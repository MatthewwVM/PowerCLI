Write-Host -BackgroundColor Black -ForegroundColor Green "Checking if lab is already on"

[String[]]$vcpingcheck = ping van-vc-01.webblab.local
$vcpingreply = $vcpingcheck[2] -match "Reply"

if ($vcpingreply -eq $false) {

    Write-Host -BackgroundColor Black -ForegroundColor Green "vCenter ping failed, booting up lab!"

  
}else {

    Write-Host -BackgroundColor Black -ForegroundColor Green "vCenter is already on, exiting script"

    Start-Sleep -Seconds 10
    
    exit 

}

$iDracUser = "root"
$iDracPass = "calvin"
$iDracAddresses = ("192.168.20.10","192.168.20.20","192.168.20.30","192.168.20.40")
    
Foreach ($iDrac in $iDracAddresses) {
    racadm -r $iDrac -u $iDracUser -p $iDracPass serveraction powerup | Out-Null
    Write-Host "Poweron sent to iDrac $iDrac"
    Get-Date
}

Write-Host -ForegroundColor Green -BackgroundColor Black "Starting 15 minutes of sleep to allow boot"
Start-Sleep -s 0

$vSANnodes = ("pe-esx-10.webblab.local", "pe-esx-20.webblab.local", "pe-esx-30.webblab.local", "pe-esx-40.webblab.local")
$ESXiR = Get-Content "C:\ssc\ESXi.txt" | ConvertTo-SecureString
$ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)

foreach ($vsnode in $vSANnodes) {
    do {

        $connecttest = Connect-VIServer -Server $vsnode -Credential $ESXiC

        Write-Host -BackgroundColor Black -ForegroundColor Green "Attempting to connect to $vsnode"

        Start-Sleep -Seconds 30
                
    } until ($connecttest.IsConnected -eq $true)
}

Disconnect-VIServer -Server * -Confirm:$false

foreach ($nodes in $vSANnodes) {

    Connect-VIServer -server $nodes -credential $ESXiC | Out-Null
    
    Set-VMHost -State "Connected" -confirm:$false | Out-Null

    Write-Host -BackgroundColor Black -ForegroundColor Green "$nodes has exited MM..."

    Disconnect-VIServer -confirm:$false | Out-Null

}

Start-Sleep -s 60

$password = Get-Content "C:\ssc\vcenter.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential("Administrator@vsphere.local",$password)
$ESXiR = Get-Content "C:\ssc\ESXi.txt" | ConvertTo-SecureString
$ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)

    Connect-VIServer -server pe-esx-40.webblab.local -credential $ESXiC | Out-Null

    Get-VM -name "VAN-VC-02" | Start-VM -confirm:$false

    Disconnect-VIServer -confirm:$false

    Write-Host -ForegroundColor Green -BackgroundColor Black "vCenter is booting..."
    
    do {
        
        $vcconnect = Connect-VIServer -Server van-vc-01.webblab.local -Credential $credential

        Write-Host -BackgroundColor Black -ForegroundColor Green "Attempting to connect to vCenter"
        
    } until ($vcconnect.IsConnected -eq $true)

    Write-Host -BackgroundColor Black -ForegroundColor Green "Connected to vCenter, starting all VM's"

    Get-VM -location vSANcluster | Where-Object {$_.PowerState -eq "poweredoff"} | Start-VM



    





