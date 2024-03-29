
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:ErrorAction']='Stop'

# If doesn't exists create C:/Temp
$path = "C:\Temp"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

Set-Location -Path $path
Import-Module -name AWSPowerShell

Write-Output "Download windows exporter installer from S3."
Read-S3Object -BucketName $env:INSTALLERS_BUCKET -Key "$env:EXPORTER_BUCKET_KEY/windows_exporter-$env:EXPORTER_VERSION-amd64.msi" -File windows_exporter.msi

Start-Sleep -Seconds 70

Write-Output "Install the windows exporter."
msiexec -i C:\Temp\windows_exporter.msi ENABLED_COLLECTORS=[defaults],cpu,cs,iis,logical_disk,memory,mssql,net,os,service,textfile,process,container,memory
