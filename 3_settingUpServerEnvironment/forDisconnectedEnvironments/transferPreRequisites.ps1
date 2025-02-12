# Brendan Bladdick and Adrien Hafner

# this script is designed to transfer web adaptor 11.1+ Microsoft IIS pre-requisites to the web server machine(s) listed in the $remoteServer list from the $localServer orchestration machine.  At the end of the script, it will report the contents of the folder on your remote servers so you can confirm the prerequisites have been transferred.

# change the $localServer and $remoteServers lists to reflect your machines

# Define the local and remote servers
$localServer = @('localserver')   # Local server or orchestration server
$remoteServers = @('remoteserver1','remoteserver2') # List of remote servers

$mainDirectory = "EsriInstall" # Change this to the directory that contains the folder that contains the prerequisites folder
$subDirectory = "prerequisites" # Change this to the directory that contains the Microsoft IIS prerequisites

$ScriptBlock = {
    param ($server, $mainDirectory, $subDirectory, $remoteServers)
    
    # Trim any spaces and perform a case-insensitive comparison for remote servers
    $serverTrimmed = $server.Trim()
    
    Write-Host "Checking if $serverTrimmed is in remote servers list..."
    
    if ($remoteServers -contains $serverTrimmed) {
        try {
            # Define the target directory path
            $targetDir = "\\$serverTrimmed\d$\$mainDirectory\$subDirectory"
            
            # Check if the target directory exists, create it if it doesn't
            if (-not (Test-Path -Path $targetDir)) {
                Write-Host "Creating directory: $targetDir"
                New-Item -ItemType Directory -Path $targetDir -Force
            }
            else {
                # If the directory already exists, remove its contents
                Write-Host "Removing contents of directory: $targetDir"
                Remove-Item "$targetDir\*" -Recurse -Force
            }
            
            # Now, copy only the contents of the source prerequisites folder to the target
            Write-Host "Copying files to $targetDir"
            Copy-Item -Path "D:\$mainDirectory\$subDirectory\*" -Destination $targetDir -Recurse -Force
            
            # Output the contents of the target directory after copy
            Write-Host "Files in destination directory $targetDir after copy:"
            Get-ChildItem -Path $targetDir -Recurse | ForEach-Object { Write-Host $_.FullName }
        }
        catch {
            Write-Error "An error occurred on server ${serverTrimmed}: $_"
        }
    } else {
        Write-Host "Skipping local server: $serverTrimmed"
    }
}

# Loop through all servers and apply script to remote servers only
$jobs = @()
foreach ($server in $localServer + $remoteServers) {
    $job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $server, $mainDirectory, $subDirectory, $remoteServers
    $jobs += $job
}

# Wait for all jobs to complete
$jobs | Wait-Job

# Output job results and cleanup
$jobs | ForEach-Object {
    Receive-Job -Job $_
    Remove-Job -Job $_
}


