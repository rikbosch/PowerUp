function Add-FontsInDirectory([string]$path)
{
	$FONTS = 0x14
	$windowsfontdir = "c:\windows\fonts" #had to hard-code this as there's no way to obtain this that I can see
	$objShell = New-Object -ComObject Shell.Application
	$windowsFontFolder = $objShell.Namespace($FONTS)	
	$fontinstalldir = dir $path		
	foreach($fontFile in $fontinstalldir) {
	  Write-Host $windowsfontdir\$fontFile
      if (!(Test-Path $windowsfontdir\$fontFile))
	  {
	    $windowsFontFolder.CopyHere($fontFile.fullname, 20) #this second parameter to hide the dialog seems to be ignored
	  }
    }
}

export-modulemember -function Add-FontsInDirectory