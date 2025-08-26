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

# Define your internal domains
#$internalDomains = @("contoso.com", "rnmst1.com")

# Prompt user to enter internal domains manually
Write-Host "##########################################################################"
$domainInput = Read-Host "Enter your internal domains separated by commas (e.g., contoso.com,test.com)"

# Line 2: Loop until a valid domain is entered
while ([string]::IsNullOrWhiteSpace($domainInput)) {
    Write-Host "Warning"-ForegroundColor Yellow
    $domainInput = Read-Host "Warning: Please enter a domain" 
}


$internalDomains = $domainInput.Split(",") | ForEach-Object { $_.Trim() }

# Display the domains for confirmation
Write-Host "Internal domains set to: $($internalDomains -join ', ')" -ForegroundColor Green


# Get today's date and the date from 7 days ago
$endDate = Get-Date
$startDate = $endDate.AddDays(-7)

# Fetch message traces
$traces = Get-MessageTraceV2 -StartDate $startDate -EndDate $endDate

# Filter for Receive events from external senders
$externalReceives = $traces | Where-Object {
    $_.status -eq "Delivered" -and
    ($internalDomains -notcontains ($_.SenderAddress.Split("@")[-1]))
}

# Output results
Write-Host "###################################################################"
Write-Host "Trafic to review "
$externalReceives | ft SenderAddress, RecipientAddress, Subject, Received, MessageId -AutoSize # | Export-Csv -Path "ExternalReceives.csv" -NoTypeInformation
#$externalReceives | ft *id*,recipie*

#Write-Host "Exported external receive events to ExternalReceives.csv"



###############################################################################################
# Loop through each external receive message
#$details = Get-MessageTraceDetailV2 -MessageTraceId "8b6332cc-730f-4663-c9fd-08dde485d20d" -RecipientAddress exouser11@MngEnvMCAP689794.mail.onmicrosoft.com
#$details = get-messagetracev2 -MessageId "0644f024-7ef8-4336-aeff-4aaa3af6c9b2@BN0P221MB0605.NAMP221.PROD.OUTLOOK.COM" -StartDate $startDate -EndDate $endDate | Get-MessageTraceDetailV2

foreach ($msg in $externalReceives) {
    # Get detailed trace for the message
    $details = Get-MessageTraceDetailV2 -MessageTraceId $msg.MessageTraceId -RecipientAddress $msg.RecipientAddress
       
    # Filter for Receive events
    $receiveEvents = $details | Where-Object { $_.Event -eq "Receive" }
   
    $data = $receiveEvents.data
    foreach ($event in $receiveEvents) {
         Write-Host "###################################################################"
        Write-Host "Analizzando TraceId: $($msg.MessageId) - Sender: $($msg.SenderAddress)"
        if ($data -like "*TLS*") {
            Write-Host "TLS is present for MessageId $($msg.MessageId)" -ForegroundColor Green
            Write-Host "Sender $($msg.SenderAddress)" 
            #Write-Host $data
            $receiveEvents | Export-Csv ".\TLSLogPresent_$((Get-Date).ToString('yyyy-MM-dd')).csv" -Append 
        } else {
            Write-Host "TLS not present for MessageId $($msg.MessageId)" -ForegroundColor Yellow
             Write-Host "TLS is present for MessageId $($msg.MessageId)" -ForegroundColor Green
            Write-Host "Sender $($msg.SenderAddress)" 
            #Write-Host $data
            $receiveEvents | Export-Csv ".\TLSLogTocheck_$((Get-Date).ToString('yyyy-MM-dd')).csv" -Append 
        }
     Write-Host "###################################################################"   
    }
}





########################################################################################################
