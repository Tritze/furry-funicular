function Get-UserData([string]$UserName){
    $ADAdminUserName      = Get-AutomationVariable -Name 'ADAdminUserName'
    $ADAdminUserPassword  = Get-AutomationVariable -Name 'ADAdminUserPassword'
    $pass = ConvertTo-SecureString -String $ADAdminUserPassword -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($ADAdminUserName, $pass)
    $user = Get-ADUser -Identity $UserName -Properties mobile,office -Credential $cred
    return New-Object -TypeName psobject -Property @{
        Office = $user.office
        MobilePhoneNumber = $user.mobile
    }
}

function Set-UserPW ([string]$SecureStringPW, [string]$UserName) {
    $ADAdminUserName      = Get-AutomationVariable -Name 'ADAdminUserName'
    $ADAdminUserPassword  = Get-AutomationVariable -Name 'ADAdminUserPassword'
    $pass = ConvertTo-SecureString -String $ADAdminUserPassword -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ($ADAdminUserName, $pass)
    Set-ADAccountPassword -Identity $UserName -NewPassword $SecureStringPW -Credential $cred 
    Set-ADUser -Identity $UserName -ChangePasswordAtLogon $true -Credential $cred
    Unlock-ADAccount -Identity $UserName -Credential $cred
}