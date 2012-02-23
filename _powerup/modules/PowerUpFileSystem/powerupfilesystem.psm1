
function Ensure-Directory([string]$directory)
{
	if (!(Test-Path $directory -PathType Container))
	{
		Write-Host "Creating folder $directory"
		New-Item $directory -type directory
	}
}

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
	& "$PSScriptRoot\robocopy.exe" /E /np /njh /nfl /ns /nc $sourceDirectory $destinationDirectory 
	
	if ($lastexitcode -lt 8)
	{
		Write-Host "Successfully copied to $destinationDirectory "
		cmd /c #reset the lasterrorcode strangely set by robocopy to be non-0
	}		
}

function Copy-MirroredDirectory([string]$sourceDirectory, [string]$destinationDirectory)
{
	Write-Host "Mirroring $sourceDirectory to $destinationDirectory"
	& "$PSScriptRoot\robocopy.exe" /E /np /njh /nfl /ns /nc /mir $sourceDirectory $destinationDirectory 
	
	if ($lastexitcode -lt 8)
	{
		Write-Host "Successfully mirrored to $destinationDirectory "
		cmd /c #reset the lasterrorcode strangely set by robocopy to be non-0
	}
	else
	{
		throw "Robocopy failed to mirror to $destinationDirectory. Exited with exit code $lastexitcode"
	}
}

function Write-FileToConsole([string]$fileName)
{	
	$line=""

	if ([System.IO.File]::Exists($fileName))
	{
		$streamReader=new-object System.IO.StreamReader($fileName)
		$line=$streamReader.ReadLine()
		while ($line -ne $null)
		{
			write-host $line
			$line=$streamReader.ReadLine()
		}
		$streamReader.close()		
	}
	else
	{
	   write-host "Source file ($fileName) does not exist." 
	}
}

Set-Alias Copy-Directory RobocopyDirectory

Export-ModuleMember -function Write-FileToConsole, Ensure-Directory, Copy-MirroredDirectory, RobocopyDirectory -alias Copy-Directory
