# VMware-ESX-Backup Script

Simple backup script with Powershell SecretVault to test the concept for secure storing passwords.

More information in this link: https://devblogs.microsoft.com/powershell/secretmanagement-and-secretstore-are-generally-available/ 

## Tested on

* Script execution machine:

VMware Photon OS 4.0 ARM64

* ESXi version:

ESXi on Arm Fling (Build 17230755)
Also should work without issue on the x86 platform. 

## Requirements

* Install Powershell Core (https://github.com/PowerShell/PowerShell)

Example based on VMware Photon OS 4.0 ARM64:

```
tdnf install powershell
tdnf -y install wget icu libunwind wget tar
tdnf install -y '^libssl1.0.[0-9]$' libunwind8
wget https://github.com/PowerShell/PowerShell/releases/download/v7.1.3/powershell-7.1.3-linux-arm64.tar.gz
mkdir powershell
tar -xvf ./powershell-7.1.3-linux-arm64.tar.gz -C ~/powershell
ln -s ~/powershell/pwsh /usr/bin/pwsh
pwsh
```

* Install VMware PowerCLI

```
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted;
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore;
Set-PowerCLIConfiguration -Scope AllUsers -ParticipateInCEIP $false;

Install-Module -Name VMware.PowerCLI;
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore;
```

* Install required PowerShell modules (included in a prep_vault.ps1)

```
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -Repository PSGallery
```

## Usage

* Manual usage:

```
pwsh ./prep_vault.ps1
pwsh ./powercli-esx-backup.ps1
```

* You can also use crone for the scheduling:

```
0 0 * * 0 pwsh -File /root/vmware-esx-backup/powercli-esx-backup.ps1
```
