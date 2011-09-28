function import-settings($settings) 
{
    foreach($key in $settings.keys)
    {
		set-variable -name $key -value $settings.$key -scope global
    }	
}

Export-ModuleMember -function import-settings