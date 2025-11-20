
$ErrorActionPreference = 'Stop';

# package download information
$url64      = 'https://edge.elgato.com/egc/windows/echw/2.2.2/CameraHub_2.2.2.6949_x64.msi'
$checksum64 = 'e7a8ed8a58b3cdcd962ac157d88cf91fdd634df6b09c672cbe26f6a08e2064f6'

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
