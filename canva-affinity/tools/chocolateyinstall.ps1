
$ErrorActionPreference = 'Stop';
$url64 = 'https://downloads.affinity.studio/Affinity%20x64.exe'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url64bit       = $url64

  softwareName   = 'Affinity'

  checksum64     = '26194FB7AB0C83754549C99951B2DBBDC0361278172D02BB55EAF6B42A100409'
  checksumType64 = 'sha256'

  validExitCodes = @(0)
}

$InstallPath = Join-Path -Path ${Env:ProgramFiles} -ChildPath 'Affinity\Affinity\Affinity.exe'

if (Test-Path $InstallPath)
{
  # get the installed version number, removing build information from the version number
  [Version]$InstalledVersion = ((Get-ItemProperty -Path $InstallPath).VersionInfo.FileVersionRaw.ToString().Split('.') | Select-Object -First 3) -join '.'
}

$UpdateNeeded = $InstalledVersion -lt [Version]$Env:ChocolateyPackageVersion

if ($UpdateNeeded -or $Env:ChocolateyForce)
{
  Install-ChocolateyPackage @packageArgs
}
