#function rename
#{
#    #Write-Host $company + "&" + $serialnum
#    if ( ($company -eq "FB" -or $company -eq "FD") -and ($serialnum -eq (Get-CimInstance -ClassName Win32_BIOS -Property SerialNumber).SerialNumber ) )
#    {
#        $newName = ($company + "-" + $serialnum)
#        Write-Host ("New PC name will be: " + $newName)
#        Rename-Computer -NewName ($company + "-" + $serialnum) -Confirm
#    }
#    else
#    {
#        Write-Host "Error with either assigned company value or assigned serial number."
#    }
#} ###### FUNCTION TO RENAME PC TO EITHER FB-SerialNumber or FD-SerialNumber######
### Function removed due to Azure AD automatic rename. Function used to leverage wmic to retrieve BIOS and auto-rename PC

function installApps
{
    Write-Host "Entering app installation function."
    Write-Host "Installing Lenovo System Update Utility for drivers and firmware."
    Start-Process -Wait 'c:\apps\system_update_5.07.0136.exe'
    Write-Host "Installing DMG True View freeware to allow users to view AutoCAD files."
    Start-Process msiexec.exe -Wait -ArgumentList '/i c:\apps\DWGTrueView_2022_English_64bit_dlm\x64\dwgviewr\dwgviewr.msi ADSK_SETUP_EXE=1 ADAOPTIN=0 ADAOVERRIDED=1 /qn'
    Write-Host "Installing PhishAlert Outlook plugin."
    Start-Process msiexec -Wait -ArgumentList '/quiet /i c:\apps\PhishAlert\PhishAlert.msi LicenseKey=serialnumber ALLUSERS=1'
    Write-Host "Installing Google Chrome"
    Start-Process msiexec.exe -Wait -ArgumentList '/i c:\apps\GoogleChromeStandaloneEnterprise64.msi /qn'
    Write-Host "Installing Google Earth"
    Start-Process -Wait c:\apps\googleearthprowin-7.3.3-x64.exe OMAHA=1
} #Installs the standard suite of apps

function systemConfigs
{
    Write-Host "Entering system configuration function."
    Write-Host "Turning off hibernation."
    powercfg.exe /hibernate off
    Write-Host "Setting time zone to US Eastern."
    Set-TimeZone -Id "Eastern Standard Time"
} #Sets simple configs

