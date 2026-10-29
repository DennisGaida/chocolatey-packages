
$ErrorActionPreference = 'Stop';

# package download information
$url64      = 'https://github.com/AprilNEA/OpenLogi/releases/download/v0.8.19/OpenLogi-v0.8.19-windows-x86_64.msi'
$checksum64 = 'b105d12b54949ef03cf33b7647c30ab309ff2a3bbc02ea0262429d08461bdce7'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url64bit       = $url64

  softwareName   = 'OpenLogi'

  checksum64     = $checksum64
  checksumType64 = 'sha256'

  # OpenLogi's MSI installs per-user (no elevation required); /qn keeps it silent.
  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).installer.log`""
  validExitCodes = @(0, 3010, 1641)
}

# Per-user install location (packaging/windows/OpenLogi.wxs installs to %LocalAppData%\Programs\OpenLogi).
$InstallPath = Join-Path -Path $Env:LocalAppData -ChildPath 'Programs\OpenLogi\OpenLogi.exe'

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
