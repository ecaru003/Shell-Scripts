# ecaru003Bash_Scripts

This is a collection of Bash scripts which I have either written before, find interesting, or find userful

UNIX (Bash)
GenerateCustomHomeFolders.sh
    Given a properly formatted CSV (ecaru003.csv), script generated a thousand user folders based on given requirements. 
    /home/ was organized by two subfolders, "olympic" and "paralympic"
    Olympic was further organized by competitive sport, and finally each individual username.
    Each olympic user's personal home folder needed to have three files ('country' 'event' 'medal' with respective CSV entries within.
    Paralympic users were treated similarly, but organized by home country instead of competitive sport.
        
GenerateWebpageByGender.sh
    Given a properly formatted CSV (ecaru003.csv), script installed Apache web server and generated several html plain text webpages.
    For male participants, both olympic and paralympic, a webpage was generated for each sport. 
    Each webpage had male participant information according to a specified order.
    For female participants, both olympic and paralympic, a webpage was generated for each country.
    Each webpage had female participant information according a different, specified order from male participants.
    
ResortUsersByCountry.sh
    This script was meant to reorganize an existing configuration. An apache webserver and mysql server were running and configured, sorted by sport.
    The goal of this script was to remove that old configuration, and reapply it with users sorted by country instead
    
add_ldap_user_by_gender.sh
    This script dynamically adds users to an LDAP server.
    The script will make two LDAP groups, one for each gender present in the csv (m,f)
    Then it will add each user to the appropriate gender group 

Windows (PowerShell)
NewPCSetup.ps1
    Script written to simplify my workflow at Frontier Building Corp.
    Preparing new devices for users was a tedious process that would take the better part of a day when I was initially hired.
    It is a collection of PowerShell functions that can be called from the command line 
      eg., 'powershell NewPCSetup.ps1 standard' or 'powershell NewPCSetup.ps1 egConfig'
    By leveraging the script, proper configuration could be achieved in one hour (with user present/available) or two hours without user. 
