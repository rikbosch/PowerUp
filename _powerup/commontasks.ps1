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
	invoke-remotetasks $task $servers ${deployment.profile} ${package.name} $serverSettingsScriptBlock
}

task importsettings {
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

