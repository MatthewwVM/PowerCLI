
Write-Host -BackgroundColor Black -ForegroundColor Green "Checking if lab is already off"

[String[]]$vcpingcheck = ping van-vc-01.webblab.local
$vcpingreply = $vcpingcheck[2] -match "Reply"

if ($vcpingreply -eq $true) {

    Write-Host "vCenter ping replied, shutting down lab!"

  
}else {

    Write-Host "vCenter is already off, exiting script"

    Start-Sleep -Seconds 10
    
    exit 

}

$password = Get-Content "C:\ssc\vcenter.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential("Administrator@vsphere.local",$password)

Connect-viserver -server van-vc-01.webblab.local -Credential $credential

$vCenterVM = Get-VM -name "VAN-VC-02"

$onVMs = get-vm -location vSANcluster | Where-Object {$_.PowerState -eq "poweredon"} | Where-Object {$_.Name -ne "VAN-VC-02"}

Move-VM "$vCenterVM" -destination pe-esx-40.webblab.local
#update to check for tools and force stop or graceful shut down

    get-vm -location vSANcluster | Where-Object {$_.PowerState -eq "poweredon"} | Where-Object {$_.Name -ne "VAN-VC-02"} | Stop-VMGuest -confirm:$false | Out-Null

    foreach ($vms in $onVMs) {

        Write-Host -background black -foreground green "$vms shutting down"
            do {
                
            Write-Host -background black -foreground blue "." -NoNewLine
    
            Start-Sleep -seconds 1
    
            $psvm = Get-VM -name $vms
    
        }   until ($psvm.PowerState -eq "Poweredoff") 
        
        Write-Host -BackgroundColor Black -ForegroundColor Green "*"

        Write-Host -background black -foreground green "$vms confirmed off"
    
        }
     Disconnect-viserver -confirm:$false


    $ESXiR = Get-Content "C:\ssc\ESXi.txt" | ConvertTo-SecureString
    $ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)
    $vCenterVM = "VAN-VC-02"

    Connect-viserver -server pe-esx-40.webblab.local -Credential $ESXiC

    Get-VM -name "$vCenterVM" | Stop-VMGuest -confirm:$false

    do {
        
        Write-Host -background black -foreground blue "." -NoNewLine

        Start-Sleep -seconds 1

        $vcenter = Get-VM -name "VAN-VC-02"

    } until ($vCenter.Powerstate -eq "Poweredoff")

    Write-Host -background black -foreground green "$vCenterVM is shut down, moving hosts to MM"

    Disconnect-viserver -confirm:$false

    $vSANnodes = ("pe-esx-10.webblab.local", "pe-esx-20.webblab.local", "pe-esx-30.webblab.local", "pe-esx-40.webblab.local")
    $ESXiR = Get-Content "C:\ssc\esxi.txt" | ConvertTo-SecureString
    $ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)

    foreach ($vSANhost in $vSANnodes) {
        Connect-viserver -server $vSANhost -Credential $ESXiC

        Set-VMHost -State Maintenance -VsanDataMigrationMode NoDataMigration | Out-Null

        Write-Host -background black -foreground green "$vSANhost has been put in MM"

        disconnect-viserver -confirm:$false

            }

    $vSANnodes = ("pe-esx-10.webblab.local", "pe-esx-20.webblab.local", "pe-esx-30.webblab.local", "pe-esx-40.webblab.local")
    $ESXiR = Get-Content "C:\Passwords\esxir.txt" | ConvertTo-SecureString
    $ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)    
    
    foreach ($poweroff in $vSANnodes) {
        Connect-viserver -server $poweroff -credential $ESXiC

        Write-Host -background black -foreground green "initiating shutdown of $poweroff"
        
        Stop-VMhost -confirm:$false | Out-Null
        
        Disconnect-viserver -confirm:$false

    }

