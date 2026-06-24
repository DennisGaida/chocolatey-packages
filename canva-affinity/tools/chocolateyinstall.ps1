$ErrorActionPreference = 'Stop'
$url64 = 'https://downloads.affinity.studio/Affinity%20x64.exe'

$InstallPath = Join-Path $env:ProgramFiles 'Affinity\Affinity\Affinity.exe'

if (Test-Path $InstallPath) {
  [Version]$InstalledVersion = (Get-Item $InstallPath).VersionInfo.FileVersionRaw
}

if ((-not $InstalledVersion) -or ($InstalledVersion -lt [Version]$env:ChocolateyPackageVersion) -or $env:ChocolateyForce) {

  $exeFile = Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
    -FileFullPath (Join-Path $env:TEMP "$($env:ChocolateyPackageName)-setup.exe") `
    -Url64bit $url64 `
    -Checksum64 '' -ChecksumType64 'none'

  # The installer exe is a PE stub whose entire payload is a single MSI stored as
  # a binary resource (type 'BIN', ~630 MB). We extract it by parsing the PE
  # resource directory rather than relying on hardcoded offsets that would break
  # across version updates.
  $msiPath = Join-Path $env:TEMP "$($env:ChocolateyPackageName).msi"

  $fs = [System.IO.File]::OpenRead($exeFile)
  try {
    # ── Locate the .rsrc section ─────────────────────────────────────────────
    # 0x3C holds the offset to the PE signature. After it: 20-byte COFF header,
    # then the optional header. Section headers follow at peOff+24+optHeaderSize.
    # Each section header is 40 bytes; fields we need: VA (+12) and raw offset (+20).
    $hdr = New-Object byte[] 4096
    $fs.Read($hdr, 0, 4096) | Out-Null
    $peOff = [BitConverter]::ToUInt32($hdr, 0x3C)
    $nSect = [BitConverter]::ToUInt16($hdr, $peOff + 6)
    $optSz = [BitConverter]::ToUInt16($hdr, $peOff + 20)
    $sBase = $peOff + 24 + $optSz
    $rsrcVA = $rsrcRaw = 0
    for ($i = 0; $i -lt $nSect; $i++) {
      $s = $sBase + $i * 40
      if ([System.Text.Encoding]::ASCII.GetString($hdr[$s..($s+7)]).TrimEnd([char]0) -eq '.rsrc') {
        $rsrcVA  = [BitConverter]::ToUInt32($hdr, $s + 12)
        $rsrcRaw = [BitConverter]::ToUInt32($hdr, $s + 20)
        break
      }
    }

    # ── Find the largest resource entry (the embedded MSI) ───────────────────
    # The resource section is a three-level directory tree (type → ID → language).
    # Each IMAGE_RESOURCE_DIRECTORY has a 16-byte header then 8-byte entries.
    # A high bit in an entry's data field = sub-directory; clear = data leaf.
    # The leaf (IMAGE_RESOURCE_DATA_ENTRY) stores the VA and byte size of the data.
    # We walk every leaf and take the largest one — that is the MSI.
    # 64 KB is enough to hold all directory entries; the actual data is elsewhere.
    $rbuf = New-Object byte[] 65536
    $fs.Seek($rsrcRaw, [System.IO.SeekOrigin]::Begin) | Out-Null
    $fs.Read($rbuf, 0, 65536) | Out-Null

    $bestSize = 0L; $bestVA = 0
    $l1Named = [BitConverter]::ToUInt16($rbuf, 12)
    $l1Id    = [BitConverter]::ToUInt16($rbuf, 14)
    $off1 = 16
    for ($i = 0; $i -lt ($l1Named + $l1Id); $i++) {
      $d1 = [BitConverter]::ToUInt32($rbuf, $off1 + 4); $off1 += 8
      if (($d1 -band 0x80000000) -eq 0) { continue }   # skip data leaves at this level
      $r1 = $d1 -band 0x7FFFFFFF
      $l2Named = [BitConverter]::ToUInt16($rbuf, $r1 + 12)
      $l2Id    = [BitConverter]::ToUInt16($rbuf, $r1 + 14)
      $off2 = $r1 + 16
      for ($j = 0; $j -lt ($l2Named + $l2Id); $j++) {
        $d2 = [BitConverter]::ToUInt32($rbuf, $off2 + 4); $off2 += 8
        if (($d2 -band 0x80000000) -eq 0) { continue }
        $r2 = $d2 -band 0x7FFFFFFF
        # Level 3 entry points directly to a data leaf (no further sub-directory).
        $d3 = [BitConverter]::ToUInt32($rbuf, $r2 + 20)
        $r3 = $d3 -band 0x7FFFFFFF
        $leaf = New-Object byte[] 8
        $fs.Seek($rsrcRaw + $r3, [System.IO.SeekOrigin]::Begin) | Out-Null
        $fs.Read($leaf, 0, 8) | Out-Null
        $va = [BitConverter]::ToUInt32($leaf, 0)
        $sz = [BitConverter]::ToUInt32($leaf, 4)
        if ($sz -gt $bestSize) { $bestSize = $sz; $bestVA = $va }
      }
    }

    if ($bestSize -eq 0) { throw "Could not locate embedded MSI in installer" }

    # Convert the resource VA to a raw file offset: rawOffset = VA - sectionVA + sectionRawOffset
    Write-Host "Extracting embedded MSI ($([Math]::Round($bestSize/1MB,0)) MB)..."
    $msiRawOff = $bestVA - $rsrcVA + $rsrcRaw
    $out = [System.IO.File]::Create($msiPath)
    $fs.Seek($msiRawOff, [System.IO.SeekOrigin]::Begin) | Out-Null
    $buf = New-Object byte[] 65536
    $remaining = $bestSize
    while ($remaining -gt 0) {
      $read = $fs.Read($buf, 0, [Math]::Min($remaining, $buf.Length))
      $out.Write($buf, 0, $read)
      $remaining -= $read
    }
    $out.Close()
  } finally {
    $fs.Close()
  }

  try {
    $logFile = Join-Path $env:TEMP "$($env:ChocolateyPackageName).install.log"
    $exitCode = (Start-Process msiexec -ArgumentList "/i `"$msiPath`" /qn /norestart /l*v `"$logFile`"" -Wait -PassThru).ExitCode
    if ($exitCode -ne 0) {
      throw "MSI installation failed with exit code $exitCode. Log: $logFile"
    }
  } finally {
    Remove-Item $msiPath -ErrorAction SilentlyContinue
    Remove-Item $exeFile -ErrorAction SilentlyContinue
  }
}
