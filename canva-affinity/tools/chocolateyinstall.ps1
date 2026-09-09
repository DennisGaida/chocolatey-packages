$ErrorActionPreference = 'Stop'
$url64 = 'https://downloads.affinity.studio/Affinity%20x64.exe'

# The download URL is not version-locked (it always serves the current build), so
# these checksums are recomputed and pinned by update.ps1 every time a new version
# is packaged - see au_GetLatest there.
$checksum64     = '7273dd459959ae5e4fa7a56bf8690eedbafdf06adc3039e724f5dc01ba31902e'
$checksumType64 = 'sha256'
$checksumMsi    = '5f81d3bce4a6b1d291e0199067e5f77b58de2763512af84bc50bca0007b527a0'

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
