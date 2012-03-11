function Expand-Templates($settingsFile, $deploymentEnvironment, $templatePath, $outputPath) {
	import-module AffinityId\Id.PowershellExtensions.dll
	
	Write-Output "Reading settings"
	$settings = get-parsedsettings $settingsFile $deploymentEnvironment 
	
	Write-Output "Template settings for the $deploymentEnvironment environment are:"
	$settings | Format-Table -property *
	
	copy-substitutedsettingfiles -templatesDirectory $templatePath -targetDirectory $outputPath -deploymentEnvironment $deploymentEnvironment -settings $settings
}

function Merge-EnvironmentSpecificFiles($deploymentEnvironment)
{
	$currentPath = Get-Location

	if ((Test-Path $currentPath\_environments\$deploymentEnvironment -PathType Container) -eq $true)
	{
		Copy-Item $currentPath\_environments\$deploymentEnvironment\* -destination $currentPath\ -recurse -force   
	}	
}


function Merge-Templates($settings, $deploymentEnvironment)
{
	import-module AffinityId\Id.PowershellExtensions.dll

	$currentPath = Get-Location
	
	if ((Test-Path $currentPath\_templates\ -PathType Container) -eq $false)
	{
		return
	}

	copy-substitutedsettingfiles -templatesDirectory $currentPath\_templates -targetDirectory $currentPath\_templatesoutput -deploymentEnvironment $deploymentEnvironment -settings $settings
	
	if ((Test-Path $currentPath\_templatesoutput\$deploymentEnvironment -PathType Container) -eq $true)
	{
		Copy-Item $currentPath\_templatesoutput\$deploymentEnvironment\* -destination $currentPath\ -recurse -force    
	}
}


Export-ModuleMember -function Expand-Templates, Merge-Templates, Merge-EnvironmentSpecificFiles