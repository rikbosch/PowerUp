function install-CloudBerry {	
	try{
		C:\Windows\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe "$PSScriptRoot\CloudBerryLab.Explorer.PSSnapIn.dll"
	}
	catch{
		Write-Host "Unable to install CloudBerry"
		exit
	}
	
	$ModuleName = "CloudBerryLab.Explorer.PSSnapIn"
	$ModuleLoaded = $false
	$LoadAsSnapin = $false

	if ($PSVersionTable.PSVersion.Major -ge 2)
	{
		if ((Get-Module -ListAvailable | ForEach-Object {$_.Name}) -contains $ModuleName)
		{
			Import-Module $ModuleName
			if ((Get-Module | ForEach-Object {$_.Name}) -contains $ModuleName)
			{
				$ModuleLoaded = $true
			}
			else
			{
				$LoadAsSnapin = $true
			}
		}
		elseif ((Get-Module | ForEach-Object {$_.Name}) -contains $ModuleName)
		{
			$ModuleLoaded = $true
		}
		else
		{
			$LoadAsSnapin = $true
		}
	}
	else
	{
		$LoadAsSnapin = $true
	}

	if ($LoadAsSnapin)
	{
		if ((Get-PSSnapin -Registered | ForEach-Object {$_.Name}) -contains $ModuleName)
		{
			Add-PSSnapin $ModuleName
			if ((Get-PSSnapin | ForEach-Object {$_.Name}) -contains $ModuleName)
			{
				$ModuleLoaded = $true
			}
		}
		elseif ((Get-PSSnapin | ForEach-Object {$_.Name}) -contains $ModuleName)
		{
			$ModuleLoaded = $true
		}
	}
}

function sync-folderswiths3($secret, $key, $rootlocalFolderPath, $folders, $bucketPath) {
	#import-module powerupfilesystem
	
	#$logFilePath = [System.IO.Path]::GetTempFileName()	
	#Write-Host "Logging to $logFilePath"	
	#Set-Logging –LogPath $logFilePath -LogLevel info
	SyncFoldersWithS3 $secret $key $rootlocalFolderPath $folders $bucketPath
	#Write-Host "Log for activity ($logFilePath):"
	#Write-FileToConsole $logFilePath		
	#Remove-Item $logFilePath -force
}


function SyncFoldersWithS3($secret, $key, $rootlocalFolderPath, $folders, $bucketPath) {	
	$folderNames = $folders.split(';')
	if (!$folderNames)
	{
		$folderNames = @($folders)
	}
	
	Set-CloudOption -PermissionsInheritance "inheritall"
	$s3 = Get-CloudS3Connection -Key $key -Secret $secret
	
	foreach ($folder in $folderNames)
	{
		$destination
		try {
			$destination = $s3 | Select-CloudFolder -Path $bucketPath/$folder
		}
		catch {
			$destination = $s3 | Select-CloudFolder -path $bucketPath | Add-CloudFolder $folder
		}
		$src = Get-CloudFilesystemConnection | Select-CloudFolder $rootlocalFolderPath\$folder
	
		Write-Host "Copying all files in $rootlocalFolderPath\$folder to $bucketPath/$folder"
		$src | Copy-CloudSyncFolders $destination -IncludeSubfolders -ExcludeFiles "*.tmp" -ExcludeFolders "temp"
		#Write-Host "Enabling all files in $bucketPath for public read"
		#$s3 | Select-CloudFolder $bucketPath | Add-CloudItemPermission -UserName "All Users" -Read -Descendants
	}
	
	$s3 = $null	
}

export-modulemember -function install-CloudBerry, sync-folderswiths3