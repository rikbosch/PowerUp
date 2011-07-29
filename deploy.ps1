properties{
	$packageFolder = Get-Location
}


task default -depends importmodules, deployfiles

task importmodules {
	Import-Module PowerUpFileSystem
	Import-Module PowerUpWeb
}

task deployfiles {
	copy-mirroreddirectory $packageFolder\${package.name} ${deployment.root}\${package.name} 
}
