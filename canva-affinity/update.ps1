(Get-Item '.\Affinity x64.exe').VersionInfo.FileVersionRaw


Import-Module au
$release_url = "https://downloads.affinity.studio/Affinity%20x64.exe"

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(^[$]url64\s*=\s*)('.*')"              = "`$1'$($Latest.URL64)'"
      "(?i)(^\s*checksum64\s*=\s*)('.*')"       = "`$1'$($Latest.Checksum64)'"
    }
   }
}

function global:au_BeforeUpdate() {
  $Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64
}

function global:au_GetLatest {
  # # There currently doesn't seem to be any changelog or version information available online
  # # Only chance is to download the release and compare via hash
  # --------- We'll Ignore AU for now ---------
  # $download_url = $release_url

  # # download checksum file and get the sha-256 hash for the installer
  # $tmpDownloadFile = "$($env:TEMP)\Affinity.exe"
  # Invoke-WebRequest $download_url -OutFile $tmpDownloadFile
  # $checksum = (Get-FileHash -Algorithm "SHA256" -Path $tmpDownloadFile).Hash
  
  # $version_number = ((Get-ItemProperty -Path $tmpDownloadFile).VersionInfo.FileVersionRaw.ToString().Split('.') | Select-Object -First 3) -join '.'

  # Remove-Item $tmpDownloadFile
  
  # $Latest = @{ URL64 = $download_url; Version = $version_number; Checksum64 = $checksum}
  # return $Latest
  return 'ignore'
}

Update-Package