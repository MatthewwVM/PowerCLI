$password = Get-Content "C:\Users\mattheww\SP\vCenter.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential("Administrator@vsphere.local",$password)

Connect-viserver -server van-vc-01.webblab.local -Credential $credential

$Cluster = Get-Cluster -Name "vSANCluster"
$r5sp = Get-SpbmStoragePolicy -Name "FTT=1 _Erasure"
$r1sp = Get-SpbmStoragePolicy -Name "FTT=1_Mirroring"
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


       

      
    
    

    




