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
    $RequestBody = ConvertFrom-json $WebHookData.RequestBody
    $null,$user = $RequestBody.SearchResult.value.Account.Split("\")
    return $user
}