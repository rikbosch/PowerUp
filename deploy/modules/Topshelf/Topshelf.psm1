Function Ensure-Topshelf-Service([string]$serviceName, [string]$servicePath,[string]$instance,[string]$user=$null,[string]$password=$null){
    $OSServiceName = "${serviceName}`$${instance}"
	
	$service = get-service $OSServiceName -ErrorAction SilentlyContinue 
    if ($service –ne $null){
        "$serviceName is already installed on this server";
    }
    else{
        Write-Host "Installing $serviceName...";

		if($user -eq $null){
        & $servicepath install -instance:$instance --sudo
		}
		else{
			& $servicepath install -instance:$instance -username:$user -password:$password --sudo
		}
    }
}

Export-ModuleMember -function Ensure-Topshelf-Service