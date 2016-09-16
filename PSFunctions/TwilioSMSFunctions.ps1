function Get-IncomingSMSData ([object]$WebHookData){
    $RequestBody = $WebHookData.RequestBody
    $SMSData = @{}                                                                                                                                                                   
    $RequestBody -split "&" | % {$key,$value = $_ -split "="; $SMSData.Add($key,$value)}
    return New-Object -TypeName psobject -Property @{
        Body = $SMSData.Body
        FromNumber = $SMSData.From.replace("%2B","+")
    } 
}

function Send-SMS ([string]$SMSMessage, [string]$RecieverPhoneNumber){
    $TwilioAccountSid = Get-AutomationVariable -Name 'TwilioAccountSid'
    $TwilioAuthToken = Get-AutomationVariable -Name 'TwilioAuthToken'
    $TwilioPhoneNumber = Get-AutomationVariable -Name 'TwilioPhoneNumber'

    try {
        # Build URI with Account Sid
        $URI = "https://api.twilio.com/2010-04-01/Accounts/$TwilioAccountSid/SMS/Messages.json"
        # Build data to post
        $MessageData = "From=$TwilioPhoneNumber&To=$RecieverPhoneNumber&Body=$SMSMessage"
        # Build authorization for header
        $SecureAuthToken = ConvertTo-SecureString $TwilioAuthToken -AsPlainText -Force
        $AuthCredentials = New-Object System.Management.Automation.PSCredential($TwilioAccountSid,$SecureAuthToken) 

        $msg = Invoke-RestMethod -Uri $URI -Body $MessageData -Credential $AuthCredentials -Method "POST" -ContentType "application/x-www-form-urlencoded"

        return $true
    }
    catch {
        return $false
    }
}