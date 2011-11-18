

function getPlainTextServerSettings($serverName)
{
	getPlainTextSettings $serverName servers.txt
}

function getPlainTextDeploymentProfileSettings($deploymentProfile)
{
	getPlainTextSettings $deploymentProfile settings.txt
}

function getPlainTextSettings($parameter, $fileName)
{
	$currentPath = Get-Location
	$fullFilePath = "$currentPath\$fileName"

	write-host $fullFilePath
	
	import-module AffinityId\Id.PowershellExtensions.dll

	if (!(test-path $fullFilePath))
	{
		return $null
	}
	
	get-parsedsettings $fullFilePath $parameter
}

function run($task, $servers, $remoteWorkingSubFolder = $null)
{
	import-module powerupremote	
	$currentPath = Get-Location
	
	if ($remoteWorkingSubFolder -eq $null)
	{
		$remoteWorkingSubFolder =	Get-Content $currentPath\package.id	
	}
	
	$serverNames = $servers.split(';')
	if (!$serverNames)
	{
		$serverNames = @($servers)
	}
	
	invoke-remotetasks $task $serverNames ${deployment.profile} $remoteWorkingSubFolder $serverSettingsScriptBlock
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
	
	if ($deploymentProfileSettings)
	{
		import-settings $deploymentProfileSettings
			
		echo "Package settings for this profile are:"
		$deploymentProfileSettings | Format-Table -property *
		
		echo "Substituting and copying templated files"	
		merge-templates $deploymentProfileSettings ${deployment.profile}
	}
}


$deploymentProfileSettingsScriptBlock = $function:getPlainTextDeploymentProfileSettings
$serverSettingsScriptBlock = $function:getPlainTextServerSettings
$setupScriptBlock = $function:mergeSettingsAndProcessTemplates

