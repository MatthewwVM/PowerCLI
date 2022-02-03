
#example login through connect-viserver
Connect-VIServer -server 10.10.10.2 -Credential $credential

$Cluster = Get-Cluster -Name "Cluster-1"
$r5sp = Get-SpbmStoragePolicy -Name "FTT=1 _Erasure"
$r1sp = Get-SpbmStoragePolicy -Name "vSAN Default Storage Policy"
$r5objects = Get-SpbmEntityConfiguration -StoragePolicy $r5sp

if ($r5objects -ne $null ) {

    foreach ($oldobject in $r5objects) {
    
        Write-Host "Updating Storage Policy for $oldobject" -ForegroundColor "Yellow"
    
        Set-SPBMEntityConfiguration -Configuration $OldObject -StoragePolicy $r1sp
    
        Write-Host "Updated Storage Policy for $oldobject, now waiting for resyncs to complete" -ForegroundColor "green"
        
            While ((Get-VsanResyncingComponent -Cluster $Cluster)) { 
    
            Write-Host "." -ForegroundColor "DarkYellow" -NoNewline   
        }  
        
        Write-Host "* " -ForegroundColor "Green"    
        
        Write-Host "Resyncs for $oldobject Complete" -ForegroundColor Cyan
        }
    
} else {
    
    Write-Host -ForegroundColor Green -BackgroundColor Black "No objects are erasure coded"

}


       

      
    
    

    




