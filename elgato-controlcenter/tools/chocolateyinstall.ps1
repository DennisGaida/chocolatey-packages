
$ErrorActionPreference = 'Stop';

# package download information
$url64      = 'https://edge.elgato.com/egc/windows/eccw/1.9/Elgato.ControlCenter_1.9.0.818_x64.msi'
$checksum64 = '8b172310722dedd241a51e4138423587040fb171868f84712c1429599dc68400'

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'msi'
  url64bit       = $url64

  softwareName   = 'Elgato Control Center'

  checksum64     = $checksum64
  checksumType64 = 'sha256'

  # The vendor MSI's LaunchConditions checks WIX_IS_NETFRAMEWORK_481_OR_LATER_INSTALLED,
  # but never sets that property from its own (correctly detected) WIXNETFX4RELEASEINSTALLED
  # search result - so the condition is always false and the MSI refuses to install via
  # msiexec at all (silent or not), even when .NET 4.8.1 is genuinely present. Since this
  # package depends on netfx-4.8.1, it's safe to pass the property explicitly.
  silentArgs     = "/quiet /lv `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).installer.log`" WIX_IS_NETFRAMEWORK_481_OR_LATER_INSTALLED=1"
  validExitCodes = @(0, 3010, 1641)
}

$InstallPath = Join-Path -Path ${Env:ProgramFiles} -ChildPath 'Elgato\ControlCenter\ControlCenter.exe'

if (Test-Path $InstallPath)
{
  # get the installed version number, removing build information from the version number
  [Version]$InstalledVersion = (Get-ItemProperty -Path $InstallPath).VersionInfo.ProductVersion
}

$UpdateNeeded = $InstalledVersion -lt [Version]$Env:ChocolateyPackageVersion

if ($UpdateNeeded -or $Env:ChocolateyForce)
{
  Install-ChocolateyPackage @packageArgs
}
