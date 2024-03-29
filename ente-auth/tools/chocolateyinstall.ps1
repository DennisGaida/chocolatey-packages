
$ErrorActionPreference = 'Stop';
$url32 = 'https://github.com/ente-io/ente/releases/download/auth-v2.0.48/ente-auth-v2.0.48-installer.exe'

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url            = $url32

  softwareName   = 'Ente Auth'

  checksum       = 'f591585ac992239b43d82e9b7e8fc25f64ef304792d4880fe5d82fd3b3fded8a'
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
