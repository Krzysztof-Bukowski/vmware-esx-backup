#Repo location & retention
$repo= "/root/backup"
$retention =-14

#unlock vault
$securePasswordPath = ".\creds.xml"
$password = Import-CliXml -Path $securePasswordPath
Unlock-SecretStore -Password $password

# Create a new backup destination folder
$repo = Join-Path $repo (get-date).ToString('dd-MM-yyyy_HH-mm-ss');
New-Item -ItemType directory -Path $repo -Force;

#get fqdn or ip
$esx_ip = Get-SecretInfo | Select-Object -ExpandProperty Name

# Run the backup
foreach ($row in $esx_ip) {
    $esx_pass = Get-Secret -Vault $vault_name -Name $row -AsPlainText | Select-Object -ExpandProperty password
    $esx_login = Get-Secret -Vault $vault_name -Name $row -AsPlainText | Select-Object -ExpandProperty login
    Connect-VIServer $row -user $esx_login -password $esx_pass;
    Get-VMHostFirmware -vmhost $row -BackupConfiguration -DestinationPath $repo;
    Disconnect-VIServer $row -Force -Confirm:$false;
}


#Remove old backups
$limit_rem = (Get-Date).AddDays($retention)
Get-ChildItem $repo | Where-Object CreationTime -lt $limit_rem | Remove-Item

clear-Variable -Name "esx_ip", "esx_pass", "esx_login", "repo", "securePasswordPath", "password", "retention", "limit_rem"