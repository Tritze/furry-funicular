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
    $LockedUserName = Get-UserNameFromOMSAlert($WebhookData)
    $LockedUserData = Get-UserData($LockedUserName)
    If ($LockedUserData.MobilePhoneNumber -ne $null){
        If ($LockedUserData.Office -ne $null){
            If (Create-ResetPasswordDBEntry ($LockedUserData.MobilePhoneNumber, $LockedUserName)){
                If (Send-SMS ("Your account has been locked out. Reply with UNLOCK to unlock your account.", $LockedUserData.MobilePhoneNumber)){
                    Write-Host "DB entry created and SMS send to user."
                }
                else {
                    Write-Error "SMS send was not possible."
                }
            }
            else {
                Write-Error "Create DB entry not possible."
            }
        }
        else {
            Write-Error "User has no assigned office."
        }
    }
    else {
        Write-Error "User has no assigned mobile phone number."
    }
}