# -----------------------------------------------------------------------------------------------
# Component: Sophos Central Installer
# Author: Stephen Weber
# Purpose: Using the new Sophos Thin installer, 
#          perform default install of Sophos Central using the defined variables
# Version 1.2
# -----------------------------------------------------------------------------------------------

#Setup Customer Variables
#CustomerToken - Example - "Customer Token Here"
#Products - Example - "antivirus,intercept"
$Global:CustomerToken = 
$Global:Products = 

# Define Functions

function Get-SophosInstalled {

$Global:installed = (gp HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -contains "Sophos Endpoint Agent"
$Global:mcsclient = Get-Service -name "Sophos MCS Client" -ea SilentlyContinue
$Global:mcsagent = Get-Service -name "Sophos MCS Agent" -ea SilentlyContinue
}

# Sophos Central Installation
Start-Transcript c:\temp\SophosCentralInstallLog.txt
Write-Host "Starting the Sophos Central Installation based on the variables defined in the site"
Write-Host ""
Write-Host "Checking to see if Sophos is Already Installed"

Get-SophosInstalled
if ($installed -eq "True") {
	Write-Host "--Sophos Central Endpoint Agent Installed"
	if ($mcsclient.Status -eq "Running"){	
	Write-Host "--Sophos MCS Client is Running"
	Exit 0
	}
}
else {
	Write-Host "--Sophos Central is Not Installed"
	Write-Host "Sophos MCS Client is Not Running"
	}

# Check for the Site Variables
Write-Host ""
Write-Host "Checking the Variables"

if ($CustomerToken -eq $null)
	{Write-Host "--Customer Token Not Set or Missing"
    Stop-Transcript
	Exit 1}
else
	{Write-Host "--CustomerToken = "$CustomerToken""}

if ($Products -eq $null)
	{Write-Host "--Sophos Products Not Set or Missing"
	Stop-Transcript
	Exit 1}
else
	{Write-Host "--Products = "$Products""}

# Sophos parameters are defined from the site specific variables
$arguments = "--products=""" + $Products
$arguments = $arguments + """ --quiet"

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

$timeout = new-timespan -Minutes 30
$install = [diagnostics.stopwatch]::StartNew()
while ($install.elapsed -lt $timeout){
    if ((Get-Service "Sophos MCS Client" -ea SilentlyContinue)){
	Write-Host "Sophos MCS Client Found - Breaking the Loop"
	Break
	}
    start-sleep -seconds 60
}
Write-Host ""
Write-Host "Sophos Setup Completed"

# Verify that Sophos Central Endpoint Agent Installed
Write-Host ""
Write-Host "Verifying that Sophos Central Endpoint installed and is Running"

Get-SophosInstalled
if ($installed -eq "True") {
	Write-Host "--Sophos Central Endpoint Agent Installed Successfully"
	if ($mcsclient.Status -eq "Running"){
	Write-Host "--Sophos MCS Client is Running"
		if ($mcsagent.Status -eq "Running"){
		Write-Host "--Sophos MCS Agent is Running"
		Write-Host "Log Location - <system>\programdata\Sophos\Cloudinstaller\Logs\"
		Stop-Transcript
		Exit 0
		}
	}
}
else {
	Write-Host "--Sophos Central Install Failed"
	Write-Host ""
	Write-Host "Please check the Sophos Central Install Logs for more details"
	Write-Host ""
	Write-Host "Log Location - <system>\programdata\Sophos\Cloudinstaller\Logs\"
	Stop-Transcript
	Exit 1
	}