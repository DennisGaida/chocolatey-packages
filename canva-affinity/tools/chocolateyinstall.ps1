
$ErrorActionPreference = 'Stop';
$url64    = 'https://downloads.affinity.studio/Affinity%20x64.exe'
$toolsPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'exe'
  url64bit       = $url64

  softwareName   = 'Affinity'

  checksum64     = '255BB7E688BC68818513A469F6BEC75EF48A4FDB3956E37ED33411CDFAC3E50D'
  checksumType64 = 'sha256'

  validExitCodes = @(0)
}

$InstallPath = Join-Path -Path ${Env:ProgramFiles} -ChildPath 'Affinity\Affinity\Affinity.exe'

if (Test-Path $InstallPath)
{
  # get the installed version number, removing build information from the version number
  [Version]$InstalledVersion = ((Get-ItemProperty -Path $InstallPath).VersionInfo.FileVersionRaw.ToString().Split('.') | Select-Object -First 3) -join '.'
}

$UpdateNeeded = $InstalledVersion -lt [Version]$Env:ChocolateyPackageVersion

if ($UpdateNeeded -or $Env:ChocolateyForce)
{
  Write-Host "Starting AutoHotKey in the background...";
  $ahkExe = 'AutoHotKey'
  $ahkFile = Join-Path $toolsPath "affinityinstall.ahk"
  $ahkProc = Start-Process -FilePath $ahkExe `
                           -ArgumentList $ahkFile `
                           -PassThru

  $ahkId = $ahkProc.Id
  Write-Debug "$ahkExe start time:`t$($ahkProc.StartTime.ToShortTimeString())"
  Write-Debug "Process ID:`t$ahkId"

  Install-ChocolateyPackage @packageArgs
}
