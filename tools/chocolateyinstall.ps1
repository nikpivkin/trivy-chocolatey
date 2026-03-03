$ErrorActionPreference = 'Stop';

$packageName        = 'trivy'
$version            = '0.69.3'
$url64              = "https://github.com/aquasecurity/trivy/releases/download/v"+$version+"/trivy_"+$version+"_Windows-64bit.zip"
$checksum64         = '74362dc711383255308230ecbeb587eb1e4e83a8d332be5b0259afac6e0c2224'
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