# Brendan Bladdick and Adrien Hafner

# this script is designed to transfer installers to all the machines in the $remoteServers block from the $localServer orchestration machine, and at the end of the script, it will report the contents of the folder on your remote servers so you can confirm the installers have been transferred.

# change the $localServer and $remoteServers lists to reflect your machines

# change the $sourceDrive, $mainDirectory and $subDirectory to match your environment

# Define the local and remote servers
$localServer = @('localserver')   # Local server or orchestration server
$remoteServers = @('remoteserver1','remoteserver2') # List of remote servers

$sourceDrive = "C:" # Define the drive letter as a variable (no trailing slash or $)
$mainDirectory = "Automation" # Change this to the directory that contains the folder that contains the installs folder
$subDirectory = "installs" # Change this to the directory that contains the installers

$ScriptBlock = {
    param ($server, $mainDirectory, $subDirectory, $remoteServers, $sourceDrive)
    
    $serverTrimmed = $server.Trim()
    Write-Host "Checking if $serverTrimmed is in remote servers list..."
    
    if ($remoteServers -contains $serverTrimmed) {
        try {
            # Clean the colon from the drive letter for UNC use (e.g., "D:" -> "D$")
            $driveShare = "$($sourceDrive.TrimEnd(':'))$"
            
            # Define the target directory path using the dynamic drive variable
            $targetDir = "\\$serverTrimmed\$driveShare\$mainDirectory\$subDirectory"
            
            # Check if the target directory exists, create it if it doesn't
            if (-not (Test-Path -Path $targetDir)) {
                Write-Host "Creating directory: $targetDir"
                New-Item -ItemType Directory -Path $targetDir -Force
            }
            else {
                Write-Host "Removing contents of directory: $targetDir"
                Remove-Item "$targetDir\*" -Recurse -Force
            }
            
            # Copy from local source to remote target
            $sourcePath = Join-Path -Path $sourceDrive -ChildPath "$mainDirectory\$subDirectory\*"
            Write-Host "Copying files from $sourcePath to $targetDir"
            Copy-Item -Path $sourcePath -Destination $targetDir -Recurse -Force
            
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
    $job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $server, $mainDirectory, $subDirectory, $remoteServers, $sourceDrive
    $jobs += $job
}

# Wait for all jobs to complete
$jobs | Wait-Job

# Output job results and cleanup
$jobs | ForEach-Object {
    Receive-Job -Job $_
    Remove-Job -Job $_
}

