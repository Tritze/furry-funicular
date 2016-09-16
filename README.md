# furry-funicular

This projekt is part of a blog-post-series on https://blog.tritze.eu

furry-funicular is a set of PowerShell scripts that must be implemented as Azure Automation Runbooks,
to have, combined with Microsoft Operations Management Suite, a solution that does an automated password
recovery for useraccounts. This is done with a simple SMS system. 

To make it clearer, look at the process:
1. User A has forgotten his password.
2. User A's account has been locked out.
3. OMS analyzes the server logs.
4. Bases on the logs, OMS triggers a OMS Alert for the locked-out account of User A.
5. The Alert triggers a WebHook from a Azure Automation Runbook.
    * The Runbook get's the mobile phone number of the user.
    * The Runbook creates an entry in a SQL database.
    * The Runbook sends an SMS to User A's mobile phone.
6. User A gets an SMS with information that his account is locked-out.
    * The user can now reply, by SMS, with "UNLOCK" to start the unlock process.
7. The SMS reply triggers a second Runbook.
    * The Runbooks controlls if there is any entry in the database.
    * If an entry exsist, the Runbook gets the location information of the User from the Active Directory.
    * The Runbook sends a second SMS to the User's mobile phone, with the question where he is located.
8. The User recieves the SMS and replys with his location. - like "STUTTGART"
9. The second reply SMS triggers a the Runbook again
    * The Runbook checks if the location is correct.
    * If correct, the Runbook generates a random password.
    * User A's password will set to the generated one. 
        * Also the account will be unlocked.
        * And the password must be changed at the next logon.
    * In the last step, the runbook triggers a final SMS with the new password to the user.
10. User A is now able to login and change his one-time password to a real one.

Azure based variabels to be in place:
- $TwilioAccountSid     = Get-AutomationVariable -Name 'TwilioAccountSid'       ->  
- $TwilioAuthToken      = Get-AutomationVariable -Name 'TwilioAuthToken'        ->
- $TwilioPhoneNumber    = Get-AutomationVariable -Name 'TwilioPhoneNumber'      ->
- $SQLConnectionString  = Get-AutomationVariable -Name 'SQLConnectionString'    ->
- $DatabaseName         = Get-AutomationVariable -Name 'DatabaseName'           ->
- $ADAdminUserName      = Get-AutomationVariable -Name 'ADAdminUserName'        ->
- $ADAdminUserPassword  = Get-AutomationVariable -Name 'ADAdminUserPassword'    ->