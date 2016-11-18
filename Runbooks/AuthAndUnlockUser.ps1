<#
    .SYNOPSIS
    

    .DESCRIPTION


    .NOTES


    .LINK 
    https://github.com/Tritze/furry-funicular
#>

param(
    [object]$WebhookData
)

Import-Module furry-funicular.psm1 -Force

if ($WebhookData -ne $null){
    $SMSData = Get-IncomingSMSData -WebHookData $WebHookData
    $UserName = Get-UserNameByPhoneNumber -MobilePhoneNumber $SMSData.FromNumber
    $UserData = Get-UserData -UserName $UserName
    if ($UserName -ne $null) {  
        If (Check-ResetPasswordDBEntry -MobilePhoneNumber $SMSData.FromNumber -Status 1){
            If ($SMSData.Body.ToUpper() -eq "OPEN"){
                If (Update-ResetPasswordDBEntry -MobilePhoneNumber $SMSData.FromNumber -Status 2){
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
        elseif (Check-ResetPasswordDBEntry -MobilePhoneNumber $SMSData.FromNumber -Status 2) {
            if ($UserData.Office.ToUpper() -eq $SMSData.Body.ToUpper()) {
                $password = Generate-RandomPassword(15)
                Set-UserPW -SecureStringPW $password.SecureString -UserName $UserName
                Send-SMS -SMSMessage ("Your account has been unlocked. Use '" + $password.PlainText + "' to log in and change your password.") -RecieverPhoneNumber $UserData.MobilePhoneNumber
                Delete-ResetPasswordDBEntry -MobilePhoneNumber $UserData.MobilePhoneNumber
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