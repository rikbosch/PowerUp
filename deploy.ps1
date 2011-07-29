task default -depends Deploy
task Deploy 
{
	Import-Module PowerUpWeb
	Write-Host "deploying"
}
