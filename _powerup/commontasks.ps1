
task importsettings {
	import-module powerupsettings
	import-module AffinityId\Id.PowershellExtensions.dll
	import-module poweruptemplates

	$currentPath = Get-Location

	echo "Copying files specific to this profile to necessary folders within the package"
	merge-environmentspecificfiles ${deployment.profile}

	$settings = get-parsedsettings $currentPath\settings.txt ${deployment.profile}
	import-settings $settings
		
	echo "Package settings for this profile are:"
	$settings | Format-Table -property *
	
	echo "Substituting and copying templated files"	
	merge-templates $settings ${deployment.profile}
}
