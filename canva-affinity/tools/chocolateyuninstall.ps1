$ErrorActionPreference = 'Stop'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  softwareName   = 'Affinity'
  fileType       = 'MSI'
  silentArgs     = '/qn /norestart'
  validExitCodes = @(0)
}

[array]$key = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']
if ($key.Count -eq 1) {
  $packageArgs['silentArgs'] = "$($key[0].PSChildName) /qn /norestart"
  $packageArgs['file'] = ''
  Uninstall-ChocolateyPackage @packageArgs
} elseif ($key.Count -eq 0) {
  Write-Warning "$($packageArgs['packageName']) has already been uninstalled."
} else {
  Write-Warning "Multiple installs found for '$($packageArgs['softwareName'])'; skipping automatic uninstall."
}
