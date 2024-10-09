
$ErrorActionPreference = 'Stop';
$url32 = 'https://edge.elgato.com/egc/windows/echw/1.11.0/CameraHub_1.11.0.4066_x64.msi'

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url            = $url32

  softwareName   = 'Elgato Camera Hub'

  # checksum       = 'ebf3f660d241c8d9363a4c0fb2518312dc0501d1870af532f7204a7c368f5d07'
  # checksumType   = 'sha256'

  silentArgs     = "/quiet /lv `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).installer.log`""
  validExitCodes = @(0, 3010, 1641)
}

$InstallPath = Join-Path -Path ${Env:ProgramFiles} -ChildPath 'Elgato\CameraHub\Camera Hub.exe'

if (Test-Path $InstallPath)
{
  # get the installed version number, removing build information from the version number
  [Version]$InstalledVersion = (Get-ItemProperty -Path $InstallPath).VersionInfo.ProductVersion
}

$UpdateNeeded = $InstalledVersion -lt [Version]$Env:ChocolateyPackageVersion

if ($UpdateNeeded -or $Env:ChocolateyForce)
{
  Install-ChocolateyPackage @packageArgs
}
