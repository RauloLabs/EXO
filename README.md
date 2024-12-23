<p>==========================================================<br><strong>Disclaimer:</strong><br>This script is read-only and is designed to help collect information related to Exchange Online transport services. The use of this script does not guarantee any solution and is the sole responsibility of the person executing it.<br>==========================================================</p>

# Exchange Online Transport Collector

### How to use it?
Before using this procedure, it is recommended to verify and install the latest version of the Exchange Online module.
```powershell
Install-Module -Name ExchangeOnlineManagement -RequiredVersion 3.7.0
```
To see the current Module:
```powershell
Get-Module  -Name ExchangeOnlineManagement | fl
Get-installedModule exchangeonlinemanagement
```
More Information on: 

https://learn.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps
https://www.powershellgallery.com/packages/ExchangeOnlineManagement/3.7.0

### Download and use it:
The first step is connect to Exchange online, otherwise the scrip won't collect any data:
```powershell
connect-exchangeOnline
```
![image](https://github.com/user-attachments/assets/80b3d151-ee51-45eb-9a97-353c7eaadfc8)

Once connected to EXO PowerShell, the procedure exports all configuration information.

![image](https://github.com/user-attachments/assets/e9d6ad17-fbfb-4713-8e22-c49232488ef6)

![image](https://github.com/user-attachments/assets/76b801c6-81c1-422e-a118-b518246fc5f4)


