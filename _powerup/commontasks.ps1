
task importsettings {
	import-module powerupsettings

	$currentPath = Get-Location

	echo "Copying files specific to this environment to necessary folders within the package"
	merge-environmentspecificfiles ${deployment.environment}

	$settings = get-parsedsettings $currentPath\settings.txt ${deployment.environment}
	import-settings $settings
		
	echo "Package settings for this environment are:"
	$settings | Format-Table -property *
	
	echo "Substituting and copying templated files"	
	merge-templates $settings ${deployment.environment}
}
