
$ErrorActionPreference = 'Stop';
$url32 = 'https://github.com/ente-io/ente/releases/download/auth-v2.0.50/ente-auth-v2.0.50-installer.exe'

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url            = $url32

  softwareName   = 'Ente Auth'

  checksum       = 'ebf3f660d241c8d9363a4c0fb2518312dc0501d1870af532f7204a7c368f5d07'
  checksumType   = 'sha256'

  silentArgs     = "{0} /VERYSILENT /SUPPRESSMSGBOXES /LOG=`"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).installer.log`""
  validExitCodes = @(0)
}

$InstallPath = Join-Path -Path ${Env:ProgramFiles} -ChildPath 'Ente Auth\auth.exe'

if (Test-Path $InstallPath)
{
  # get the installed version number, removing build information from the version number
  [Version]$InstalledVersion = (Get-ItemProperty -Path $InstallPath).VersionInfo.ProductVersion -replace '\+.*'
}

$UpdateNeeded = $InstalledVersion -lt [Version]$Env:ChocolateyPackageVersion

if ($UpdateNeeded -or $Env:ChocolateyForce)
{
  Install-ChocolateyPackage @packageArgs
}
