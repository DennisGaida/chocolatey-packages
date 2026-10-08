$ErrorActionPreference = 'Stop'
$url64 = 'https://downloads.affinity.studio/Affinity%20x64.exe'

# The download URL is not version-locked (it always serves the current build), so
# these checksums are recomputed and pinned by update.ps1 every time a new version
# is packaged - see au_GetLatest there.
$checksum64     = '9e05d95a27d5e1249a9ba1e8b3ea5731988c2ab481f31aea1df13c88a025018b'
$checksumType64 = 'sha256'
$checksumMsi    = 'e148598f2dc86aca7de39ceb79ab57ee15417fc76c3abb7bfbe2b93051d1287d'

$InstallPath = Join-Path $env:ProgramFiles 'Affinity\Affinity\Affinity.exe'

if (Test-Path $InstallPath) {
  [Version]$InstalledVersion = (Get-Item $InstallPath).VersionInfo.FileVersionRaw
}

if ((-not $InstalledVersion) -or ($InstalledVersion -lt [Version]$env:ChocolateyPackageVersion) -or $env:ChocolateyForce) {

  $exeFile = Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
    -FileFullPath (Join-Path $env:TEMP "$($env:ChocolateyPackageName)-setup.exe") `
    -Url64bit $url64 `
    -Checksum64 $checksum64 -ChecksumType64 $checksumType64

  # The installer exe is a PE stub whose entire payload is a single MSI stored as
  # a binary resource (type 'BIN', ~630 MB). We extract it by parsing the PE
  # resource directory rather than relying on hardcoded offsets that would break
  # across version updates.
  . (Join-Path $PSScriptRoot 'Get-EmbeddedMsi.ps1')
  $msiPath = Join-Path $env:TEMP "$($env:ChocolateyPackageName).msi"
  Get-EmbeddedMsi -ExeFile $exeFile -MsiFile $msiPath

  # The exe checksum only guarantees we extracted from the file Chocolatey
  # verified - it says nothing about our own PE-parsing having found the right
  # resource. Belt and braces: verify the extracted MSI itself too.
  $msiHash = (Get-FileHash -Path $msiPath -Algorithm SHA256).Hash
  if ($msiHash -ne $checksumMsi.ToUpper()) {
    throw "Checksum mismatch for extracted MSI: expected $checksumMsi, got $msiHash"
  }

  try {
    $packageArgs = @{
      packageName    = $env:ChocolateyPackageName
      fileType       = 'msi'
      file           = $msiPath
      silentArgs     = '/qn /norestart'
      validExitCodes = @(0)
    }
    Install-ChocolateyInstallPackage @packageArgs
  } finally {
    Remove-Item $msiPath -ErrorAction SilentlyContinue
    Remove-Item $exeFile -ErrorAction SilentlyContinue
  }
}
