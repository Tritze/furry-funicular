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
    $LockedUserName = Get-UserNameFromOMSAlert -WebHookData $WebhookData
    $LockedUserData = Get-UserData -UserName $LockedUserName
    If ($LockedUserData.MobilePhoneNumber -ne $null){
        If ($LockedUserData.Office -ne $null){
            If (Create-ResetPasswordDBEntry -MobilePhoneNumber $LockedUserData.MobilePhoneNumber -UserName $LockedUserName){
                If (Send-SMS -SMSMessage "Account locked. Reply OPEN to unlock." -RecieverPhoneNumber $LockedUserData.MobilePhoneNumber){
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