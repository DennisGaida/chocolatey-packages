
$ErrorActionPreference = 'Stop';
$url32 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4b00117c-a7d2-42eb-825a-8fb53239790a/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/311f0c4f-89f0-415f-a56a-74060ca99bd0/MicrosoftEdgeEnterpriseX64.msi'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum       = '3C68A69C8ECED6D361D72FDDEC7F9F699C2790A93FE6E3B32F8282C9934B4F62'
  checksumType   = 'sha256'
  checksum64     = '36B370DD79EE5C20E40980EC3CFE44B01EDD94B81E908B7D0411548A6FB27FD5'
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
