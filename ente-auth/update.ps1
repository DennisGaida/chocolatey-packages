Import-Module au
$release_url           = "https://api.github.com/repos/ente/ente/releases?per_page=40"
$ente_auth_tag_prefix  = "auth-v"

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url32\s*=\s*)('.*')"              = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum32)'"
    }
   }
}

function global:au_GetLatest {
  # get contents of the download API response
  $download_release_content =  (Invoke-WebRequest $release_url).Content

  # grab the JSON containing all version/download information
  $json_data = $download_release_content | ConvertFrom-Json

  # filter on the auth tag prefix since in this mono repo there are all ente releases, also filter out prereleases
  $auth_releases = $json_data | Where-Object {$_.name -like "$ente_auth_tag_prefix*" -and $_.prerelease -ne $true}

  if ($auth_releases.Count -eq 0) {
    throw "No releases found with tag prefix $ente_auth_tag_prefix"
  }

  # select the latest release and filter on exe installer
  $current_release = $auth_releases[0]

  # get download URL
  $download_url = $current_release.assets | Where-Object -Property name -like "*installer.exe" | Select-Object -Expand browser_download_url

  # prefer sha256sum-windows, fall back to sha256sum
  $checksum_url = $current_release.assets | Where-Object -Property name -eq "sha256sum-windows" | Select-Object -Expand browser_download_url
  if (-not $checksum_url) {
    $checksum_url = $current_release.assets | Where-Object -Property name -eq "sha256sum" | Select-Object -Expand browser_download_url
  }

  $tmpChecksumFile = "$($env:TEMP)\$ente_auth_tag_prefix-sha256"
  Invoke-WebRequest $checksum_url -OutFile $tmpChecksumFile
  $checksum = (Select-String -Path $tmpChecksumFile -Pattern '(\S{64})\s.*installer\.exe').Matches[0].Groups[1].Value
  Remove-Item $tmpChecksumFile

  $version_number = ($current_release.name -replace $ente_auth_tag_prefix).Trim()

  $Latest = @{ URL32 = $download_url; Version = $version_number; Checksum32 = $checksum }
  return $Latest
}

Update-Package