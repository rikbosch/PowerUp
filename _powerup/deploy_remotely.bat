whoami

if not '%1'=='' goto RUN

:NOENVIRONMENT
	echo Deployment environment parameter is required
	echo e.g. deploy_remotely production	
	exit /B

:RUN
	powershell -inputformat none -command "Set-ExecutionPolicy Unrestricted"
	powershell -inputformat none -command ".\_powerup\deploy_remotely.ps1 -deploymentEnvironment %1";exit $LastExitCode