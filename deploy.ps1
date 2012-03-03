include .\_powerup\commontasks.ps1

task deploy {
	run web-deploy ${web.servers}
}

task web-deploy  {
	import-module websiterecipes

	$websiteOptions = @{
		websitename = ${website.name};
		deploymentroot = ${deployment.root};
		bindings = @{port = ${http.port};};
	}	
				
	set-website($websiteOptions)
}

