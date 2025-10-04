$global:version = "1.0.0"

$ascii = @"

.____                        .__            .____          ___.     _________       __                
|    |    ____   ____ _____  |  |           |    |   _____ \_ |__  /   _____/ _____/  |_ __ ________  
|    |   /  _ \_/ ___\\__  \ |  |    ______ |    |   \__  \ | __ \ \_____  \_/ __ \   __\  |  \____ \ 
|    |__(  <_> )  \___ / __ \|  |__ /_____/ |    |___ / __ \| \_\ \/        \  ___/|  | |  |  /  |_> >
|_______ \____/ \___  >____  /____/         |_______ (____  /___  /_______  /\___  >__| |____/|   __/ 
        \/          \/     \/                       \/    \/    \/        \/     \/           |__|    

~ Created with <3 by @nickvourd
- Edited by DMCXBLUE 
~ Version: $global:version
~ Type: UnquotedServicePath
- Will work on Domain Joined Computers

"@

Write-Host $ascii`n

# Find Domain

$Domain = (Get-ComputerInfo).CsDomain

# Set the path for the folder
$folderPath = "C:\Program Files\Vulnerable Service1\Service Binary\"

# Create the folder if it doesn't exist
if (-not (Test-Path $folderPath)) {
    mkdir C:\Program` Files\Vulnerable` Service1\Service` Binary\
    Write-Host "`n[+] Folder created successfully at $folderPath`n"
} else {
    Write-Host "[+] Folder already exists at $folderPath`n"
}

Write-Host "[+] Set new file to Service folder`n"
# Set the URLs of the files to download
$urlBinary = "https://raw.githubusercontent.com/nickvourd/Windows-Local-Privilege-Escalation-Cookbook/master/Lab-Setup-Binary/Service%201.exe"  

# Download Service executable
Invoke-WebRequest -Uri $urlBinary -OutFile "$folderPath\Service1.exe"

Write-Host "[+] Granting write privileges to BUILTIN\Users for the folder`n"
# Grant write privileges to BUILTIN\Users for the folder
cmd /c icacls "C:\Program Files\Vulnerable Service1\Service Binary" /grant "blume\Domain Users:(W)"

# The previous command ony worked for local accounts, this fixes the Domain Users issue

takeown /f "C:\Program Files" /r /d y
cmd /c icacls "C:\Program Files" /grant "$Domain\Domain Users:(W)"

# Now the folder
takeown /f "C:\Program Files\Vulnerable Service1" /r /d y
cmd /c icacls "C:\Program Files" /grant "$Domain\Domain Users:(W)"

# Now the binary
cmd /c icacls "C:\Program Files\Vulnerable Service1\Service Binary\Service1.exe" /grant "$Domain\Domain Users:(F)"


Write-Host "[+] Installing the Service 1`n"
# Install the Service 1
New-Service -Name "Vulnerable Service 1" -BinaryPathName "C:\Program Files\Vulnerable Service1\Service1.exe" -DisplayName "Vuln Service 1" -Description "My Custom Vulnerable Service 1" -StartupType Automatic

Write-Host "[+] Editing the permissions of the Service 1"
# Edit the permissions of the Service 1
cmd.exe /c 'sc sdset "Vulnerable Service 1" D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)(A;;RPWP;;;BU)'
