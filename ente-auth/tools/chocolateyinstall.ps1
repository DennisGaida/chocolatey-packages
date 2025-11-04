
$ErrorActionPreference = 'Stop';
$url32 = 'https://github.com/ente-io/ente/releases/download/auth-v4.4.4/ente-auth-v4.4.4-installer.exe'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url            = $url32

  softwareName   = 'Ente Auth'

  checksum       = '8f00181a88a5df6ae60caed404a9ca7b20975f829f65c63516ea1311435a8507'
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
