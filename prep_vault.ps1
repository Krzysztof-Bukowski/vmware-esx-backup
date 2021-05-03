#!!!WARNING!!! this will clear vault configuration. !!!WARNING!!!
Remove-Item .\creds.xml -ErrorAction SilentlyContinue
Reset-SecretStore -Scope CurrentUser -Authentication None -PasswordTimeout -1 -Interaction None -Force
Set-SecretStoreConfiguration -Scope CurrentUser -Authentication None -PasswordTimeout -1 -Interaction None -Confirm:$false -ErrorAction SilentlyContinue
#unRegister-SecretVault vault_name

$vault_name = Read-Host "Enter vault name"

#password for decrypt a vault
$Creds = Read-Host "Enter vault Password"  -AsSecureString #-MaskInput
$Creds | Export-Clixml -Path .\creds.xml
$SecurePasswordPath = ".\creds.xml"

#Install the SecretManagement and SecretStore PowerShell modules.
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -Repository PSGallery
$password = Import-CliXml -Path $SecurePasswordPath

#Create vault
Set-SecretStoreConfiguration -Scope CurrentUser -Authentication Password -PasswordTimeout 3600 -Interaction None -Password $password -Confirm:$false
Register-SecretVault -Name $vault_name -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault -AllowClobber
Unlock-SecretStore -Password $password

$a = 'null'

#Feed store
do
{
 clear-Variable -Name "a"
 $hostname = Read-Host "valid fqdn or ip:"
 $login = Read-Host "Login:" -MaskInput
 $pass = Read-Host "Pass:" -MaskInput
 $date = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
 Set-Secret -name $hostname -Vault $vault_name -Secret @{ login = "$login"; password = "$pass"}  -Metadata @{creation_date = "$date"; purpose = "powercli-esx-backup"}

 $a = Read-Host "Add next host? 'no' to exit"
} until($a -eq "no")

Write-Host "Summary, Secrets in vault"
Get-SecretInfo -Vault $vault_name | Select-Object Name,Metadata

#clear variables
clear-Variable -Name "a", "SecurePasswordPath", "password", "vault_name", "pass", "login" 
