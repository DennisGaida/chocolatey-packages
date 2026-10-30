
$ErrorActionPreference = 'Stop';
$url32 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d2cf7bd2-bdff-4498-aabc-f92bd2d4a9a1/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d0a4e3fc-604a-4d46-8fd6-e90de2df72f6/MicrosoftEdgeEnterpriseX64.msi'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum       = '8FC2F8E437980DDC0FEED79398295DD16A5B0CAB370DFD5D1D5D82340278EBE1'
  checksumType   = 'sha256'
  checksum64     = '784051EBFCC8B28569127F381D515766866C4925312D35C52293382B97EEF2FB'
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
