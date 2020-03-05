
$ErrorActionPreference = 'Stop';
$url32 = 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/d79c2c42-96fa-40a3-90ca-bdfd0d7c79b0/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/2828e59b-2d46-4c1d-8d52-235fe21da25b/MicrosoftEdgeEnterpriseX64.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum32     = 'D111950A40D5DACC5766E82DE539B4062E4C05E2F071902C7070ECC240478BD7'
  checksumType   = 'sha256'
  checksum64     = '279B3E6EB2DDE04CA7601AE9C975A95A5057B1FC44E2B7E8A247944164B41EB2'
  checksumType64 = 'sha256'

  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
