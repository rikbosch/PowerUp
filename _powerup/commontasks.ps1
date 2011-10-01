function getPlainTextDeploymentProfileSettings($deploymentProfile)
{
	import-module AffinityId\Id.PowershellExtensions.dll
	$currentPath = Get-Location

	get-parsedsettings $currentPath\settings.txt $deploymentProfile
}

function getPlainTextServerSettings($serverName)
{
	import-module AffinityId\Id.PowershellExtensions.dll
	$currentPath = Get-Location

	get-parsedsettings $currentPath\servers.txt $serverName
}

function run($task, $servers)
{
	import-module powerupremote	
	$currentPath = Get-Location
	$packageName =	Get-Content $currentPath\package.id	
	invoke-remotetasks $task $servers ${deployment.profile} $packageName $serverSettingsScriptBlock
}

tasksetup {
	& $setupScriptBlock
}

task default -depends deploy 

function mergeSettingsAndProcessTemplates()
{
	import-module powerupsettings
	import-module poweruptemplates

	$deploymentProfileSettings = &$deploymentProfileSettingsScriptBlock ${deployment.profile}
	import-settings $deploymentProfileSettings
		
	echo "Package settings for this profile are:"
	$deploymentProfileSettings | Format-Table -property *
	
	echo "Substituting and copying templated files"	
	merge-templates $deploymentProfileSettings ${deployment.profile}
}


$deploymentProfileSettingsScriptBlock = $function:getPlainTextDeploymentProfileSettings
$serverSettingsScriptBlock = $function:getPlainTextServerSettings
$setupScriptBlock = $function:mergeSettingsAndProcessTemplates

