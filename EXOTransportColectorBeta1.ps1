#=================================
# By Raul N, Microsoft Ltd. 2025. Use at your own risk.  No warranties are given.
#
#  DISCLAIMER:
# THIS CODE IS SAMPLE CODE. THESE SAMPLES ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND.
# MICROSOFT FURTHER DISCLAIMS ALL IMPLIED WARRANTIES INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR OF FITNESS FOR
# A PARTICULAR PURPOSE. THE ENTIRE RISK ARISING OUT OF THE USE OR PERFORMANCE OF THE SAMPLES REMAINS WITH YOU. IN NO EVENT SHALL
# MICROSOFT OR ITS SUPPLIERS BE LIABLE FOR ANY DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF BUSINESS PROFITS,
# BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, OR OTHER PECUNIARY LOSS) ARISING OUT OF THE USE OF OR INABILITY TO USE THE
# SAMPLES, EVEN IF MICROSOFT HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. BECAUSE SOME STATES DO NOT ALLOW THE EXCLUSION OR LIMITATION
# OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, THE ABOVE LIMITATION MAY NOT APPLY TO YOU.

#Colectot
#DO NOT MODIFY ANY OF THE COMMANDS BELOW
Write-Host "==========================================" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Wellcome to EXO transport collector" -ForegroundColor Green
# Disclaimer
Write-Host "=========================================" -ForegroundColor Green
Write-Host "IMPORTANT NOTICE" 
Write-Host "=========================================" -ForegroundColor Green
Write-Host "This procedure is classified as 'Red only'." -ForegroundColor Green
Write-Host "It will not make any changes to the system." -ForegroundColor Green
Write-Host "It is designed solely to collect information" -ForegroundColor Green
Write-Host "regarding EXO transport services." -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
# Prompt the user to press a button to continue
Write-Host "Press any key to continue..."  -ForegroundColor red
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#=================================
# Check if the current session is connected to Exchange Online
$session = Get-ConnectionInformation | Where-Object { $_.Name -like '*Exchange*' -and $_.TokenStatus -eq 'Active' } 
if ($session -eq $null) {
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Please connect to Exchange Online first." -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Green
    exit
} else {
    Write-Host "Connected to Exchange Online."
    # Continue with the rest of your script here
}
#=================================
#Define folder and collect data
$Folder = "$env:temp\MSDataCollection"
New-Item -Path $folder -ItemType Directory -erroraction silentlycontinue|out-null
Set-Location $folder
Get-AcceptedDomain | Export-Clixml Cloud_AcceptedDomains.xml
Get-OutboundConnector | Export-Clixml Cloud_OutboundConnectors.xml
Get-InboundConnector|Export-Clixml Cloud_InboundConnectors.xml
Get-RemoteDomain | Export-Clixml Cloud_RemoteDomains.xml
Get-TransportConfig | Export-Clixml Cloud_TransportConfig.xml
Get-TransportRule | Export-Clixml Cloud_ETR.xml
Get-OrganizationConfig | Export-Clixml Cloud_OrganizationConfig.xml
Invoke-item $Folder
#=================================
#Inport data Into Variables
$delim = "=" * 80
$CloudAcceptedDomain = Import-CLIXml Cloud_AcceptedDomains.xml
$OutboundConnectors = Import-CLIXml Cloud_OutboundConnectors.xml
$InboundConnectors = Import-CLIXml Cloud_InboundConnectors.xml
$CloudRemoteDomains = Import-CLIXml Cloud_RemoteDomains.xml
$CloudTransportConfig = Import-CLIXml Cloud_TransportConfig.xml
$CloudETR = Import-CLIXml Cloud_ETR.xml
$CloudOrganizationConfig = Import-CLIXml Cloud_OrganizationConfig.xml
$ts =Get-Date -Format yyyyMMdd_hhmmss
$FilePath = ".\Output$ts.txt"
#$Space = "=========================================================================" 

#================================================================================
#Outbound Connectors
#Quick view
    Write-Host "$delim`nOutbound Connectors `n$delim"
    $OutboundConnectors | Format-Table -AutoSize
    #Write log
    "$delim`nOutbound Connectors `n$delim"  | Out-File -FilePath $FilePath -Append
    $OutboundConnectors | Format-Table -AutoSize | Out-File -FilePath $FilePath -Append
