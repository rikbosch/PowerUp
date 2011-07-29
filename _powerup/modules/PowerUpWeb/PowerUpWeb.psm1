$ModuleName = "CommonDeploy"

$sitesPath = "IIS:\sites"
$appPoolsPath = "IIS:\apppools"
$bindingsPath = "IIS:\sslbindings"

function ReplaceDirectory([string]$sourceDirectory, [string]$destinationDirectory)
{
	if (Test-Path $destinationDirectory -PathType Container)
	{
		Write-Host "Removing folder"
		Remove-Item $destinationDirectory -recurse -force
	}
	Write-Host "Copying files"
	Copy-Item $sourceDirectory\ -destination $destinationDirectory\ -container:$false -recurse -force
}

function RobocopyDirectory([string]$sourceDirectory, [string]$destinationDirectory)
{
	Write-Host "copying newer files from $sourceDirectory to $destinationDirectory"
	.\_powerup\robocopy.exe /E /np /njh /nfl /ns /nc $sourceDirectory $destinationDirectory 
	
	if ($lastexitcode -lt 8)
	{
		Write-Host "Successfully copied to $destinationDirectory "
		cmd /c #reset the lasterrorcode strangely set by powershell to be non-0
	}		
}

function Copy-MirroredDirectory([string]$sourceDirectory, [string]$destinationDirectory)
{
	Write-Host "Mirroring $sourceDirectory to $destinationDirectory"
	.\_powerup\robocopy.exe /E /np /njh /nfl /ns /nc /mir $sourceDirectory $destinationDirectory 
	
	if ($lastexitcode -lt 8)
	{
		Write-Host "Successfully mirrored to $destinationDirectory "
		cmd /c #reset the lasterrorcode strangely set by powershell to be non-0
	}
}

function StopAppPoolAndSite($appPoolName, $siteName)
{
	StopAppPool($appPoolName)
	StopSite($siteName)
}

function StartAppPoolAndSite($appPoolName, $siteName)
{
	StartSite($siteName)
	StartAppPool($appPoolName)
}

function StopSite($siteName)
{	
	StopWebItem $sitesPath $siteName
}

function StopAppPool($appPoolName)
{	
	StopWebItem $appPoolsPath $appPoolName
}

function StartSite($siteName)
{	
	StartWebItem $sitesPath $siteName
}

function StartAppPool($appPoolName)
{	
	StartWebItem $appPoolsPath $appPoolName
}

function CreateAppPool($appPoolName)
{	
	if (!(WebItemExists $appPoolsPath $appPoolName))
	{
		New-WebAppPool $appPoolName
	}
}

function DeleteAppPool($appPoolName)
{	
	if (WebItemExists $appPoolsPath $appPoolName)
	{
		Remove-WebAppPool $appPoolName
	}
}

function DeleteWebsite($websiteName)
{	
	if (WebItemExists $sitesPath $websiteName)
	{
		Remove-WebSite $websiteName
	}
}



function SetAppPoolProperties($appPoolName, $pipelineMode, $runtimeVersion)
{
	$appPool = Get-Item $appPoolsPath\$appPoolName
	SetAppPoolManagedPipelineMode $appPool $pipelineMode
	SetAppPoolManagedRuntimeVersion $appPool $runtimeVersion
	$appPool | set-item
}

function SetAppPoolManagedPipelineMode($appPool, $pipelineMode)
{
	$appPool.managedPipelineMode = $pipelineMode
}

function SetAppPoolManagedRuntimeVersion($appPool, $runtimeVersion)
{
	$appPool.managedRuntimeVersion = $runtimeVersion
}

function RecreateAppPool($appPoolName, $pipelineMode, $runtimeVersion)
{
	DeleteAppPool $appPoolName
	CreateAppPool $appPoolName
	SetAppPoolProperties $appPoolName $pipelineMode $runtimeVersion
}

function RecreateWebsite($websiteName, $appPoolName, $fullPath, $protocol, $ip, $port, $hostHeader)
{
	DeleteWebsite $websiteName
	CreateWebsite $websiteName $appPoolName $fullPath $protocol $ip $port $hostHeader
}

