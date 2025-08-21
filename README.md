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

### How to import all information collected and work with it:
The collector repository will contain a txt file with the execution date and many xml file with current configuration, you can import those to a variable an make different PS queries:
```powershell
$VarETR = Import-Clixml .\Cloud_ETR.xml
```
To view the information you have many options, bellow some examples:
```powershell
$VarETR | Sort-Object Name -Descending | ft 
$VarETR | Where-Object {$_.State -like '*Enabled*'} | ft
```
![image](https://github.com/user-attachments/assets/2bdd18a5-5ff3-45ef-8711-72dc7e105efc)


# TLS not present
This script (TLSSenderCheck.ps1) help to evidence sender that doesn't use TLS in EXo with Oportunistic TLS, based on (to enter in deep details):  
https://learn.microsoft.com/en-us/exchange/monitoring/mail-flow-reports/mfr-inbound-messages-and-outbound-messages-reports

Before to start, rename with your domain this line:
Line 22>>>>> $externalDomain = "@yourdomain.com"  #Add your domain here

If the script finds some user will be inform with this following message waring and sale a log on current execution folder (TLSLog_2025-08-21.csv)

<img width="807" height="273" alt="image" src="https://github.com/user-attachments/assets/f0cbf9e3-9b60-4af5-a1b6-d40a2a53d217" />