#Advanced view
    foreach ($Conn in ($OutboundConnectors |Sort-Object Name)) {
        $OutputOutConnectorName = "$delim`nOutbound Connector Name: $($Conn.Name)`n$delim"
        Write-Output $OutputOutConnectorName
        $OutputOutConnectorName | Out-File -FilePath $FilePath -Append
        $OutputOutConnectorDetails = ($Conn| Format-List Enabled, ConnectorType, RecipientDomains, AllAcceptedDomains, SmartHosts, UseMXRecord, CloudServicesMailEnabled, TLSDomain, TLSSettings, RequireTLS, IsTransportRuleScoped, WhenCreatedUTC, WhenChangedUTC | out-string )
        Write-Output $OutputOutConnectorDetails
        $OutputOutConnectorDetails | Out-File -FilePath $FilePath -Append
    }

    #check CMT enable
    if ($OutboundConnectors | Where-Object {$_.RouteAllMessagesViaOnPremises -eq $true}) {
        #Warn about Centralized Mail Transport
        $warmCMT = "Centralized Mail Transport (CMT) is currently enabled" 
        Write-Warning $warmCMT
        $warmCMT | Out-File -FilePath $FilePath -Append
    }

    #check RecipientDomains is missing
    if ($OutboundConnectors | Where-Object {$_.RecipientDomains -eq $null -and $_.IsTransportRuleScoped -eq $false}) {
        #Warn about Missing RecipientDomains
        $warmCMT = "RecipientDomains is missing, please check if all doamis hybrid domaisn are included on some connector" 
        Write-Warning $warmCMT
        $warmCMT | Out-File -FilePath $FilePath -Append
    }

#================================
#Inbound Connectors
#quick view
    Write-Host "$delim`nInbound Connectors Preview `n$delim"
    $InboundConnectors | Format-Table -AutoSize
    "$delim`nIntbound Connectors `n$delim"  | Out-File -FilePath $FilePath -Append
    $InboundConnectors | Format-Table -AutoSize | Out-File -FilePath $FilePath -Append
#Advanced view
<#foreach ($Connin in ($InboundConnectors |Sort-Object Name)) {
    $InputOutConnectorName = "$delim`nInbound Connector Name: $($Conn.Name)`n$delim"
    Write-Output $InputOutConnectorName 
    $delim | Out-File -FilePath $FilePath -Append
    $InputOutConnectorDetails = ($ConnIn| Format-List Enabled, ConnectorType, TlsSenderCertificateName, ConnectorSource, SenderDomains, RequireTls, WhenChangedUTC, Guid, SenderIPAddresses    | out-string )
    Write-Output $InputOutConnectorDetails
    $delim | Out-File -FilePath $FilePath -Append
}
#>    
#IP Based
    foreach ($Connin in ($InboundConnectors | Where-Object {$_.SenderIPAddresses -ne $null}|Sort-Object Name)) {
        Write-Output "$delim`nInbound Connector Name (IP Based): $($Conn.Name)`n$delim"
        Write-Output ($Conn|Format-List Enabled, ConnectorType, CloudServicesMailEnabled, TreatMessagesAsInternal, RequireTLS, SenderDomains, AssociatedAcceptedDomains, SenderIPAddresses, RestrictDomainsToIPAddresses, WhenCreatedUTC, WhenChangedUTC|out-string)
        $InbounconMame = "$delim`nInbound Connector Name (IP Based): $($Conn.Name)`n$delim"
        $Inbounconconf = ($Conn|Format-List Enabled, ConnectorType, CloudServicesMailEnabled, TreatMessagesAsInternal, RequireTLS, SenderDomains, AssociatedAcceptedDomains, SenderIPAddresses, RestrictDomainsToIPAddresses, WhenCreatedUTC, WhenChangedUTC|out-string)
        $InbounconMame | Out-File -FilePath $FilePath -Append
        $Inbounconconf | Out-File -FilePath $FilePath -Append
    }


