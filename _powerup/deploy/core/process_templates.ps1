param([string]$deploymentEnvironment)

$currentPath = Get-Location

$env:PSModulePath = $env:PSModulePath + ";$currentPath\modules\"
import-module PowerUpTemplates

$settingsFile = "..\settings.txt"
$templatesPath = "..\_templates"
$outputPath = "..\_templates_output"

Write-Host "Deployment Environment: $deploymentEnvironment"
Write-Host "Output Path: $outputPath"

Expand-Templates $settingsFile $deploymentEnvironment $templatesPath $outputPath
