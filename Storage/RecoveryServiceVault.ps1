
function Save-AzureRmRecoveryServicesVault{
    $script:AzureRmRecoveryServicesVaultTable = @()
    $script:AzureRmRecoveryServicesVaultDetailTable = @()

    $script:AzureRmRecoveryServicesVault | foreach{

        # Check AzureVM Backup
        $script:Vault = $_
        $script:AzureRmRecoveryServicesVaultContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $script:Vault.Id

        $script:AzureRmRecoveryServicesVaultBackupItemDetail = @()
        $script:AzureRmRecoveryServicesVaultBackupItemDetailTable = @()

        $script:AzureRmRecoveryServicesVaultContainer | ForEach-Object {
            $script:Container = $_            

            $script:AzureRmRecoveryServicesBackupItem = Get-AzureRmRecoveryServicesBackupItem -WorkloadType AzureVM -VaultId $script:Vault.Id -Container $script:Container

            $script:AzureRmRecoveryServicesBackupItem | ForEach-Object {
                $script:BackupItem = $_
                $script:AzureRmRecoveryServicesVaultBackupItemDetail += [PSCustomObject]@{
                    "Name"                      = "<a href=`"#$($script:BackupItem.VirtualMachineId.ToLower())`">$($script:BackupItem.Name)</a>"
                    "ContainerType"             = $script:BackupItem.ContainerType
                    "ContainerName"             = $script:BackupItem.ContainerName
                    "WorkloadType"              = $script:BackupItem.WorkloadType
                    "ProtectionPolicyName"      = $script:BackupItem.ProtectionPolicyName
                    "ProtectionStatus"          = $script:BackupItem.ProtectionStatus
                }
            }

        }

        <#
        # TODO:https://github.com/Azure/azure-powershell/issues/6595
        # Check Azure Agent Backup
        $script:AzureRmRecoveryServicesVaultContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType Windows -BackupManagementType MARS -VaultId $script:Vault.Id

        $script:AzureRmRecoveryServicesVaultContainer | ForEach-Object {
            $script:Container = $_            

            $script:AzureRmRecoveryServicesBackupItem = Get-AzureRmRecoveryServicesBackupItem -WorkloadType AzureVM -VaultId $script:Vault.Id -Container $script:Container
 $script:Container
            $script:AzureRmRecoveryServicesBackupItem | ForEach-Object {
                $script:BackupItem = $_
                $script:AzureRmRecoveryServicesVaultBackupItemDetail += [PSCustomObject]@{
                    "VirtualMachineId"          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
                    "Name"                      = $script:BackupItem.Name
                    "ContainerType"             = $script:BackupItem.ContainerType
                    "ContainerUniqueName"       = $script:BackupItem.ContainerUniqueName
                    "WorkloadType"              = $script:BackupItem.WorkloadType
                    "ProtectionStatus"          = $script:BackupItem.ProtectionStatus
                }
            }

        }
        #>

        $script:AzureRmRecoveryServicesBackupStorageRedundancy = (Get-AzureRmRecoveryServicesBackupProperties -Vault $script:Vault).BackupStorageRedundancy

        $script:AzureRmRecoveryServicesVaultBackupItemDetailTable  = New-HTMLTable -InputObject $script:AzureRmRecoveryServicesVaultBackupItemDetail
        $script:AzureRmRecoveryServicesVaultDetail = [PSCustomObject]@{
            "Name"                          = $script:Vault.Name
            "ResourceGroupName"             = $script:Vault.ResourceGroupName
            "Location"                      = $script:Vault.Location
            "Id"                            = $script:Vault.Id
            "Type"                          = $script:Vault.Type
            "BackupStorageRedundancy"       = $script:AzureRmRecoveryServicesBackupStorageRedundancy
            "ProvisioningState"             = $script:Vault.Properties.ProvisioningState
            "Container"                     = $script:AzureRmRecoveryServicesVaultBackupItemDetailTable
        }
        $script:AzureRmRecoveryServicesVaultDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRecoveryServicesVaultDetail) 

        $script:AzureRmRecoveryServicesVaultTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($Vault.Id.ToLower())`">$($Vault.Name)</a>"
            "ResourceGroupName"             = $script:Vault.ResourceGroupName
            "Location"                      = $script:Vault.Location
            "BackupStorageRedundancy"       = $script:AzureRmRecoveryServicesBackupStorageRedundancy
            "ProvisioningState"             = $script:Vault.Properties.ProvisioningState
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmRecoveryServicesVaultDetailTable
        }        
    }

    $script:Report += "<h3>Recovery Service Vault</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmRecoveryServicesVaultTable))
}