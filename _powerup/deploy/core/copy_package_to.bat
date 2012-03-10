@echo off

if not '%1'=='' goto RUN

:NOENVIRONMENT
	@echo on
	echo Destination Path Required
	echo e.g. copy_package_to \\manage\packages
	exit /B

:RUN
	call _powerup\unzip.bat %2
	xcopy xcopy . %1 /S /Y
	
	