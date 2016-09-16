<#
    .SYNOPSIS
    

    .DESCRIPTION


    .NOTES


    .LINK 
    https://github.com/Tritze/furry-funicular
#>

#region includes
. ../PSFunctions/ADFunctions.ps1
. ../PSFunctions/SQLFunctions.ps1
. ../PSFunctions/SupportFunctions.ps1
. ../PSFunctions/TwilioSMSFunctions.ps1
#endregion includes


param(
    [object]$WebhookData
)

# Check if runbook was started by webhook
if ($WebhookData -ne $null){
    $SMSData = Get-IncomingSMSData ($WebHookData)
    $UserName = Get-UserNameByPhoneNumber($SMSData.FromNumber)
    $UserData = Get-UserData($UserName)
    if ($UserName -ne $null) {  
        If (Check-ResetPasswordDBEntry ($SMSData.FromNumber , 1)){
            If ($SMSData.Body.ToUpper() -eq "OPEN"){
                If (Update-ResetPasswordDBEntry ($SMSData.FromNumber, 2)){
                    Send-SMS ("Reply with the location of your office (e.g. Stuttgart) to unlock your account.", $UserData.MobilePhoneNumber)
                }
                else {
                    Write-Error "Reset DB entry could not be updated."
                }
            }
            else {
                Send-SMS ("Password reset aborted! Reply with OPEN to reset password.", $SMSData.FromNumber)
                #Write-Error "User doesn't send OPEN."
            }
        }
        elseif (Check-ResetPasswordDBEntry ($SMSData.FromNumber, 2)) {
            if ($UserData.Office.ToUpper() -eq $SMSData.Body.ToUpper()) {
                $password = Generate-RandomPassword(15)
                Set-UserPW ($password.SecureString, $UserName)
                Send-SMS ("Your account has been unlocked. Use \'$password.PlainText\' to log in and change your password.", $UserData.MobilePhoneNumber)
                Delete-ResetPasswordDBEntry ($UserData.MobilePhoneNumber)
            }
            else {
                Send-SMS ("Password reset aborted! Reply with OPEN to reset password.", $SMSData.FromNumber)
                #Write-Error "User could not be authenticated by his office."
            }
        }
        else {
            Write-Error "Reset DB entry for this mobile phone number not found."
        }
    }
    else {
        Write-Error "UserName not found."
    }
}