@echo off

if not '%1'=='' goto RUN

:NOENVIRONMENT
	@echo on
	echo Package Number is required
	echo e.g. unzip 256
	exit /B

:RUN
	call _powerup\ensure_prerequisites.bat
	powershell -inputformat none .\_powerup\unzip.ps1 -buildNumber %1
	