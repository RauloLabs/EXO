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

=======================================================================

# TLS not present
This script (TLSSenderCheckV2.ps1) help to evidence sender that doesn't use TLS in EXO with Opportunistic TLS, based on (to enter in deep details):  
> https://learn.microsoft.com/en-us/exchange/monitoring/mail-flow-reports/mfr-inbound-messages-and-outbound-messages-reports

> ⚠️ **Warning:** The information will search on the last 7 days.

<img width="802" height="270" alt="image" src="https://github.com/user-attachments/assets/c8da42be-f440-4060-8a84-d66763c021f7" />

### How to ue this script?

1.Download the script (TLSSenderCheckV2.ps1). 

<img width="1051" height="119" alt="image" src="https://github.com/user-attachments/assets/6b3453f3-7983-4d88-97d0-a5c2030d1c12" />

2.Connect to exchange Online using PowerShell (Admin user or Transport Role able to run Get-messagetracev2):
```powershell
Connect-ExchangeOnline -UserPrincipalName chris@contoso.com
```
3.Execute the script: Before starting, enter your tenants domain/s (accepted domains) after execute it to ignore internal emails:

<img width="565" height="108" alt="image" src="https://github.com/user-attachments/assets/80c6dba8-680a-4ce4-b9f5-916da20a5cec" />

If the script finds some user will be informed with this following message waring (In Yellow) and sale a log on current execution folder (TLSLogX_//Date//.csv)

<img width="861" height="85" alt="image" src="https://github.com/user-attachments/assets/823ed0e4-1aa7-483d-bea2-80072f515681" />

### Exampled:

<img width="985" height="352" alt="image" src="https://github.com/user-attachments/assets/82ecf619-e852-4613-bc73-ae0c5936cdf2" />