function egnyteInstall
{
    $org = ""
    switch ($in)
    {
        b       {$org = "frontierbuilding"  ; Break}
        d       {$org = "fdllc"; Break}
        default {Write-Host "Input outside expected parameters 'b' or 'd' Aborting install."}
    }
    if ( ($org -eq "frontierbuilding") -or ( $org -eq "fdllc") )
    {
        Write-Host "Installing Egnyte Outlook Addin"
        Start-Process C:\Apps\Egnyte\EgnyteOfficeAddin.msi "INSTALLDIR=`"C:\Program Files (x86)\Egnyte Office Add-in`" DISABLE_AUTOUPDATE=TRUE DOMAIN_NAME=$org ALLUSERS=1 /qn"
        Write-Host "Installing Egnyte Desktop App"
        Start-Process C:\Apps\Egnyte\EgnyteDesktopApp.msi "ED_SILENT=1 /passive"
    }
}

function egnyteConfig
{
    $username = ""
    $dmn = ""
    Write-Host "This method REQUIRES to be run as the user in question. It expects a user in AzureAD."
    Write-Host "Are you sure you are running it as USER instead of Admin? Abort with Ctrl-C"
    PAUSE
    Write-Host "Egnyte Connection"
    $username=(whoami /upn).split("@") | Select-Object -First 1
    $localuser=(whoami).split("\") | Select-Object -Last 1
    switch ($in)
    {
        b       {$dmn = "FBC", "frontierbuilding"  ; Break}
        d       {$dmn = "FDLLC", "fdllc"; Break}
        default {Write-Host "Input outside expected parameters 'b' or 'd' Aborting install."}
    }
    Start-Process "C:\Program Files (x86)\Egnyte Connect\EgnyteClient.exe" -ArgumentList "--auto-silent"
    & "C:\Program Files (x86)\Egnyte Connect\EgnyteClient.exe" -command add -l $dmn[0] -d $dmn[1] -m "/Shared" -sso use_sso -t N -c connect_immediately
    & "C:\Program Files (x86)\Egnyte Connect\EgnyteClient.exe" -command add -l Private -d $dmn[1] -m "/Private/$username" -sso use_sso -t P -c connect_immediately
    Write-Host Please login via the browser window that will automatically pop up.
    PAUSE
    Write-Host "Outlook Addin Configuration"
    REG ADD "HKEY_CURRENT_USER\SOFTWARE\Egnyte\Egnyte Office AddIn\0" /v defUploadFolder /d "/Shared/Outlook-Links/$username" /f
    REG ADD "HKEY_CURRENT_USER\SOFTWARE\Egnyte\Egnyte Office AddIn\0" /v defSaveToFolder /d "/Private/$username/Outlook-Attachments" /f
    PAUSE
    Write-Host "Egnyte - Configuration - Advanced"
    Start-Process "C:\Program Files (x86)\Egnyte Connect\EgnyteClient.exe" -ArgumentList "-command connect_folder -l Private -a `"C:\Users\$localuser\Desktop`" -r `"/Private/$username/Sync/Desktop`""
    Start-Process "C:\Program Files (x86)\Egnyte Connect\EgnyteClient.exe" -ArgumentList "-command connect_folder -l Private -a `"C:\Users\$localuser\Documents`" -r `"/Private/$username/Sync/Documents`""
    Start-Process "C:\Program Files (x86)\Egnyte Connect\EgnyteClient.exe" -ArgumentList "-command connect_folder -l Private -a `"C:\Users\$localuser\Pictures`" -r `"/Private/$username/Sync/Pictures`""
    Write-Host "Method complete. Please verify all settings and configurations have been completed successfully."
}

function security
{
##########################################################################
    Write-Host "====================Installing Huntress===================="
    switch ($in)
    {
        b       {$org = "fbc"  ; Break}
        d       {$org = "fdllc"; Break}
        default {Write-Host "Input outside expected parameters 'b' or 'd'"}
    }
    if ( ! [string]::IsNullOrEmpty($org) ) {
    powershell -executionpolicy bypass -f C:\Apps\Huntress\InstallHuntress.powershellv1.ps1 -acctkey serialnumber -orgkey $org
    }
    Write-Host "====================Installation Complete===================="
##########################################################################
    Write-Host "====================Installing SentinelOne===================="
    $token = ""
    switch ($in)
    {
        b       {$token = "serialnumber1"  ; Break}
        d       {$token = "serialnumber2"; Break}
        default {Write-Host "Input outside expected parameters 'b' or 'd'"}
    }
    if ( ! [string]::IsNullOrEmpty($token) ) {
    Start-Process -FilePath "C:\Apps\SentinelOne\SentinelInstaller.msi" -Wait -ArgumentList "/QUIET /NORESTART UI=false SITE_TOKEN=$token"
    }
    Write-Host "====================Installation Complete===================="
##########################################################################
} # Installs Huntress and SentinelOne

function helpCmd
{
    Write-Host "Written by Ed Carulo :: edreycarulo@gmail.com"
    Write-Host "========================================"
    Write-Host "The script expects one of a handful of parameters: standard, egConfig, egInstall and help."
    Write-Host "========================================"
    Write-Host "Help will display this informational text. It can be called using:    NewPCSetup.ps1 help"
    Write-Host "========================================"
    Write-Host "Standard will go through much of the automated changes to new PCs used by Frontiercompanies. This includes the installation of certain apps and plugins, security changes, and other system configurations.    NewPCSetup.ps1 standard"
    Write-Host "========================================"
    Write-Host "egConfig MUST be run as a user, not NOT as an Admin. It will go through the Egnyte configurations needed. Be sure to take your time with it and don't just smash Enter. Refer to the documentation in IT SOPs for more information.    NewPCSetup.ps1 egConfig"
    Write-Host "========================================"
    Write-Host "egInstall will reinstall the Egnyte desktop and its plugin. Sometimes the installation fails, or will not complete because Outlook is open. This will simply retry without going through the whole suite."
    #Write-Host "========================================"
    #Write-Host "Rename will execute only the rename function, and kept only for the rare occasion where a device is not on AzureAD."
}

ECHO "Is the user:" "b) Frontier BUILDING" "d) Frontier DEVELOPMENT"
$in = Read-Host Input b or d then hit enter

switch ($args[0])
{
    standard   { installApps; systemConfigs; egnyteInstall; security; Break}
    egInstall  {egnyteInstall; Break}
    egConfig   {Write-Host "You are running this as $(whoami). Are you sure this is correct? Hit Ctrl-C if IT IS NOT."; PAUSE; egnyteConfig; Break}
    #rename    { rename; Break;}
    help       { helpCmd; Break}
    default    { helpCmd; Break;}
}
