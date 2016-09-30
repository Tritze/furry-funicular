# furry-funicular

*This project is part of a blog-post-series on https://blog.tritze.eu*

**!Attention - This is a not tested pre-version!**

## What it is

furry-funicular is a set of PowerShell scripts that must be implemented as Azure Automation Runbooks,
to have, combined with Microsoft Operations Management Suite, a solution that does an automated password
recovery for user accounts. This is done with a simple SMS system. 

## How it works

1. User A has forgotten his password.
2. User A's account has been locked out.
3. OMS analyses the server logs.
4. Bases on the logs, OMS triggers a OMS Alert for the locked-out account of User A.
5. The Alert triggers a WebHook from a Azure Automation Runbook.
    1. The Runbook gets the mobile phone number of the user.
    2. The Runbook creates an entry in a SQL database.
    3. The Runbook sends an SMS to User A's mobile phone.
6. User A gets an SMS with information that his account is locked-out.
    1. The user can now reply, by SMS, with "UNLOCK" to start the unlock process.
7. The SMS reply triggers a second Runbook.
    1. The Runbooks controls if there is any entry in the database.
    2. If an entry exists, the Runbook gets the location information of the User from the Active Directory.
    3. The Runbook sends a second SMS to the User's mobile phone, with the question where he is located.
8. The User receives the SMS and replies with his location. - like "STUTTGART"
9. The second reply SMS triggers a the Runbook again
    1. The Runbook checks if the location is correct.
    2. If correct, the Runbook generates a random password.
    3. User A's password will set to the generated one. 
        * Also the account will be unlocked.
        * And the password must be changed at the next logon.
    4. In the last step, the runbook triggers a final SMS with the new password to the user.
10. User A is now able to login and change his one-time password to a real one.

## Requirements

Azure based variable’s to be in place:
- $TwilioAccountSid     = Get-AutomationVariable -Name 'TwilioAccountSid'       
- $TwilioAuthToken      = Get-AutomationVariable -Name 'TwilioAuthToken'        
- $TwilioPhoneNumber    = Get-AutomationVariable -Name 'TwilioPhoneNumber'      
- $SQLConnectionString  = Get-AutomationVariable -Name 'SQLConnectionString'    
- $DatabaseName         = Get-AutomationVariable -Name 'DatabaseName'           
- $ADAdminUserName      = Get-AutomationVariable -Name 'ADAdminUserName'        
- $ADAdminUserPassword  = Get-AutomationVariable -Name 'ADAdminUserPassword'    

Also a OMS Alert with this query is required:
    Type=SecurityEvent EventID=4740