# -----------------------------------------------------------------------------------------------
# Component: Sophos Central Register Only
# Author: Stephen Weber
# Purpose: Using the new Sophos Thin installer, 
#          perform a Register Only for the Endpoint.
# Version 1.0
# -----------------------------------------------------------------------------------------------

#Setup Customer Variables
#CustomerToken - Example - "Customer Token Here"
$Global:CustomerToken = 

# Define Functions

# Check for the Site Variables
Write-Host ""
Write-Host "Checking the Variables"

if ($CustomerToken -eq $null)
	{Write-Host "--Customer Token Not Set or Missing"
    Stop-Transcript
	Exit 1}
else
	{Write-Host "--CustomerToken = "$CustomerToken""}

# Sophos parameters are defined from the site specific variables
$arguments = "--registeronly --quiet"

# Check to see if a previous SophosSetup Process is running
Write-Host ""
Write-Host "Checking to see if SophosSetup.exe is already running"
if ((get-process "sophossetup" -ea SilentlyContinue) -eq $Null){
        Write-Host "--SophosSetup Not Running" 
}
else {
    Write-Host "Sophos Currently Running, Will Kill the Process before Continuing"
    Stop-Process -processname "sophossetup"
 }

#Force PowerShell to use TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download of the Central Customer Installer
Write-Host ""
Write-Host "Downloading Sophos Central Installer"
Invoke-WebRequest -Uri "https://central.sophos.com/api/partners/download/windows/v1/$CustomerToken/SophosSetup.exe" -OutFile SophosSetup.exe
if ((Test-Path SophosSetup.exe) -eq "True"){
		Write-Host "--Sophos Setup Installer Downloaded Successfully"
}
else {
	Write-Host "--Sophos Central Installer Did Not Download - Please check Firewall or Web Filter"
	Stop-Transcript
	Exit 1
}

# This Section starts the installer using the arguments defined above
Write-Host ""
Write-Host "Installing Sophos Central Endpoint:"
Write-Host ""
Write-Host "SophosSetup.exe "$arguments""
Write-Host ""

start-process SophosSetup.exe $arguments

