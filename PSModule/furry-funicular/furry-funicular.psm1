<# 
 .Synopsis
  Displays a visual representation of a calendar.

 .Description
  Displays a visual representation of a calendar. This function supports multiple months
  and lets you highlight specific date ranges or days.
#>

#region ADFunctions.ps1
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
#endregion ADFunctions.ps1

#region SQLFunctions.ps1
function Create-ResetPasswordDBEntry ([string]$MobilePhoneNumber, [string]$UserName) {
    $SQLConnectionString = Get-AutomationVariable -Name 'SQLConnectionString'
    $DatabaseName = Get-AutomationVariable -Name 'DatabaseName'
    try {
        $SQLQuery = "INSERT INTO $DatabaseName (MobilePhoneNumber,Status,CreationTime,LastStepTime,UserName) VALUES ('$MobilePhoneNumber','1',GETDATE(),GETDATE(),'$UserName')"
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = $SQLConnectionString
        $SQLConnection.Open()
        $SQLCommand = $SQLConnection.CreateCommand()
        $SQLCommand.CommandText = $SQLQuery
        $SQLResult = $SQLCommand.ExecuteReader()
        $SQLResultTable = New-Object System.Data.DataTable
        $SQLResultTable.Load($SQLResult)
        $SQLConnection.Close()
        return $true
    }
    catch {
        return $false
    }
    finally {
        $SQLConnection.Close()
    }
}
function Check-ResetPasswordDBEntry ([string]$MobilePhoneNumber, [int]$Status) {
    $SQLConnectionString = Get-AutomationVariable -Name 'SQLConnectionString'
    $DatabaseName = Get-AutomationVariable -Name 'DatabaseName'                                    
    try {
        $SQLQuery = "SELECT * FROM $DatabaseName WHERE MobilePhoneNumber = '$MobilePhoneNumber' AND Status = '$Status'"
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = $SQLConnectionString
        $SQLConnection.Open()
        $SQLCommand = $SQLConnection.CreateCommand()
        $SQLCommand.CommandText = $SQLQuery
        $SQLResult = $SQLCommand.ExecuteReader()
        $SQLResultTable = New-Object System.Data.DataTable
        $SQLResultTable.Load($SQLResult)
        $SQLConnection.Close()
        if ($SQLResultTable -eq $null)
        {
            return $false
        }
        else {
            return $true
        }
    }                                     
    catch {
        return $false
    }
    finally {
        $SQLConnection.Close()
    }
}
function Update-ResetPasswordDBEntry ([string]$MobilePhoneNumber, [int]$Status) {
    $SQLConnectionString = Get-AutomationVariable -Name 'SQLConnectionString'
    $DatabaseName = Get-AutomationVariable -Name 'DatabaseName'
    try {
        $SQLQuery = "UPDATE $DatabaseName (Status,LastStepTime) VALUES ('$Status',GETDATE()) WHERE MobilePhoneNumber = '$MobilePhoneNumber'"
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = $SQLConnectionString
        $SQLConnection.Open()
        $SQLCommand = $SQLConnection.CreateCommand()
        $SQLCommand.CommandText = $SQLQuery
        $SQLResult = $SQLCommand.ExecuteReader()
        $SQLResultTable = New-Object System.Data.DataTable
        $SQLResultTable.Load($SQLResult)
        $SQLConnection.Close()
        return $true
    }
    catch {
        return $false
    }
    finally {
        $SQLConnection.Close()
    }
}
function Delete-ResetPasswordDBEntry ([string]$MobilePhoneNumber) {
    $SQLConnectionString = Get-AutomationVariable -Name 'SQLConnectionString'
    $DatabaseName = Get-AutomationVariable -Name 'DatabaseName'
    try {
        $SQLQuery = "DELETE FROM $DatabaseName WHERE MobilePhoneNumber = '$MobilePhoneNumber'"
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = $SQLConnectionString
        $SQLConnection.Open()
        $SQLCommand = $SQLConnection.CreateCommand()
        $SQLCommand.CommandText = $SQLQuery
        $SQLResult = $SQLCommand.ExecuteReader()
        $SQLResultTable = New-Object System.Data.DataTable
        $SQLResultTable.Load($SQLResult)
        $SQLConnection.Close()
        return $true
    }
    catch {
        return $false
    }
    finally {
        $SQLConnection.Close()
    }
}
function Get-UserNameByPhoneNumber ([string]$MobilePhoneNumber) {
    $SQLConnectionString = Get-AutomationVariable -Name 'SQLConnectionString'
    $DatabaseName = Get-AutomationVariable -Name 'DatabaseName'
    try {
        $SQLQuery = "SELECT * FROM $DatabaseName WHERE MobilePhoneNumber = '$MobilePhoneNumber'"
        $SQLConnection = New-Object System.Data.SqlClient.SqlConnection
        $SQLConnection.ConnectionString = $SQLConnectionString
        $SQLConnection.Open()
        $SQLCommand = $SQLConnection.CreateCommand()
        $SQLCommand.CommandText = $SQLQuery
        $SQLResult = $SQLCommand.ExecuteReader()
        $SQLResultTable = New-Object System.Data.DataTable
        $SQLResultTable.Load($SQLResult)
        $SQLConnection.Close()
        return $SQLResultTable.UserName
    }
    catch {
        return $null
    }
    finally {
        $SQLConnection.Close()
    }
}
#endregion SQLFunctions.ps1

#region SupportFunctions.ps1
function Generate-RandomPassword([int]$PasswordLenght = 15){
    $var = 1..$PasswordLenght | % {Get-Random -Minimum 33 -Maximum 122}
    $str = ""
    $var | % {$str += [char]$_}
    $cred = ConvertTo-SecureString -String $str -AsPlainText -Force
    return New-Object -TypeName psobject -Property @{
        SecureString = $cred
        PlainText = $str
    }
}
function Get-UserNameFromOMSAlert ([object]$WebHookData){
    $RequestBody = ConvertFrom-json $WebHookDataJ.RequestBody
    $null,$UserName,$null,$null = $RequestBody.SearchResult.value.Account.Split("\")
    return $UserName
}
#endregion SupportFunctions.ps1

#region TwilioSMSFunctions.ps1
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
        $URI = "https://api.twilio.com/2010-04-01/Accounts/$TwilioAccountSid/SMS/Messages.json"
        $MessageData = "From=$TwilioPhoneNumber&To=$RecieverPhoneNumber&Body=$SMSMessage"
        $SecureAuthToken = ConvertTo-SecureString $TwilioAuthToken -AsPlainText -Force
        $AuthCredentials = New-Object System.Management.Automation.PSCredential($TwilioAccountSid,$SecureAuthToken) 
        Invoke-RestMethod -Uri $URI -Body $MessageData -Credential $AuthCredentials -Method "POST" -ContentType "application/x-www-form-urlencoded"
        return $true
    }
    catch {
        return $false
    }
}
#endregion TwilioSMSFunctions.ps1