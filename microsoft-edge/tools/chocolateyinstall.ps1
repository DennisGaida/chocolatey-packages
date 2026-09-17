
$ErrorActionPreference = 'Stop';
$url32 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/a3100290-d664-4291-8228-2ffef62e5f6f/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/fac1dc9b-8a85-4c7a-9bf3-2d755ac87b07/MicrosoftEdgeEnterpriseX64.msi'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum       = 'B739D929FBE972E331C5E7F977682BB2299EF78A36FE0E201630D1FFFF13A2DB'
  checksumType   = 'sha256'
  checksum64     = 'CA91A142DC401FE8195E1E6F14273F026EAD228900857F97405CE4F1656CD5B8'
  checksumType64 = 'sha256'

  silentArgs     = "{0} /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" -f (CheckNoDestop $pp)
  validExitCodes = @(0, 3010, 1641)
}

$32Path = Join-Path -Path ${Env:ProgramFiles(x86)} -ChildPath 'Microsoft\Edge\Application\msedge.exe'
$64Path = Join-Path -Path $Env:ProgramFiles -ChildPath 'Microsoft\Edge\Application\msedge.exe'

if (Test-Path $32Path)
{
  [Version]$InstalledVersion = (Get-ItemProperty -Path $32Path).VersionInfo.ProductVersion
}
if (Test-Path $64Path)
{
  [Version]$InstalledVersion = (Get-ItemProperty -Path $64Path).VersionInfo.ProductVersion
}

$UpdateNeeded = $InstalledVersion -lt [Version]$Env:ChocolateyPackageVersion

if ($UpdateNeeded -or $Env:ChocolateyForce)
{
  Install-ChocolateyPackage @packageArgs
}
