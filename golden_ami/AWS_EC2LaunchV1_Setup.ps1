$launchConfig = @"
{
  "setComputerName": true,
  "setMonitorAlwaysOn": true,
  "setWallpaper": true,
  "addDnsSuffixList": true,
  "extendBootVolumeSize": true,
  "handleUserData": true,
  "adminPasswordType": "Random",
  "adminPassword":  ""
}
"@
Set-Content -Value $launchConfig -Path C:\ProgramData\Amazon\EC2-Windows\Launch\Config\LaunchConfig.json