function CreateWebsite($websiteName, $appPoolName, $fullPath, $protocol, $ip, $port, $hostHeader)
{		
	echo "Creating site $websiteName"
	
	New-Item $sitesPath\$websiteName -physicalPath $fullPath -applicationPool $appPoolName -bindings @{protocol="http";bindingInformation="${ip}:${port}:${hostHeader}"}
}

function SetAppPoolIdentityToUser($appPoolName, $userName, $password)
{
	echo "Setting $appPoolName to be run under $userName"
	$appPool = Get-Item $appPoolsPath\$appPoolName
	$appPool.processModel.username =  $userName
	$appPool.processModel.password = $password
	$appPool.processModel.identityType = 3
	$appPool | set-item
	
}

function AddApplication($websiteName, $appPoolName, $subPath, $physicalPath)
{
	New-Item $sitesPath\$websiteName\$subPath -physicalPath $physicalPath -applicationPool $appPoolName -type Application 
}

function EnsureSelfSignedSslCertificate($certName)
{	
	if(!(GetSslCertificate $certName))
	{
		.\_powerup\makecert -r -pe -n "CN=${certName}" -b 07/01/2008 -e 07/01/2020 -eku 1.3.6.1.5.5.7.3.1 -ss my -sr localMachine -sky exchange -sp "Microsoft RSA SChannel Cryptographic Provider" -sy 12
	}
}

function GetSslCertificate($certName)
{
	Get-ChildItem cert:\LocalMachine\MY | Where-Object {$_.Subject -match "${certName}"} | Select-Object -First 1
}

function EnsureSslBinding($certName, $ip, $port)
{
	echo "fetching cert"
	$certificate = GetSslCertificate $certName
	
	if (!$certificate) {throw "Certificate for site $certName not in current store"}

	if($ip -eq "*") {$ip = "0.0.0.0"}
	
	if(!(SslBindingExists $ip $port))
	{
		echo "creating new binding"
		CreateSslBinding $certificate $ip $port
	}
	
	echo "ssl binding complete"
}

function SslBindingExists($ip, $port)
{
	return ((dir IIS:\sslbindings | Where-Object {($_.Port -eq $port) -and ($_.IPAddress -contains $ip)}) | measure-object).Count -gt 0
}

function CreateSslBinding($certificate, $ip, $port)
{
	$existingPath = get-location
	set-location $bindingsPath
	
	echo "${ip}!${port}"
	$certificate | new-item "${ip}!${port}"
	set-location $existingPath
}

function AddBinding($websiteName, $protocol, $ip, $port, $hostHeader)
{
	echo "add binding for $websiteName, $protocol, $ip, $port, $hostHeader"
	New-WebBinding -Name $websiteName -IP $ip -Port $port -Protocol $protocol -HostHeader $hostHeader
}

function StopWebItem($itemPath, $itemName)
{
	if (WebItemExists $itemPath $itemName)
	{
		$state = (Get-WebItemState $itemPath\$itemName).Value
		Write-Host "$itemName is $state"
		if ($state -eq "started")
		{
			Stop-WebItem $itemPath\$itemName
			Write-Host "Stopped $itemName"
		}
	}
}
  
function StartWebItem($itemPath, $itemName)
{
	if (WebItemExists $itemPath $itemName)
	{
		$state = (Get-WebItemState $itemPath\$itemName).Value
		Write-Host "$itemName is $state"
		if ($state -eq "stopped")
		{
			Start-WebItem $itemPath\$itemName
			Write-Host "Started $itemName"
		}
	}
}

function WebItemExists($rootPath, $itemName)
{
	return ((dir $rootPath | ForEach-Object {$_.Name}) -contains $itemName)	
}

function MigrateDatabase([string]$connectionString, [string]$migrationsAssemblyPath)
{	
	echo "connectionString: $connectionString"
	echo "migrationsAssemblyPath: $migrationsAssemblyPath"
	push-databasemigrations -ConnectionString $connectionString -MigrationsAssemblyPath $migrationsAssemblyPath -Provider SqlServer2005  -DryRun $true -To -1
}


$ModuleName = "WebAdministration"
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