# Brendan Bladdick

# Invoking ArcGIS Configuration Script
# Set Path to easily access logs (the location you run the Invoke from will be where the Logs show up)

Set-Location -Path "C:\Automation\Logs"

Invoke-ArcGISConfiguration -ConfigurationParametersFile "C:\Automation\DSC\basic.json" -Mode InstallLicenseConfigure -DebugSwitch

# if successful, run without -DebugSwitch to turn off Debug Mode on ArcGIS Components
# Invoke-ArcGISConfiguration -ConfigurationParametersFile "D:\EsriInstall\DSC\BaseEnterpriseDeployment.json" -Mode InstallLicenseConfigure

