@echo off

if not '%1'=='' goto RUN

:NOENVIRONMENT
	@echo on
	echo Deployment environment parameter is required
	echo e.g. deploy production	
	exit /B

:RUN
	call _powerup\ensure_prerequisites.bat
	powershell -inputformat none -command ".\test_templates_substitution.ps1 -deploymentEnvironment %1 -destination ..\_templates_output -settingsFile ..\settings.txt -templatesFolder ..\_templates"
	
	