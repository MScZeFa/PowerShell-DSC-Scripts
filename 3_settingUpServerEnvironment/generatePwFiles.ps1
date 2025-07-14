# Brendan Bladdick - – angepasst auf GeoBAK / ArcGIS Enterprise 11.5 Umgebung

# Script to create password files for the accounts and certificates

# Define account types and their respective output file paths in an ordered hashtable
$accounts = [ordered]@{
    "AD account 'SMI\svc_arcgis'"       = "C:\Automation\passwordFiles\svc_arcgis.txt"
    "Portal admin account 'siteadmin'"  = "C:\Automation\passwordFiles\portalAdmin.txt"
    "Server admin account 'siteadmin'"  = "C:\Automation\passwordFiles\serverAdmin.txt"
    "SSL certificate (PFX) password"    = "C:\Automation\passwordFiles\certPassword.txt"
}

# Ensure the directory exists before creating the password files
foreach ($filePath in $accounts.Values) {
    $directory = [System.IO.Path]::GetDirectoryName($filePath)
    if (-not (Test-Path -Path $directory)) {
        New-Item -Path $directory -ItemType Directory | Out-Null
    }
}

# Iterate over each account, prompt for password, and save to file
foreach ($account in $accounts.GetEnumerator()) { # GetEnumerator() returns a collection of key-value pairs
    Write-Host "Enter the password for the $($account.Key)" # Key is the account type, Value is the file path
    $password = Read-Host -AsSecureString | ConvertFrom-SecureString # Convert to secure string and then to plain text
    $password | Out-File $account.Value # Save to file
}
