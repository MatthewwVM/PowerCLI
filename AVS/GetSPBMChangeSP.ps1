
#This is a script to help make bulk changes to storage policies in an AVS vCenter.  You can read more about how and why here: https://dinocloud.net/2022/02/04/managing-vsan-policies-in-azure-vmware-solution/
#This script assumes you are already conected to a vCenter server through Powercli

#Create our storage policy variables, we are gathering all the VM's on a give storage policy so we can change them
$VMobjTOchange = Read-Host "Enter the name of the VM's storage policy you would like to change (this will take all VM's of that given storage policy.)"
$ChangeVMto = Read-Host "What storage policy would you like the VM's to change to?"
$VMobjofSP = Get-SpbmEntityConfiguration -StoragePolicy "$VMobjTOchange"
$Cluster = "Cluster-1"

#Identify if the storage policy given has any VM's
if ($VMobjofSP -ne $null ) {
    #If there are objects, iterate through each object and change them.  This will allow objects to rebuild before moving to next object
    foreach ($VMobjs in $VMobjofSP) {
    
        Write-Host "Updating Storage Policy for $VMobjs" -ForegroundColor "Yellow"
    
        Set-SPBMEntityConfiguration -Configuration $VMobjs -StoragePolicy $ChangeVMto
    
        Write-Host "Updated Storage Policy for $VMobjs, now waiting for resyncs to complete" -ForegroundColor "green"
        
            While ((Get-VsanResyncingComponent -Cluster $Cluster)) { 
    
            Write-Host "." -ForegroundColor "DarkYellow" -NoNewline   
        }  
        
        Write-Host "* " -ForegroundColor "Green"    
        
        Write-Host "Resyncs for $VMobjs Complete" -ForegroundColor Cyan
        }
    
} else {
    
    Write-Host -ForegroundColor Green -BackgroundColor Black "No VM objects are on the $VMobjTOchange storage policy"

}


       

      
    
    

    




