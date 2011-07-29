@echo off

if not '%1'=='' goto RUN

:NOENVIRONMENT
	@echo on
	echo Deployment environment parameter is required
	echo e.g. deploy_remotely production	
	exit /B

:RUN
	call _powerup\ensure_prerequisites.bat
	powershell -inputformat none -command ".\_powerup\deploy_remotely.ps1 -deploymentEnvironment %1";exit $LastExitCode