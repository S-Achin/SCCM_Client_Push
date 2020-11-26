$user = $env:USERNAME
$path = "C:\Users\$user\Desktop\"
Do
{
$ListOrManual = Read-Host "Would you like to run the script using an input list or manual entry? (L)ist/(M)anual"
if ($ListOrManual -eq 'L') 
{
$TestList = Test-Path $path\Machines.txt 
if ($TestList)
{
$Date = Get-Date -Format yyyy.MM.dd-HH.mm.ss
Rename-Item -Path $path\\Success.txt -NewName Success-$Date.txt -ErrorAction SilentlyContinue
Rename-Item -Path $path\\Failure.txt -NewName Failure-$Date.txt -ErrorAction SilentlyContinue
$PSExec = ("$path\PsExec.exe")
$ComputersList = Get-Content $path\Machines.txt
$ComputersCount = $ComputersList.Count
Write-Host "You are attempting to install the SCCM client on " -NoNewLine; Write-Host "$ComputersCount devices." -ForegroundColor Yellow
$Confirm = Read-Host "Are you sure you want to proceed? Y/N"
if ($Confirm -eq 'Y')
{
$FailureCount = 0
$SuccessCount = 0
foreach ($Computer in $ComputersList)
{
Write-Host "Running Job on $Computer"
&$PSExec -s \\$Computer cmd /c \\Server1\share$\SCCMCLIENT.Bat | Out-Null
if ($LastExitCode -Eq 0)
{
$Computer | Out-File -Encoding ascii -Append $path\Success.txt
Write-Host "CM installation " -NoNewLine; Write-Host "was successfully launched" -ForegroundColor Green -NoNewLine; Write-Host " on $Computer"
Write-Host "--------------------------------------------------"
$SuccessCount++
}
else
{
$Computer | Out-File -Encoding ascii -Append $path\Failure.txt
Write-Host "CM installation " -NoNewLine; Write-Host "could not be launched" -ForegroundColor Red -NoNewLine; Write-Host " on $Computer"
Write-Host "--------------------------------------------------"
$FailureCount++
}

}
Write-Host "Finished executing on " -NoNewLine; Write-Host "$ComputersCount devices:" -ForegroundColor Yellow -NoNewLine; Write-Host " $SuccessCount installation(s) succeeded, " -ForegroundColor Green -NoNewLine; Write-Host "$FailureCount installation(s) failed." -ForegroundColor Red
Pause
}
else
{
Write-Host "SCCM client installation aborted by user!"
Pause
}
}
else
{
Write-Host "The Machines.txt list is missing. Make sure the file exists and is populated." 
Pause
}
}
if ($ListOrManual -eq 'M')
{
$Target = Read-Host "Please input target machine name" 

$PSExec = ("$path\PsExec.exe")
&$PSExec -s \\$Target cmd /c \\Server1\share$\sccMCLIENT.Bat | Out-Null
if ($LastExitCode -Eq 0)
{
Write-Host "SCCM installation " -NoNewLine; Write-Host "was successfully launched" -ForegroundColor Green -NoNewLine; Write-Host " on $Target"
Write-Host "--------------------------------------------------"
}
else
{
Write-Host "SCCM installation " -NoNewLine; Write-Host "could not be launched" -ForegroundColor Red -NoNewLine; Write-Host " on $Target"
Write-Host "--------------------------------------------------"
}
Pause
}
if ($ListOrManual -ne "L" -and $ListOrManual -ne "M")
{
Write-Host "Incorrect selection made. Please input either 'L' to use a list or 'M' for manual entry ..."
}
$Retry = Read-Host "Would you like to run the script again? Y/N"
}
While ($Retry -eq 'Y')

Write-Host "Have a good day!"
Pause
