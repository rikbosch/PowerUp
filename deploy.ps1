include .\_powerup\commontasks.ps1

task deploy {
	run web-deploy ${web.servers}
}

task web-deploy  {
	import-module websiterecipes

	$websiteOptions = @{
		websitename = ${website.name};
		webroot = ${deployment.root};
		bindings = @(
					@{port = ${http.port};}
					@{port = ${https.port};protocol='https';}
					);
	}	
				
	set-website($websiteOptions)
}

