
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:ErrorAction']='Stop'

# If doesn't exists create C:/Promtail
$path = "C:\Promtail"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

Set-Location -Path $path
Import-Module -name AWSPowerShell

Write-Output "Download promtail installer from S3."
Read-S3Object -BucketName $env:INSTALLERS_BUCKET -Key "$env:PROMTAIL_BUCKET_KEY/promtail-$env:PROMTAIL_VERSION-win64.exe" -File promtail_installer.exe
# Read-S3Object -BucketName $env:INSTALLERS_BUCKET -Key "$env:PROMTAIL_BUCKET_KEY/promtail_windows_config.yaml" -File promtail_config.yaml

Start-Sleep -Seconds 100

# Write-Output "Run the promtail installer."

# $pathvargs = "C:\Temp\promtail_installer.exe"
# Start-Process -FilePath $pathvargs -ArgumentList "--config.file C:\Temp\promtail_config.yaml" /S -NoNewWindow

