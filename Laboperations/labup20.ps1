Write-Host -BackgroundColor Black -ForegroundColor Green "Checking if lab is already on"

[String[]]$vcpingcheck = ping van-vc-01.webblab.local
$vcpingreply = $vcpingcheck[2] -match "Reply"

if ($vcpingreply -eq $false) {

    Write-Host "vCenter ping failed, booting up lab!"

  
}else {

    Write-Host "vCenter is already on, exiting script"

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
Start-Sleep -s 1800

$vSANnodes = ("pe-esx-10.webblab.local", "pe-esx-20.webblab.local", "pe-esx-30.webblab.local", "pe-esx-40.webblab.local")
$ESXiR = Get-Content "C:\Passwords\esxir.txt" | ConvertTo-SecureString
$ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)

foreach ($nodes in $vSANnodes) {
    
    Connect-viserver -server $nodes -credential $ESXiC | Out-Null
    
    Set-VMHost -State "Connected" -confirm:$false | Out-Null

    Disconnect-VIServer -confirm:$false | Out-Null

}

Start-Sleep -s 60

$password = Get-Content "C:\Passwords\vCenter.txt" | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PSCredential("Administrator@vsphere.local",$password)
$ESXiR = Get-Content "C:\Passwords\esxir.txt" | ConvertTo-SecureString
$ESXiC = New-Object System.Management.Automation.PSCredential("root",$ESXiR)

    Connect-viserver -server pe-esx-40.webblab.local -credential $ESXiC | Out-Null

    Get-VM -name "VAN-VC-02" | Start-VM -confirm:$false

    Disconnect-VIServer -confirm:$false

    Write-Host -ForegroundColor Green -BackgroundColor Black "Starting sleep to allow vCenter to boot"
    
    Start-Sleep -Seconds 900

    Connect-viserver -server van-vc-01.webblab.local -credential $credential

    get-vm -location vSANcluster | Where-Object {$_.PowerState -eq "poweredoff"} | Start-VM



    





