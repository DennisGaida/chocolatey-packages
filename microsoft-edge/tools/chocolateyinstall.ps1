
$ErrorActionPreference = 'Stop';
$url32 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/7a0cd07c-ad6f-4c1d-9429-fd84982eca41/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/7391befd-12cb-46ab-8797-7c9d6a98d20d/MicrosoftEdgeEnterpriseX64.msi'

$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
. $toolsDir\helpers.ps1

$pp = Get-PackageParameters

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum       = 'DB3017F03D40F49D14FD7B2E739BB9CAA8462FFCAE2D3A3C72E9CC56A28FD306'
  checksumType   = 'sha256'
  checksum64     = '182C90DDAB531717750BDE7FABC80CC3DD21CE0277E273CBAD38B13C0DC03917'
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
