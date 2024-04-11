Import-Module au
$release_url           = "https://api.github.com/repos/ente-io/ente/releases?per_page=5"
$ente_auth_tag_prefix  = "auth-v"

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url32\s*=\s*)('.*')"              = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum32)'"
    }
   }
}

function global:au_BeforeUpdate() {
  $Latest.Checksum32 = Get-RemoteChecksum $Latest.Url32
}

function global:au_GetLatest {
  # get contents of the Edge download API response
  $download_release_content =  (Invoke-WebRequest $release_url).Content
    
  # grab the JSON containing all version/download information
  $json_data = $download_release_content | ConvertFrom-Json

  $auth_releases = $json_data | Where-Object -Property name -like "$ente_auth_tag_prefix*"

  # select the latest release and filter on exe installer
  $current_release = $auth_releases[0]
  
  # get download URLs and hashes from JSON
  $download_url = $current_release[0].assets | Where-Object -Property name -like "*installer.exe" | Select-Object -Expand browser_download_url

  # get checksum URL
  $checksum_url = $current_release[0].assets | Where-Object -Property name -eq "sha256sum-windows" | Select-Object -Expand browser_download_url
  
  # download checksum file and get the sha-256 hash for the installer
  $tmpChecksumFile = "$($env:TEMP)\$ente_auth_tag_prefix-sha256"
  Invoke-WebRequest $checksum_url -OutFile $tmpChecksumFile
  $checksum = (Select-String -Path $tmpChecksumFile -Pattern '(\S{64})\s.*installer\.exe').Matches[0].Groups[1].Value
  Remove-Item $tmpChecksumFile
  $version_number = ($current_release[0].name -replace $ente_auth_tag_prefix).Trim()
  
  $Latest = @{ URL32 = $download_url; Version = $version_number; Checksum32 = $checksum}
  return $Latest
}

update