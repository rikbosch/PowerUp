function set-website($options)
{
	import-module powerupfilesystem
	import-module powerupweb
	
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
		$options.fulldestinationpath = "$($options.deploymentroot)\$($options.destinationfolder)"
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
		$options.bindings = @{}
	}

	if (!$options.bindings.protocol)
	{
		$options.bindings.protocol = "http"
	}

	if (!$options.bindings.ip)
	{
		$options.bindings.ip = "*"
	}
	
	if (!$options.bindings.url)
	{
		$options.bindings.url = $options.websitename
	}

	if (!$options.bindings.port)
	{
		$options.bindings.port = 80
	}
	
	$options | Format-Table -property *
	
	if($options.stopwebsitefirst)
	{
		stop-apppoolandsite $options.apppoolname $options.websitename
	}
	
	copy-mirroreddirectory $options.fullsourcepath $options.fulldestinationpath

	set-webapppool $options.apppool.name $options.apppool.executionmode $options.apppool.dotnetversion
	set-website $options.websitename $options.apppoolname $options.fulldestinationpath $options.bindings.url $options.bindings.protocol $options.bindings.ip $options.bindings.port

	if($options.startwebsiteafter)
	{
		start-apppoolandsite $options.apppoolname $options.websitename
	}

}
