

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
	
	invoke-remotetasks $task $servers ${deployment.profile} $remoteWorkingSubFolder $serverSettingsScriptBlock
}


task default -depends preprocesspackage, deploy 

task preprocesspackage {
	touchPackageIdFile
	& $processTemplatesScriptBlock
}

tasksetup {
	mergeSettings
}

function touchPackageIdFile()
{
	$path = get-location 
	(Get-Item $path\package.id).LastWriteTime = [datetime]::Now
}

function mergeSettings()
{
	import-module powerupsettings

	$deploymentProfileSettings = &$deploymentProfileSettingsScriptBlock ${deployment.profile}
	
	if ($deploymentProfileSettings)
	{
		import-settings $deploymentProfileSettings
	}
}

function processTemplates()
{
	import-module powerupsettings
	import-module poweruptemplates

	$deploymentProfileSettings = &$deploymentProfileSettingsScriptBlock ${deployment.profile}
	
	if ($deploymentProfileSettings)
	{			
		Write-Host "Package settings for this profile are:"
		$deploymentProfileSettings | Format-Table -property *
		
		Write-Host "Substituting and copying templated files"	
		merge-templates $deploymentProfileSettings ${deployment.profile}
	}
}


$deploymentProfileSettingsScriptBlock = $function:getPlainTextDeploymentProfileSettings
$serverSettingsScriptBlock = $function:getPlainTextServerSettings
$processTemplatesScriptBlock = $function:processTemplates

