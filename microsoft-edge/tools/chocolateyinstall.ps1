
$ErrorActionPreference = 'Stop';
$url32 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/d1ee8487-a470-44f5-92de-83d69ca96b48/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/1c94fae2-b0f4-4415-bb95-dae4c4c7189d/MicrosoftEdgeEnterpriseX64.msi'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum       = '981992203F5F33FA724FC82E1B8D15833FF3CE79A128E74A092D1AA34F8332F6'
  checksumType   = 'sha256'
  checksum64     = 'A69CD31857DFBE3FB138E5D5BB5EA0A1BBEB7204926BA17AD36FB0E6E3F50EF0'
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
