powershell -inputformat none -command "Set-ExecutionPolicy Unrestricted"
powershell -inputformat none -command ".\_powerup\set_powershell_version.ps1";exit $LastExitCode
