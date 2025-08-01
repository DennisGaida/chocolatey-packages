
$ErrorActionPreference = 'Stop';

# package download information
$url64      = 'https://edge.elgato.com/egc/windows/echw/2.1.0/CameraHub_2.1.0.6409_x64.msi'
$checksum64 = ''

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url64bit       = $url64

  softwareName   = 'Elgato Camera Hub'

  checksum64     = $checksum64
  checksumType64 = 'sha256'

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
