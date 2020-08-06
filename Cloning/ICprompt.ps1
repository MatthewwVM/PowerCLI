#Basic Instant Clone script with prompts.  You must have the in guest customization script and imported William Lam's New-InstantClone module that is also in this directory (InstantClone.PSM1).  
#Credit goes to William Lam!

$numOfVMs = Read-Host -Prompt "Input the number of clones you want to make"
$SourceVM = Read-Host -Prompt "What is the source VM?"
$ipStartingCount = 50
$ipNetwork = Read-Host -Prompt "What IP network do you want to use (format should be '192.168.30' or '10.10.10')"
$netmask = 255.255.255.0
$dns = Read-Host -Prompt "Enter DNS IP"
$gw = Read-Host -Prompt "Enter gateway ip"

$StartTime = Get-Date
foreach ($i in 1..$numOfVMs) {
    $newVMName = "IC-$i"
 
    $guestCustomizationValues = @{
        "guestinfo.ic.hostname" = "$newVMName"
        "guestinfo.ic.ipaddress" = "$ipNetwork.$ipStartingCount"
        "guestinfo.ic.netmask" = "$netmask"
        "guestinfo.ic.gateway" = "$gw"
        "guestinfo.ic.dns" = "$dns"
        "guestinfo.ic.sourcevm" = "$SourceVM"
    }
    $ipStartingCount++
    New-InstantClone -SourceVM $SourceVM -DestinationVM $newVMName -CustomizationFields $guestCustomizationValues
}
 
$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)
 
Write-Host -ForegroundColor Cyan  "`nTotal Instant Clones: $numOfVMs"
Write-Host -ForegroundColor Cyan  "StartTime: $StartTime"
Write-Host -ForegroundColor Cyan  "  EndTime: $EndTime"
Write-Host -ForegroundColor Green " Duration: $duration minutes"