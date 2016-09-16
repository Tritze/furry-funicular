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