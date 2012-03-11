@echo off

:RUN
	call _powerup\ensure_prerequisites.bat
	powershell -inputformat none .\_powerup\unzip.ps1 
	