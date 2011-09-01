function Expand-Templates($settingsFile, $deploymentEnvironment, $templatePath, $outputPath) {
	import-module AffinityId\Id.PowershellExtensions.dll
	
	Write-Output "Reading settings"
	$settings = get-parsedsettings $settingsFile $deploymentEnvironment 
	
	Write-Output "Template settings for the $deploymentEnvironment environment are:"
	$settings | Format-Table -property *
	
	copy-substitutedsettingfiles -templatesDirectory $templatePath -targetDirectory $outputPath -deploymentEnvironment $deploymentEnvironment -settings $settings
}

Export-ModuleMember -function Expand-Templates