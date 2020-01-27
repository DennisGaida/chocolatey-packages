Import-Module au
$download_scrape_url     = "https://www.microsoft.com/en-us/edge/business/download"
$download_scrape_version = "Stable"

$artifact_base_url       = "https://www.microsoft.com/en-us/edge/business/Product/GetArtifacturl"
$artifact_arch32         = "x86"
$artifact_arch64         = "x64"

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url64\s*=\s*)('.*')"          = "`$1'$($Latest.URL64)'"
      "(^[$]url32\s*=\s*)('.*')"          = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
      "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
    }
   }
}

function global:au_GetLatest {
  #get contents of the download page (HTML)
  $download_scrape_content = Invoke-WebRequest -Uri $download_scrape_url
  #select the first version from the version list - this should be the latest version
  $version_node   = ($download_scrape_content.AllElements | ? {$_.value -eq $download_scrape_version -and $_.'data-version' -ne $null} | select -first 1)
  $version_number = $version_node.'data-version'
  $full_version   = $version_node.outerText.Trim()
  #generate download urls
  $download_url_32 = Invoke-WebRequest -Uri "$($artifact_base_url)?productname=$($full_version)&osname=Windows&osversion=$($artifact_arch32)"
  $download_url_64 = Invoke-WebRequest -Uri "$($artifact_base_url)?productname=$($full_version)&osname=Windows&osversion=$($artifact_arch64)"
  $Latest = @{URL32 = $download_url_32; URL64 = $download_url_64; Version = $version_number; }
  return $Latest
}

update