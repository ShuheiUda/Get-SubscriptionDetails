
function Save-AzureRmRecoveryServicesVault{
    $script:AzureRmRecoveryServicesVaultTable = @()
    $script:AzureRmRecoveryServicesVaultDetailTable = @()

    $script:AzureRmRecoveryServicesVault | foreach{

        $script:Vault = $_

        # Check BackupProtectionPolicy
        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyDetail = @()
        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyDetailTable = @()
        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicySchedulePolicyDetail = @()
        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyRetentionPolicyDetail = @()

        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicy = Get-AzureRmRecoveryServicesBackupProtectionPolicy -VaultId $script:Vault.Id -WorkloadType AzureVM

        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicy | ForEach-Object {

            $script:AzureRmRecoveryServicesVaultBackupProtectionPolicySchedulePolicyDetail = [PSCustomObject]@{
                "ScheduleRunFrequency"    = $_.SchedulePolicy.ScheduleRunFrequency
                "ScheduleRunDays"         = $_.SchedulePolicy.ScheduleRunDays
                "ScheduleRunTimes"        = $_.SchedulePolicy.ScheduleRunTimes[0].ToString("HH:mm UTC")
            }

            $script:DailySchedule = ""
            if ( $_.RetentionPolicy.DailySchedule -ne $null ){
                $script:DailySchedule = $_.RetentionPolicy.DailySchedule.ToString() -replace "\{[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\}",$_.SchedulePolicy.ScheduleRunTimes[0].ToString("HH:mm UTC")
            }

            $script:WeeklySchedule = ""
            if ( $_.RetentionPolicy.WeeklySchedule -ne $null ){
                $script:WeeklySchedule = $_.RetentionPolicy.WeeklySchedule.ToString() -replace "\{[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\}",$_.SchedulePolicy.ScheduleRunTimes[0].ToString("HH:mm UTC")
            }

            $script:MonthlySchedule = ""
            if ( $_.RetentionPolicy.MonthlySchedule -ne $null ){
                $script:MonthlySchedule = $_.RetentionPolicy.MonthlySchedule.ToString() -replace "\{[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\}",$_.SchedulePolicy.ScheduleRunTimes[0].ToString("HH:mm UTC")
            }            

            $script:YearlySchedule = ""
            if ( $_.RetentionPolicy.YearlySchedule -ne $null ){
                $script:YearlySchedule = $_.RetentionPolicy.YearlySchedule.ToString() -replace "\{[0-9]{4}\/[0-9]{2}\/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\}",$_.SchedulePolicy.ScheduleRunTimes[0].ToString("HH:mm UTC")
            }            

            $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyRetentionPolicyDetail = [PSCustomObject]@{
                "IsDailyScheduleEnabled"    = $_.RetentionPolicy.IsDailyScheduleEnabled
                "IsWeeklyScheduleEnabled"   = $_.RetentionPolicy.IsWeeklyScheduleEnabled
                "IsMonthlyScheduleEnabled"  = $_.RetentionPolicy.IsMonthlyScheduleEnabled
                "IsYearlyScheduleEnabled"   = $_.RetentionPolicy.IsYearlyScheduleEnabled
                "DailySchedule"             = $script:DailySchedule
                "WeeklySchedule"            = $script:WeeklySchedule
                "MonthlySchedule"           = $script:MonthlySchedule
                "YearlySchedule"            = $script:YearlySchedule
            }

            $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "WorkloadType"              = $_.WorkloadType
                "BackupManagementType"      = $_.BackupManagementType
                "BackupTime"                = $_.BackupTime
                "SnapshotRetentionInDays"   = $_.SnapshotRetentionInDays
                "SchedulePolicy"            = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $_.SchedulePolicy )
                "RetentionPolicy"           = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyRetentionPolicyDetail )
            }

        }

        $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyDetailTable = New-HTMLTable -InputObject $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyDetail

        # Check AzureVM Backup
        $script:AzureRmRecoveryServicesVaultContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $script:Vault.Id

        $script:AzureRmRecoveryServicesVaultBackupItemDetail = @()
        $script:AzureRmRecoveryServicesVaultBackupItemDetailTable = @()

        if ( $script:AzureRmRecoveryServicesVaultContainer -ne $null ){
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
            $script:AzureRmRecoveryServicesVaultBackupItemDetailTable  = New-HTMLTable -InputObject $script:AzureRmRecoveryServicesVaultBackupItemDetail
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

        $script:AzureRmRecoveryServicesVaultDetail = [PSCustomObject]@{
            "Name"                          = $script:Vault.Name
            "ResourceGroupName"             = $script:Vault.ResourceGroupName
            "Location"                      = $script:Vault.Location
            "Id"                            = $script:Vault.Id
            "Type"                          = $script:Vault.Type
            "BackupStorageRedundancy"       = $script:AzureRmRecoveryServicesBackupStorageRedundancy
            "ProvisioningState"             = $script:Vault.Properties.ProvisioningState
            "ProtectionPolicy"              = $script:AzureRmRecoveryServicesVaultBackupProtectionPolicyDetailTable 
            "BackupItem"                    = $script:AzureRmRecoveryServicesVaultBackupItemDetailTable
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