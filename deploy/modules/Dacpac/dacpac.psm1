
function Publish-Database([string]$dacpac, [string]$profile)
{
	& "$PSScriptRoot\sqlpackage.exe" /a:publish /sf:$dacpac /pr:$profile
	Assert($LASTEXITCODE -eq 0 ) "Publish database Failed"
}

function Publish-Database-local([string]$dacpac, [string]$profile)
{
	#Register the DLL we need
Add-Type -Path "$PSScriptRoot\Microsoft.SqlServer.Dac.dll" 

#Read a publish profile XML to get the deployment options
$dacProfile = [Microsoft.SqlServer.Dac.DacProfile]::Load($profile)

#Use the connect string from the profile to initiate the service
$dacService = New-Object Microsoft.SqlServer.dac.dacservices ($dacProfile.TargetConnectionString)
 
 if($dacService -eq $null)
 {
	Write-Host "Could not create DACService"
 }
 
#Load the dacpac
$dacPackage = [Microsoft.SqlServer.Dac.DacPackage]::Load($dacpac)

#Publish or generate the script (uncomment the one you want)
Write-Host "Deploying to $dacpac with profile $profile"

try
{
$dacService.deploy($dacPackage, $dacProfile.TargetDatabaseName, $true, $dacProfile.DeployOptions)
}
finally{
$dacPackage.Dispose()
}
#$dacService.GenerateDeployScript($dacPackage, $dacProfile.TargetDatabaseName, $dacProfile.DeployOptions)
}

Export-ModuleMember -function Publish-Database


Export-ModuleMember -function Publish-Database
