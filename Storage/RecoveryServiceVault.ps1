
function Save-AzureRmRecoveryServicesVault{
    $script:AzureRmRecoveryServicesVaultTable = @()
    $script:AzureRmRecoveryServicesVaultDetailTable = @()
    $script:AzureRmRecoveryServicesVaultContainerDetailTable = @()
    $script:AzureRmRecoveryServicesVault | foreach{

        $script:Vault = $_
        $script:AzureRmRecoveryServicesVaultContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $script:Vault.Id

        $script:AzureRmRecoveryServicesVaultContainerDetailTable = @()
        $script:AzureRmRecoveryServicesVaultContainerDetail = @()
        
        $script:AzureRmRecoveryServicesVaultContainer | ForEach-Object {
            $script:Container = $_
            $script:AzureRmRecoveryServicesVaultContainerDetail += [PSCustomObject]@{
                "ResourceGroupName"         = $script:Container.ResourceGroupName
                "FriendlyName"              = $script:Container.FriendlyName
                "Status"                    = $script:Container.Status
                "Name"                      = $script:Container.Name
                "ContainerType"             = $script:Container.ContainerType
                "BackupManagementType"      = $script:Container.BackupManagementType
            }
        }

        $script:AzureRmRecoveryServicesVaultContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType Windows -BackupManagementType MARS -VaultId $script:Vault.Id
        
        $script:AzureRmRecoveryServicesVaultContainer | ForEach-Object {
            $script:Container = $_
            $script:AzureRmRecoveryServicesVaultContainerDetail += [PSCustomObject]@{
                "ResourceGroupName"         = $script:Container.ResourceGroupName
                "FriendlyName"              = $script:Container.FriendlyName
                "Status"                    = $script:Container.Status
                "Name"                      = $script:Container.Name
                "ContainerType"             = $script:Container.ContainerType
                "BackupManagementType"      = $script:Container.BackupManagementType
            }
        }

        $script:AzureRmRecoveryServicesBackupStorageRedundancy = (Get-AzureRmRecoveryServicesBackupProperties -Vault $script:Vault).BackupStorageRedundancy

        $script:AzureRmRecoveryServicesVaultContainerDetailTable  = New-HTMLTable -InputObject $script:AzureRmRecoveryServicesVaultContainerDetail
        $script:AzureRmRecoveryServicesVaultDetail = [PSCustomObject]@{
            "Name"                          = $script:Vault.Name
            "ResourceGroupName"             = $script:Vault.ResourceGroupName
            "Location"                      = $script:Vault.Location
            "Id"                            = $script:Vault.Id
            "Type"                          = $script:Vault.Type
            "BackupStorageRedundancy"       = $script:AzureRmRecoveryServicesBackupStorageRedundancy
            "ProvisioningState"             = $script:Vault.Properties.ProvisioningState
            "Container"                     = $script:AzureRmRecoveryServicesVaultContainerDetailTable
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