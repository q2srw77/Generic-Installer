# Generic-Installer
<b>Sophos Central Deployment Scripts for Windows and macOS</b>

These scripts designed for Partner use and require access to the Customer Token and Management Server available from the Sophos Central Partner Dashboard

<b>Windows</b>

The Windows Script only requires the Customer Token and will automatically download the SophosSetup.exe from Central.
```
Example:
-  #Setup Customer Variables;
-  #CustomerToken - Example - "Customer Token Here"
-  #Products - Example - "antivirus,intercept"
-  $Global:CustomerToken = 
-  $Global:Products = 
```
```
Products:
  Central Intercept X Essentials - antivirus,intercept
  Central Intercept X Advanced - antivirus,intercept
  Central Intercept X Advanced with MTR - antivirus,intercept,mdr
  Adding DeviceEncryption - products,deviceEncryption
```
<b>macOS</b>

The macOS Script will require the Customer Token, Management Server and SophosInstall file for macOS downloaded manually.
```
Example:
  SophosCustToken="Customer Token Here"
    #Customer Token from CSV
  SophosMgmtServer_macOS="macOS Mgmt Server Location Here"
    #macOS Mgmt Server Location from CSV
  SophosEndpointSelection="antivirus intercept" 
```
```
Options:
  #Central Intercept X Essentials: "antivirus intercept"
  #Central Intercept X Advanced: "antivirus intercept"
  #Central Intercept X Adv with MTR: "antivirus intercept mdr"
```
```
Additional Product:
  SophosDeviceEncryption="false"
  #Options: true or false
```
These scripts are not supported by Sophos Support.
