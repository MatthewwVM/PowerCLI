# grab temps, convert to a string
[string[]]$testok = racadm -r 192.168.20.40 -u root -p calvin getsensorinfo

# grab the index that we care about
$conv = $testok[34]

$res = $conv -match "Warning"

if ($res -eq $False) {
    $time = Get-Date -Format "ddd MM/dd/yyyy HH:mm K"
    
    "$time ; $conv" | Out-File -FilePath C:\pslogs\temp\templogs.txt -Append
    
}elseif ($res -eq $True) {
    $time = Get-Date -Format "ddd MM/dd/yyyy HH:mm K"

    "TEMP ABOVE 100 F, STARTING SHUT DOWN; $time; $conv" | Out-File -FilePath C:\pslogs\temp\templogs.txt -Append
    #Log elseif to txt file
    C:\powershell\labdown20.ps1
    
}else {
    #log elseif to txt file
    "Job Failed at $time ; $conv" | Out-File -FilePath C:\pslogs\temp\templogs.txt -Append
}