Write-Output "Installing CERT advisory patches"

$pathTemp = "C:\Temp"
$pathTempPatches = "cert-advisory-patching"

$OS = Get-WmiObject -query "select Caption, OSArchitecture from win32_OperatingSystem"
$OSName=$OS.Caption

If(!(test-path $pathTemp))
{
      New-Item -ItemType Directory -Force -Path $pathTemp
}

Set-Location -Path $pathTemp
if (test-path $pathTempPatches) {
    Remove-Item -Path $pathTempPatches -Force -Recurse
}

New-Item -ItemType directory -Path "$pathTempPatches"
Set-Location -Path "$pathTemp/$pathTempPatches"

Write-Output "Searching for CERT hotfixes in s3://$env:CERTPatchesBucket/$OSName/"

aws s3 cp "s3://$env:CERTPatchesBucket/$OSName/" . --recursive

$MSUPackages = Get-ChildItem *.msu -Recurse
 
foreach ($KBFile in $MSUPackages) {
    Write-Output "Installing patchfile $KBFile"
    $install = [System.Diagnostics.Process]::Start('wusa.exe', "/norestart /quiet $KBFile")
    $install.WaitForExit()
    Write-Output "Installation done"
}

Write-Output "Installation of Cert advisory packages finished"