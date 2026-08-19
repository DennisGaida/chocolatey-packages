Import-Module au
$releases_url = "https://api.github.com/repos/AprilNEA/OpenLogi/releases/latest"

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url64\s*=\s*)('.*')"              = "`$1'$($Latest.URL64)'"
      "(?i)(^\s*[$]?checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
    }
   }
}

function global:au_GetLatest {
  $release = Invoke-RestMethod -Uri $releases_url

  $asset_name = 'OpenLogi-{0}-windows-x86_64.msi' -f $release.tag_name
  $asset = $release.assets | Where-Object -Property name -eq $asset_name
  if (-not $asset) {
    throw "Could not find a windows-x86_64.msi asset in the latest release ($($release.tag_name))"
  }

  $checksums_asset = $release.assets | Where-Object -Property name -eq 'SHA256SUMS'
  if (-not $checksums_asset) {
    throw "Could not find SHA256SUMS asset in the latest release ($($release.tag_name))"
  }

  $tmpChecksumFile = "$($env:TEMP)\openlogi-SHA256SUMS"
  Invoke-WebRequest $checksums_asset.browser_download_url -OutFile $tmpChecksumFile
  $checksum64 = (Select-String -Path $tmpChecksumFile -Pattern "(\S{64})\s+$([regex]::Escape($asset.name))").Matches[0].Groups[1].Value
  Remove-Item $tmpChecksumFile

  $version_number = $release.tag_name -replace '^v'

  $Latest = @{ URL64 = $asset.browser_download_url; Version = $version_number; Checksum64 = $checksum64 }
  return $Latest
}

Update-Package -ChecksumFor none
