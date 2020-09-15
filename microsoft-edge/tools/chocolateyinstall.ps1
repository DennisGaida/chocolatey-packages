
$ErrorActionPreference = 'Stop';
$url32 = 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/5350dcd0-a1ff-4756-b717-43971fca682b/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/63c21fa1-e10e-40ef-a9ac-b51f877c7cfb/MicrosoftEdgeEnterpriseX64.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum       = 'ED1FE0CBF82F20E785E9DA8B76F3F4C8AC035870AA9D28A122A94A4BA97723C4'
  checksumType   = 'sha256'
  checksum64     = '14D600A05EDBD86C5F291AE9597CBB41E1F88F505F24DD3F899A61146F320717'
  checksumType64 = 'sha256'

  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
