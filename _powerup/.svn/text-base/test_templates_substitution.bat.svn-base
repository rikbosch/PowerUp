
if not '%1'=='' goto RUN

:NOENVIRONMENT
	echo Deployment environment parameter is required
	echo e.g. test_templates production	
	exit /B

:RUN
	powershell -inputformat none -command "Set-ExecutionPolicy Unrestricted"
	powershell -inputformat none -command ".\test_templates_substitution.ps1 -deploymentEnvironment %1 -destination ..\_templates_output -settingsFile ..\settings.txt -templatesFolder ..\_templates"