# Steps to Execute MigrateDocsBetweenPerceptiveServers
- [Download the Latest version PowerShell 7.x](https://aka.ms/powershell-release?tag=lts)
  - [Instructions](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  - This code has been tested on 7.4.x LTS release
- Create a folder in your downloads called `CLive2024`
  - i.e. `C:\Users\USERNAME\downloads\CLive2024\`
- Copy `MigrateDocsBetweenPerceptiveServers_PUBLIC.ps1` and `PerceptiveContentIntegrationServer_PUBLIC.psm1` to the above `CLive2024` folder
- Open `MigrateDocsBetweenPerceptiveServers_PUBLIC.ps1` and edit/review the following variables
  - `$isModulePath` - defaults to CLive2024 folder version of `PerceptiveContentIntegrationServer_PUBLIC.psm1`
  - `$logFilePath` - defaults to CLive2024 folder. Creates `$($dateEasy)_MigrateDocs.log` where dateEasy is the ISO Date i.e. yyyy-MM-dd
  - `$searchVSL` - add your VSL search criteria here to decide which documents will be migrated
  - `$srcView` - the perceptive view you will use to execute the search
  - `$srcEnvironment; $destEnvironment;` - specifically you will need to edit the `contentURL` entry with the domain for IP for your respective Perceptive instances
  - `$srcUsername; $srcPassword;` - credentials to use for the source environment. Always use best practices for passwords
  - `$destUsername; $destPassword;` - credentials to use for the source environment. Always use best practices for passwords
- Open PowerShell 7
- CD to the downloads directory
  - `cd "$($env:USERPROFILE)\downloads\CLive2024"`
- Run the script with `.\MigrateDocsBetweenPerceptiveServers_PUBLIC.ps1`
  - You may run into issues with Execution Policy when running a script you've downloaded
  - Use `Unblock-File` to remove the block. Use with caution.
  - `Unblock-File -Path "$($env:USERPROFILE)\downloads\CLive2024\MigrateDocsBetweenPerceptiveServers_PUBLIC.ps1"`
  - `Unblock-File -Path "$($env:USERPROFILE)\downloads\CLive2024\PerceptiveContentIntegrationServer_PUBLIC.psm1"`

# How to use the Integration Server Functions
- import the module into any script you are writing and the cmdlets will become available for you to use
  - `Import-Module "$($env:USERPROFILE)\downloads\CLive2024\PerceptiveContentIntegrationServer_PUBLIC.psm1" -Force`
- You can modify and extend the `Get-Custom_Environment` cmdlet to save environment variables
