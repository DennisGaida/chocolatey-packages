
$ErrorActionPreference = 'Stop';
$url32 = 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/d940bdf2-0d2a-4cad-ae8f-0700adcf7b9e/MicrosoftEdgeEnterpriseX86.msi'
$url64 = 'http://dl.delivery.mp.microsoft.com/filestreamingservice/files/07367ab9-ceee-4409-a22f-c50d77a8ae06/MicrosoftEdgeEnterpriseX64.msi'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  url            = $url32
  url64bit       = $url64

  softwareName   = 'Microsoft Edge'

  checksum32     = '8a131f249e28d5e1cb0bb7b9156ba0fb93f5d7a2896bb5e3ce5df6c80c39e372'
  checksumType   = 'sha256'
  checksum64     = '7e91f560469806f3842b16e185241bbae82714a86808507fa23a4312ea1e0c11'
  checksumType64 = 'sha256'

  silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
