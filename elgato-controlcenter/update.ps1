Import-Module au
$releases_url           = "https://gc-updates.elgato.com/"
$product_name           = "cc-win"

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
  # get contents of the download API response
  $download_release_content = (Invoke-WebRequest $releases_url).Content
    
  # grab the JSON containing all version/download information
  $json_data = $download_release_content | ConvertFrom-Json

  # get download URL from JSON array by product name
  $download_url = $json_data.$product_name.downloadURL

  # get version number from JSON array by product name
  $version_number = $json_data.$product_name.version
  
  $Latest = @{ URL32 = $download_url; Version = $version_number}
  return $Latest
}

update