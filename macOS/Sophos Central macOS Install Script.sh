#!/bin/bash

# -----------------------------------------------------------------------------------------------
# Component: Sophos Central Installation
# Author: Stephen Weber
# Purpose: macOS Installation for Sophos Central Endpoints
# Version 1.0
# -----------------------------------------------------------------------------------------------

#Setup Variables

SophosCustToken="Customer Token Here"
	#Customer Token from CSV
SophosMgmtServer_macOS="macOS Mgmt Server Location Here"
	#macOS Mgmt Server Location from CSV
SophosEndpointSelection="antivirus intercept" 
	#Options:
		#Central Endpoint Protection: "antivirus"
		#Central Intercept X Advanced: "antivirus intercept"
		#Central Intercept X Adv with MTR: "antivirus intercept mdr"
SophosDeviceEncryption="false"
	#Options: true or false

#Setup Functions

SophosInstalled(){
if pgrep SophosMcsAgentD; then MCSstatus="Protected"; else MCSstatus="NotProtected"; fi

if pgrep SophosUpdater; then AUstatus="Protected"; else AUstatus="NotProtected"; fi

if open -Ra "Sophos Endpoint"; then Sophos="Installed"; else Sophos="NotInstalled"; fi
}

#Create Log Directory and setup STDOUT to /tmp/SophosCentral/ScriptLog.txt

[ ! -d "/tmp/SophosCentral" ] && mkdir /tmp/SophosCentral || echo "Directory Already Exists"

now=$(date +"%m_%d_%y_%T")

exec > /tmp/SophosCentral/ScriptLog_$now.txt

#Check for the Site Variables

echo ""
echo "Checking the Site Variables"
echo ""

if [ -z $SophosCustToken ]
	then
		echo "--Customer Token Not Set or Missing"
		exit 1
	else
		echo "--CustomerToken = "$SophosCustToken""
fi

if [ -z $SophosMgmtServer_macOS ]
	then
		echo "--Mgmt Server macOS Not Set or Missing"
		exit 1
	else
		echo "--SophosMgmtServer_macOS = "$SophosMgmtServer_macOS
fi

#Sophos Central Installed?

echo ""
echo "Checking to see if Sophos Central is Installed"
echo ""

SophosInstalled
if [ $Sophos = "Installed" ]
	then
		if [ $MCSstatus = "Protected" ]
			then
				if [ $AUstatus = "Protected" ]
					then
						echo "Sophos Central Installed"
						exit 0
					else
						echo "Sophos Central Installed: Auto Update Service Not Running"
						exit 1
				fi
			else
				echo "Sophos Central Installed: Sophos MCS Service Not Running"
				exit 1
		fi
	else
		echo "Installing Sophos Central"
fi

#Sophos Product Selection

[ $SophosDeviceEncryption = "true" ] && SophosProducts=$SophosEndpointSelection" deviceEncryption" || SophosProducts=$SophosEndpointSelection

# Sophos Command-Line Options

#[ $QuietInstall = "true" ] && SophosOptions=" --quiet" || SophosOptions=""

#Build the arguments for install

arguments="--customertoken "$SophosCustToken" --mgmtserver "$SophosMgmtServer_macOS" --products "$SophosProducts" --quiet"

# This Section starts the installer using the arguments defined above
echo ""
echo "SophosInstall "$arguments""
echo ""

#Unzip the SophosInstall.zip file

unzip SophosInstall.zip

#Change executable permissions

chmod a+x Sophos\ Installer.app/Contents/MacOS/Sophos\ Installer
chmod a+x Sophos\ Installer.app/Contents/MacOS/tools/com.sophos.bootstrap.helper

#Start Installation

./Sophos\ Installer.app/Contents/MacOs/Sophos\ Installer $arguments

#Sleep while waiting for the Installation to Complete

sleep 600

#Verify that Sophos Central Endpoint Agent Installed

echo ""
echo "Verifying that Sophos Central Endpoint installed and is Running"
echo ""

SophosInstalled

if [ $Sophos = "Installed" ]
	then
		if [ $MCSstatus = "Protected" ]
			then
				if [ $AUstatus = "Protected" ]
					then
						echo "Sophos Central Installed Successfully"
						exit 0
					else
						echo "Sophos Central Installed: Auto Update Service Not Running"
						exit 1
				fi
			else
				echo "Sophos Central Installed: Sophos MCS Service Not Running"
				exit 1
		fi
	else
		echo "Sophos Central Installation Failed"
fi
