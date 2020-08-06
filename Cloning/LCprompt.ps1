#Basic cloning script with prompts.  You must be connected to vCenter first before you begin the operation.  

$CloneBaseName = Read-Host -Prompt "Input clone base name"
$CloneTotalCount = Read-Host -Prompt "Input the number of clones you want to make"
$sourcevm = Read-Host -Prompt "What is the source VM?"
$snap = Read-Host -Prompt "What is the snapshot name?"
$custspec = Read-Host -Prompt "What is the Guest Customization Spec?"
$RP = Read-Host -Prompt "Which resource pool do you want to use?"

    Foreach ($i in 1..$CloneTotalCount) {
        $CloneName = $CloneBaseName+$i
        
        New-VM -VM $sourcevm -ResourcePool $RP -Name $CloneName -Datastore vSandatastore -LinkedClone:$true -ReferenceSnapshot $snap -OSCustomizationSpec $custspec
        
        Write-Host "$CloneName created, initiating boot"

        Start-VM -VM $CloneName
    }

Start-Sleep -seconds 60

Get-VM $CloneBaseName* | select name, Powerstate, @{N="IPAddress"; E={$_.Guest.IPAddress[0]}}, @{N="DnsName"; E={$_.ExtensionData.Guest.Hostname}}


