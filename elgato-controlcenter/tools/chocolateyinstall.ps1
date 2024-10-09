
$ErrorActionPreference = 'Stop';

# package download information
$url64      = 'https://edge.elgato.com/egc/windows/eccw/1.7.1/ControlCenter_1.7.1.600_x64.msi'
$checksum64 = '4af1de0c4cdc65f307518d0fc3915ca56740cd499211b6a858d4dcc6a88c0b09'

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url64bit       = $url64

  softwareName   = 'Elgato Control Center'

  checksum64     = $checksum64
  checksumType64 = 'sha256'

  silentArgs     = "/quiet /lv `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).installer.log`""
  validExitCodes = @(0, 3010, 1641)
}

$InstallPath = Join-Path -Path ${Env:ProgramFiles} -ChildPath 'Elgato\ControlCenter\ControlCenter.exe'

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
