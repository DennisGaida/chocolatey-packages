Import-Module au
$download_api_url     = "https://edgeupdates.microsoft.com/api/products"
$release_branch       = "Stable"

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url64\s*=\s*)('.*')"              = "`$1'$($Latest.URL64)'"
      "(^[$]url32\s*=\s*)('.*')"              = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum32)'"
      "(?i)(^\s*checksum64\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum64)'"
    }
   }
}

function global:au_GetLatest {
  # get contents of the Edge download API response
  $download_api_content = (Invoke-WebRequest -Uri $download_api_url).Content
    
  # grab the JSON containing all version/download information
  $json_data = $download_api_content | ConvertFrom-Json
  
  # select the release version (Dev/Beta/Stable)
  $releases = $json_data | Where-Object -Property Product -eq $release_branch | Select-Object Releases
  
  # get download URLs and hashes from JSON
  $download_url_32 = ($releases.Releases | Where-Object {$_.Platform -eq 'Windows'} | Where-Object {$_.Architecture -eq 'x86'}).Artifacts.Location
  $download_hash_32 = ($releases.Releases | Where-Object {$_.Platform -eq 'Windows'} | Where-Object {$_.Architecture -eq 'x86'}).Artifacts.Hash
  $download_url_64 = ($releases.Releases | Where-Object {$_.Platform -eq 'Windows'} | Where-Object {$_.Architecture -eq 'x64'}).Artifacts.Location
  $download_hash_64 = ($releases.Releases | Where-Object {$_.Platform -eq 'Windows'} | Where-Object {$_.Architecture -eq 'x64'}).Artifacts.Hash

  $version_number = ($releases.Releases | Where-Object {$_.Platform -eq 'Windows'} | Where-Object {$_.Architecture -eq 'x64'}).ProductVersion.Trim()
  
  $Latest = @{URL32 = $download_url_32; URL64 = $download_url_64; Version = $version_number; Checksum32 = $download_hash_32; Checksum64 = $download_hash_64;}
  return $Latest
}

update