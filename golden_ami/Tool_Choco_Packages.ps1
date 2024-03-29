Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Autologon
Write-Output "Setting Autologon to Administrator user"

$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String
Set-ItemProperty $RegPath "DefaultUsername" -Value "$env:computername\Administrator" -type String

# Install Chocolatey
Write-Output 'Install Chocolatey'
Invoke-Expression -Command ((New-Object -TypeName System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -Verbose

Write-Output 'Globally Auto confirm every action for Chocolatey'
choco feature enable -n allowGlobalConfirmation

Write-Output 'Globally disable Chocolatey download progress'
choco feature disable -n showDownloadProgress

Write-Output 'Globally disable Chocolatey "useEnhancedExitCodes" feature'
choco feature disable --name="'useEnhancedExitCodes'"

# Install awscli
Write-Output 'Install awscli'
choco install awscli

# Install jq
Write-Output 'Install jq'
choco install jq

# Install Encryption sdk and its prerequisuites
Write-Output 'Install python'
choco install python --version=3.9.6

Write-Output 'Install Network Monitor'
choco install networkmonitor

Write-Output 'Installing aws-encryption-sdk-cli using pip3'
[Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Python39\Scripts")
pip install aws-encryption-sdk-cli==4.0.0
