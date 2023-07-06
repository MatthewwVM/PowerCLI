# Connect to the vCenter server
Connect-VIServer -Server vcsa.globex.zpod.io -User administrator@globex.zpod.io -Password <password>
Connect-VIServer -Server 10.29.0.2 -User cloudadmin@vsphere.local -Password <password>

# Specify the hostname of the VM you want to search for
$vmHostname = "WIN-WEB.webblab.lab"

# Search for the VM by hostname
$vm = Get-VM | Where-Object { $_.Guest.Hostname -eq $vmHostname }

if ($vm) {
    # Retrieve the name of the vCenter server
    $vCenter = (Get-VMHost -VM $vm)
    $vCentercluster = $vCenter.Parent

    Write-Host "VM with hostname '$vmHostname' is located on cluster '$vCentercluster'."
} else {
    Write-Host "VM with hostname '$vmHostname' not found."
}


# Disconnect from the vCenter server
Disconnect-VIServer -Server vcsa.globex.zpod.io -Confirm:$false
Disconnect-VIServer -Server 10.29.0.2 -Confirm:$false