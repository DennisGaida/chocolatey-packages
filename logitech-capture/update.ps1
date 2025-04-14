Import-Module au
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1"

$releases_url = 'https://www.logitech.com/en-us/software/capture.html'


function global:au_SearchReplace {
  @{
      'tools\chocolateyInstall.ps1' = @{
          "(^[$]url\s*=\s*)('.*')"          = "`$1'$($Latest.Url32)'"
          "(^[$]checksum\s*=\s*)('.*')"     = "`$1'$($Latest.Checksum32)'"
      }
  }
}

function global:au_BeforeUpdate() {
  $Latest.Checksum32 = Get-RemoteChecksum $Latest.Url32
}

function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases_url -UseBasicParsing

  $re    = '\.exe'
  $url32 = $download_page.Links | Where-Object { $_.href -match $re } | Select-Object -First 1 -ExpandProperty href

  $re_version     = "Capture_(\d*\.\d*\.\d*)\.exe"
  $version_number = $Url32 | Select-String -Pattern $re_version | % { $_.matches.groups[1].Value }

  $Latest = @{ URL32 = $Url32; Version = $version_number}
  return $Latest
}

Update -ChecksumFor 32
