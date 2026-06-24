Import-Module au
$download_url = 'https://downloads.affinity.studio/Affinity%20x64.exe'

function global:au_SearchReplace { @{} }

function global:au_GetLatest {
  # The installer URL never changes, but the embedded file version does.
  # We read the PE FileVersion resource via 3 small HTTP range requests (~70 KB total)
  # instead of downloading the full 631 MB installer just to check the version.

  # ── Request 1: first 4 KB ───────────────────────────────────────────────────
  # The PE header lives at the very start of the exe. It tells us where each
  # section of the file is. We need the .rsrc (resource) section's virtual address
  # (VA) and its raw file offset so we can fetch it in the next request.
  $resp1 = [System.Net.HttpWebRequest]::Create($download_url)
  $resp1.AddRange('bytes', 0, 4095)
  $stream1 = $resp1.GetResponse().GetResponseStream()
  $hdr = New-Object byte[] 4096
  $stream1.Read($hdr, 0, 4096) | Out-Null
  $stream1.Close()

  # 0x3C holds the offset to the PE signature ("PE\0\0").
  # After the PE signature: 20-byte COFF header, then the optional header.
  # Section headers follow immediately after the optional header.
  $peOff  = [BitConverter]::ToUInt32($hdr, 0x3C)
  $nSect  = [BitConverter]::ToUInt16($hdr, $peOff + 6)   # number of sections
  $optSz  = [BitConverter]::ToUInt16($hdr, $peOff + 20)  # size of optional header
  $sBase  = $peOff + 24 + $optSz                          # offset of first section header

  # Each section header is 40 bytes: name (8 bytes), virtual size (4), VA (4),
  # raw size (4), raw offset (4), then 16 bytes of flags/misc.
  $rsrcVA = $rsrcRaw = 0
  for ($i = 0; $i -lt $nSect; $i++) {
    $s = $sBase + $i * 40
    if ([System.Text.Encoding]::ASCII.GetString($hdr[$s..($s+7)]).TrimEnd([char]0) -eq '.rsrc') {
      $rsrcVA  = [BitConverter]::ToUInt32($hdr, $s + 12)  # virtual address of .rsrc
      $rsrcRaw = [BitConverter]::ToUInt32($hdr, $s + 20)  # file offset of .rsrc
      break
    }
  }

  # ── Request 2: first 64 KB of .rsrc ─────────────────────────────────────────
  # The resource section starts with a three-level directory tree:
  #   Level 1 – resource type  (e.g. RT_VERSION = 0x10)
  #   Level 2 – resource ID    (always 1 for version info)
  #   Level 3 – language ID    (e.g. 2057 = en-GB)
  # Each node is an IMAGE_RESOURCE_DIRECTORY (16-byte header) followed by
  # IMAGE_RESOURCE_DIRECTORY_ENTRY records (8 bytes each).
  # A high bit in the entry's data field means "points to a sub-directory";
  # clear high bit means "points to a leaf IMAGE_RESOURCE_DATA_ENTRY".
  # All directory offsets are relative to the start of .rsrc.
  # 64 KB is far more than enough to hold all directory entries.
  $resp2 = [System.Net.HttpWebRequest]::Create($download_url)
  $resp2.AddRange('bytes', $rsrcRaw, $rsrcRaw + 65535)
  $stream2 = $resp2.GetResponse().GetResponseStream()
  $rbuf = New-Object byte[] 65536
  $stream2.Read($rbuf, 0, 65536) | Out-Null
  $stream2.Close()

  # Walk the root directory looking for the RT_VERSION entry (type 0x10).
  # The directory header at offset 0 gives the count of named and ID entries;
  # the entries themselves start at offset 16.
  $l1Named = [BitConverter]::ToUInt16($rbuf, 12)
  $l1Id    = [BitConverter]::ToUInt16($rbuf, 14)
  $off1 = 16; $vtOff = -1
  for ($i = 0; $i -lt ($l1Named + $l1Id); $i++) {
    $id = [BitConverter]::ToUInt32($rbuf, $off1)
    $d1 = [BitConverter]::ToUInt32($rbuf, $off1 + 4); $off1 += 8
    if ($id -eq 0x10 -and ($d1 -band 0x80000000) -ne 0) { $vtOff = $d1 -band 0x7FFFFFFF; break }
  }
  if ($vtOff -lt 0) { throw "RT_VERSION not found in PE resources" }

  # Descend level 2 (first entry, offset 16 into the sub-directory header) and
  # level 3 (same pattern) to reach the IMAGE_RESOURCE_DATA_ENTRY leaf.
  # The leaf gives us the VA and byte size of the raw version data.
  $d2   = [BitConverter]::ToUInt32($rbuf, $vtOff + 20)
  $l2   = $d2 -band 0x7FFFFFFF
  $d3   = [BitConverter]::ToUInt32($rbuf, $l2 + 20)
  $leaf = $d3 -band 0x7FFFFFFF

  $dataVA   = [BitConverter]::ToUInt32($rbuf, $leaf)
  $dataSize = [BitConverter]::ToUInt32($rbuf, $leaf + 4)
  # Convert VA → raw file offset using the .rsrc base values from request 1.
  $dataRaw  = $dataVA - $rsrcVA + $rsrcRaw

  # ── Request 3: ~700 bytes of version data ───────────────────────────────────
  # The VS_VERSION_INFO blob starts with a small header and the wide string
  # "VS_VERSION_INFO", followed by the VS_FIXEDFILEINFO structure.
  # We locate VS_FIXEDFILEINFO by its 4-byte signature 0xFEEF04BD, then read
  # dwFileVersionMS (offset +8) and dwFileVersionLS (offset +12):
  #   major = MS >> 16,  minor = MS & 0xFFFF
  #   build = LS >> 16   (we drop the revision / build number)
  $resp3 = [System.Net.HttpWebRequest]::Create($download_url)
  $resp3.AddRange('bytes', $dataRaw, $dataRaw + $dataSize - 1)
  $stream3 = $resp3.GetResponse().GetResponseStream()
  $vbuf = New-Object byte[] $dataSize
  $stream3.Read($vbuf, 0, $dataSize) | Out-Null
  $stream3.Close()

  for ($i = 0; $i -lt ($dataSize - 4); $i++) {
    if ($vbuf[$i] -eq 0xBD -and $vbuf[$i+1] -eq 0x04 -and $vbuf[$i+2] -eq 0xEF -and $vbuf[$i+3] -eq 0xFE) {
      $fvMS = [BitConverter]::ToUInt32($vbuf, $i + 8)
      $fvLS = [BitConverter]::ToUInt32($vbuf, $i + 12)
      $version = '{0}.{1}.{2}' -f (($fvMS -shr 16) -band 0xFFFF), ($fvMS -band 0xFFFF), (($fvLS -shr 16) -band 0xFFFF)
      return @{ URL64 = $download_url; Version = $version }
    }
  }
  throw "VS_FIXEDFILEINFO not found in version resource"
}

Update-Package -ChecksumFor none
