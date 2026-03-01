$ErrorActionPreference = 'Stop';

$packageName        = 'trivy'
$version            = '0.69.2'
$url64              = "https://github.com/aquasecurity/trivy/releases/download/v"+$version+"/trivy_"+$version+"_Windows-64bit.zip"
$checksum64         = 'd772fa7c3c1bc52d2914ff78107596fbd20010b5f18bec6f39d63ee3bb31ad45'
$bindir             = Join-Path $env:ChocolateyInstall "lib\trivy\tools\trivy.exe"

[regex]$downloaddatabaseonly = “(?i)^(Yes|No)$”

$pp=Get-PackageParameters
if (!$pp['DownloadDatabaseOnly']) {$pp['DownloadDatabaseOnly']='No'}
else {
    if ($pp['DownloadDatabaseOnly'] -notmatch $downloaddatabaseonly) {
      Write-Output "Wrong value $($pp.DownloadDatabaseOnly) for parameter DownloadDatabaseOnly"
      exit (1)
    }
}
$packageArgs = @{
  packageName     = $packageName
  fileType        = 'msi'
  url64bit        = $url64
  UnzipLocation   = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
  checksumType64  = 'sha256'
  checksum64      = $checksum64
}

Install-ChocolateyZipPackage @packageArgs

# Write-Output $bindir
try {
    if ($($pp.DownloadDatabaseOnly) -eq "Yes") {
      Write-Output "Updating Trivy databases - it can take a while"
      & $bindir 'image --download-db-only'
    }
    else {
      Write-Output "No db update selected"
    }
}
catch {
  # We don't care about updates, if they'll fail, do not fail package
  exit (0)
}