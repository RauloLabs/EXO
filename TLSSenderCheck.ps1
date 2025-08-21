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


# Definizione dell'intervallo di tempo
$startDate = (Get-Date).AddDays(-10)
$endDate = Get-Date

# Esegui il Message Trace
$traceResults = Get-MessageTrace -StartDate $startDate -EndDate $endDate

# Filtra solo i messaggi esterni (mittente o destinatario non nel dominio interno)
$externalDomain = "@test.com"  #Add your domain here
$externalMessages = $traceResults | Where-Object {
    ($_.SenderAddress -notlike "*$externalDomain") -or
    ($_.RecipientAddress -notlike "*$externalDomain")
}

# Visualizza i risultati
Write-Host "####################################################################"
Write-Host "External senders"
$externalMessages | Select-Object Received, SenderAddress, RecipientAddress, Subject, Status | Format-Table -AutoSize
Write-Host "####################################################################"

# Ciclo su ogni messaggio esterno
foreach ($msg in $externalMessages) {
    Write-Host "Analizzando TraceId: $($msg.MessageId) - Sender: $($msg.SenderAddress)"

    $details = Get-MessageTraceDetailV2 -MessageTraceId $msg.MessageTraceId -RecipientAddress $msg.RecipientAddress

    $filteredDetails = $details | Where-Object {
        $_.Event -like 'Receive' -and
        $_.Data -notmatch 'SP_PROT_TLS1_1_SERVER' -and
        $_.Data -notmatch 'SP_PROT_TLS1_2_SERVER' -and
        $_.Data -notmatch 'SP_PROT_TLS1_3_SERVER'
    }
    
    
    if ($filteredDetails -ne $null) {
        Write-Host "======================================"
        Write-Host "WARNING: Messaggio ricevuto senza TLS 1.1/1.2/1.3" -ForegroundColor Yellow
        $filteredDetails | Select-Object Timestamp, Event, MessageId, Data | FL
        Write-Host "======================================"
        $filteredDetails | Export-Csv ".\TLSLog_$((Get-Date).ToString('yyyy-MM-dd')).csv" -Append 
    }

    
    # Visualizza i risultati filtrati
    #Write-Host "####################################################################"
     #   $filteredDetails | Select-Object Timestamp, Event, Data | Fl
    #Write-Host "####################################################################"

}
