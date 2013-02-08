function Invoke-Combo-StandardWebsite($options)
{
	import-module powerupfilesystem
	import-module powerupweb
	import-module powerupappfabric\ApplicationServer
		
	if(!$options.stopwebsitefirst)
	{
		$options.stopwebsitefirst = $true
	}
	
	if(!$options.startwebsiteafter)
	{
		$options.startwebsiteafter = $true
	}
	
	if(!$options.port)
	{
		$options.port = 80
	}
		
	if (!$options.destinationfolder)
	{
		$options.destinationfolder = $options.websitename
	}

	if (!$options.sourcefolder)
	{
		$options.sourcefolder = $options.destinationfolder
	}
	
	if (!$options.fulldestinationpath)
	{
		$options.fulldestinationpath = "$($options.webroot)\$($options.destinationfolder)"
	}

	if (!$options.fullsourcepath)
	{
		$options.fullsourcepath = "$(get-location)\$($options.sourcefolder)"
	}
	
	if (!$options.apppool)
	{
		$options.apppool = @{}
	}
		
	if (!$options.apppool.executionmode)
	{
		$options.apppool.executionmode = "Integrated"
	}
	
	if (!$options.apppool.dotnetversion)
	{
		$options.apppool.dotnetversion = "v4.0"
	}
	
	if (!$options.apppool.name)
	{
		$options.apppool.name = $options.websitename
	}
	if (!$options.bindings)
	{
		$options.bindings = @(@{})
	}

	foreach($binding in $options.bindings)
	{
		if (!$binding.protocol)
		{
			$binding.protocol = "http"
		}

		if (!$binding.ip)
		{
			$binding.ip = "*"
		}
		
		if (!$binding.port)
		{
			$binding.port = 80
		}
		
		if (!$binding.useselfsignedcert)
		{
			$binding.useselfsignedcert = $true
		}
		
		if (!$binding.certname)
		{
			$binding.certname = $options.websitename
		}
	}
	
	
		
	if($options.stopwebsitefirst)
	{
		stop-apppoolandsite $options.apppool.name $options.websitename
	}
	
	if($options.copywithoutmirror)
	{
		copy-directory $options.fullsourcepath $options.fulldestinationpath
	}
	else
	{
		copy-mirroreddirectory $options.fullsourcepath $options.fulldestinationpath
	}

	set-webapppool $options.apppool.name $options.apppool.executionmode $options.apppool.dotnetversion
	
	if ($options.apppool.username)
	{
		set-apppoolidentitytouser $options.apppool.name $options.apppool.username $options.apppool.password
	}
	
	if ($options.apppool.identity -eq "NT AUTHORITY\NETWORK SERVICE")
	{
		set-apppoolidentityType $options.apppool.name 2 #2 = NetworkService
	}
	
	$firstBinding = $options.bindings[0]
	set-website $options.websitename $options.apppool.name $options.fulldestinationpath $firstBinding.url $firstBinding.protocol $firstBinding.ip $firstBinding.port 
	
	foreach($binding in $options.bindings)
	{
		if($binding.protocol -eq "https")
		{
			Set-WebsiteForSsl $binding.useselfsignedcert $options.websitename $binding.certname $binding.ip $binding.port $binding.url		
		}
		else
		{
			set-websitebinding $options.websitename $binding.url $binding.protocol $binding.ip $binding.port
		}
	}
	
	if($options.virtualdirectories)
	{
		foreach($virtualdirectory in $options.virtualdirectories)
		{
			write-host "Deploying virtual directory $($virtualdirectory.directoryname) to $($options.websitename)."
			
			if (!$virtualdirectory.fulldestinationpath) {
				$virtualdirectory.fulldestinationpath = "$($options.webroot)\$($virtualdirectory.destinationfolder)"
			}
			
			if ($virtualdirectory.fullsourcepath -or $virtualdirectory.sourcefolder)
			{
				if (!$virtualdirectory.fullsourcepath) {
					$virtualdirectory.fullsourcepath = "$(get-location)\$($virtualdirectory.sourcefolder)"
				}
				copy-mirroreddirectory $virtualdirectory.fullsourcepath $virtualdirectory.fulldestinationpath
			}
			
			if ($virtualdirectory.isapplication) {
				new-webapplication $options.websitename $options.apppool.name $virtualdirectory.directoryname $virtualdirectory.fulldestinationpath
			} else {
				new-virtualdirectory $options.websitename $virtualdirectory.directoryname $virtualdirectory.fulldestinationpath
			}
			
			if ($virtualdirectory.useapppool)
			{
				write-host "Switching virtual directory $($options.websitename)/$($virtualdirectory.directoryname) to use app pool identity for anonymous authentication."
				set-webproperty "$($options.websitename)/$($virtualdirectory.directoryname)" "/system.WebServer/security/authentication/AnonymousAuthentication" "username" ""
			}
		}
	}
	
	if($options.appfabricapplications)
	{
		foreach($application in $options.appfabricapplications)
		{
			new-webapplication $options.websitename $options.apppool.name $application.virtualdirectory "$($options.fulldestinationpath)\$($application.virtualdirectory)" 
			Set-ASApplication -SiteName $options.websitename -VirtualPath $application.virtualdirectory -AutoStartMode All -EnableApplicationPool -Force
			set-apppoolstartMode $options.websitename 1
		}
	}

	if($options.startwebsiteafter)
	{
		start-apppoolandsite $options.apppool.name $options.websitename
	}

}