#Certificate Based
    foreach ($Connin in ($InboundConnectors | Where-Object {$_.TlsSenderCertificateName -ne $null}|Sort-Object Name)) {
        Write-Output "$delim`nInbound Connector Name (Certificate Based): $($Conn.Name)`n$delim"
        Write-Output ($Conn|Format-List Enabled, ConnectorType, CloudServicesMailEnabled, TreatMessagesAsInternal, RequireTLS, SenderDomains, AssociatedAcceptedDomains, TlsSenderCertificateName, RestrictDomainsCertificates, WhenCreatedUTC, WhenChangedUTC|out-string)
        $InbounconMame = "$delim`nInbound Connector Name (IP Based): $($Conn.Name)`n$delim"
        $Inbounconconf = ($Conn|Format-List Enabled, ConnectorType, CloudServicesMailEnabled, TreatMessagesAsInternal, RequireTLS, SenderDomains, AssociatedAcceptedDomains, SenderIPAddresses, RestrictDomainsToIPAddresses, WhenCreatedUTC, WhenChangedUTC|out-string)
        $InbounconMame | Out-File -FilePath $FilePath -Append
        $Inbounconconf | Out-File -FilePath $FilePath -Append
    }

#================================
#Remote domains
    Write-Host "$delim`nRemote Domains Info. `n$delim"
    Write-Output $CloudRemoteDomains | Format-Table Name,DomainName,AllowedOOFType,TNEFEnabled,IsInternal,ByteEncoderTypeFor7BitCharsets -AutoSize
    "$delim`nRemote Domains Info.. `n$delim" | Out-File -FilePath $FilePath -Append
    $CloudRemoteDomains | Format-Table Name,DomainName,AllowedOOFType,TNEFEnabled,IsInternal,ByteEncoderTypeFor7BitCharsets -AutoSize | Out-File -FilePath $FilePath -Append
#================================
#Accepted domains
    Write-Host "$delim`nAccepted Domains Info. `n$delim"
    Write-Output $CloudAcceptedDomain | Format-Table Name,DomainName,DomainType,Default,WhenChanged -AutoSize
    "$delim`nAccepted Domains Info. `n$delim" | Out-File -FilePath $FilePath -Append
    $CloudAcceptedDomain | Format-Table Name,DomainName,DomainType,Default,WhenChanged -AutoSize | Out-File -FilePath $FilePath -Append
#================================
#Cloud ETR
    Write-Host "$delim`nETR Info. (for more details see ETRReport.csv) `n$delim"
    "$delim`nETR Info. (for more details see ETRReport.csv) `n$delim"  | Out-File -FilePath $FilePath -Append
    $CloudETR | Format-Table -AutoSize
    $CloudETR | Out-File -FilePath $FilePath -Append
    $CloudETR | Export-Csv .\ETRReport.csv

#================================
#Transport Config:
Write-Host "$delim`nTransport Config. `n$delim"
$CloudTransportConfig | Format-Table *size*,*TLS*
#================================
#Oganization Config:
    #check about SendFromAliasEnabled
    if ($CloudOrganizationConfig | Where-Object {$_.SendFromAliasEnabled -ne $False}) {
        #Warn about SendFromAliasEnabled
        $warmCMT = "Send From Alias is Enabled, please check: https://techcommunity.microsoft.com/blog/exchange/sending-from-email-aliases-%e2%80%93-public-preview/3070501" 
        Write-Warning $warmCMT
        $warmCMT | Out-File -FilePath $FilePath -Append
    }
    #check Message reacal is enabled
    if ($CloudOrganizationConfig | Where-Object {$_.MessageRecallEnabled -ne $Null}) {
        #Warn about MessageRecallEnabled
        $warmCMT = "MessageRecallEnabled doesn't have a defaul setting, please check: https://techcommunity.microsoft.com/blog/exchange/cloud-based-message-recall-in-exchange-online/3744714" 
        Write-Warning $warmCMT
        $warmCMT | Out-File -FilePath $FilePath -Append
    }


#================================
#Output file
    write-host "All infomation coledted was saved on:" $Folder -BackgroundColor Yellow -ForegroundColor Black