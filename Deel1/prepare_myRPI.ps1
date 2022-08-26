############################################
# Variables
$File = "firstrun.sh"
$ContentFile = "content.txt" #I put this in a seperate file to make it a bit more clearly
$ExtraScript = "config_update.sh"
$TestingLocaly = $true
############################################

############################################
#Path and File stuff

if($TestingLocaly){
    $FullPathDrive = $(Get-Location).ToString()
}

else
{
    $BootDriveLetter = Get-Volume -FileSystemLabel "boot" | % DriveLetter #(2.1)Searches for the "boot" volume and gives the drive letter
    $FullPathDrive = $BootDriveLetter + ":\" #Makes it a "full path" and not just a letter from the drive.
}


$FullPath = ($FullPathDrive + "\" + $File) #Full Path to the file
Write-Debug $FullPath

if(!(Test-Path $FullPath)) {
    Write-Output "Firstrun.sh file does not exist. Please add it to the boot folder or run the raspberry pi disk imager again with the advanced options!"
    Exit 1
}

############################################


############################################
#Before doing anything, make a back up file.
Copy-Item $FullPath -Destination ($FullPath + ".bak")
############################################



############################################
#Locate the right location and insert everything from the contentfile into the firstrun file 
try{


    $ContentOfFile = Get-Content $FullPath
    $Content = Get-Content $ContentFile
    $Line = Select-String -Path $File -Pattern "rm -f /boot/firstrun.sh" -SimpleMatch | % {$_.LineNumber} # Searches for "rm -f /boot/firstrun.sh" and gives back the line where it's located because it needs to insert before those lines. 
    if(($ContentOfFile | Select-String -Pattern $Content) -eq $null) #Looks if content file is already inserted into firstrun or not. If it is just do nothing.
    {

        foreach ($Data in $Content)
        {
            $ContentOfFile[$Line-2] += "`n$Data"
        }
        $ContentOfFile | Set-Content $FullPath
        Write-Output "Done insterting content"   
    }
	
############################################
#(3.2) Copies config_update.sh to the boot partition of the SD card 
	if(!(Test-Path -Path $FullPathDrive + "\" +  $ExtraScript)) #Check if the file already exist otherwise don't copy it. (Niet bevuilen)
	{
		Copy-Item $ExtraScript -Destination $FullPathDrive
	}
############################################
}



#If something went wrong just replace everything with the backup file
catch{
    if(Test-Path $FullPath) {
        Remove-Item $FullPath
        Copy-Item ($FullPath + ".bak") -Destination $FullPath
    }
}
############################################

#After everything is done, do the following > only unmounting in this case.
finally{
#(2.2.2) Unmount de drive.
	Remove-PSDrive -Name $BootDriveLetter -Force
}
