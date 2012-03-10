@echo off

if not '%1'=='' goto RUN

:NOENVIRONMENT
	@echo on
	echo Deployment environment parameter is required
	echo e.g. Local, Test, Staging, Production	
	exit /B

:RUN
	powershell -ExecutionPolicy Unrestricted -command ".\process_templates.ps1 -deploymentEnvironment %1"