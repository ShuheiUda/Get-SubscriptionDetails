
function Save-AzRecoveryServicesVault{
    $script:AzRecoveryServicesVaultTable = @()
    $script:AzRecoveryServicesVaultDetailTable = @()

    $script:AzRecoveryServicesVault | foreach{

        $script:Vault = $_

        # Check BackupProtectionPolicy
        $script:AzRecoveryServicesVaultBackupProtectionPolicyDetail = @()
        $script:AzRecoveryServicesVaultBackupProtectionPolicyDetailTable = @()
        $script:AzRecoveryServicesVaultBackupProtectionPolicySchedulePolicyDetail = @()
        $script:AzRecoveryServicesVaultBackupProtectionPolicyRetentionPolicyDetail = @()

        $script:AzRecoveryServicesVaultBackupProtectionPolicy = Get-AzRecoveryServicesBackupProtectionPolicy -VaultId $script:Vault.Id -WorkloadType AzureVM

        $script:AzRecoveryServicesVaultBackupProtectionPolicy | ForEach-Object {

            $script:AzRecoveryServicesVaultBackupProtectionPolicySchedulePolicyDetail = [PSCustomObject]@{
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

            $script:AzRecoveryServicesVaultBackupProtectionPolicyRetentionPolicyDetail = [PSCustomObject]@{
                "IsDailyScheduleEnabled"    = $_.RetentionPolicy.IsDailyScheduleEnabled
                "IsWeeklyScheduleEnabled"   = $_.RetentionPolicy.IsWeeklyScheduleEnabled
                "IsMonthlyScheduleEnabled"  = $_.RetentionPolicy.IsMonthlyScheduleEnabled
                "IsYearlyScheduleEnabled"   = $_.RetentionPolicy.IsYearlyScheduleEnabled
                "DailySchedule"             = $script:DailySchedule
                "WeeklySchedule"            = $script:WeeklySchedule
                "MonthlySchedule"           = $script:MonthlySchedule
                "YearlySchedule"            = $script:YearlySchedule
            }

            $script:AzRecoveryServicesVaultBackupProtectionPolicyDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "WorkloadType"              = $_.WorkloadType
                "BackupManagementType"      = $_.BackupManagementType
                "BackupTime"                = $_.BackupTime
                "SnapshotRetentionInDays"   = $_.SnapshotRetentionInDays
                "SchedulePolicy"            = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $_.SchedulePolicy )
                "RetentionPolicy"           = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzRecoveryServicesVaultBackupProtectionPolicyRetentionPolicyDetail )
            }

        }

        $script:AzRecoveryServicesVaultBackupProtectionPolicyDetailTable = New-HTMLTable -InputObject $script:AzRecoveryServicesVaultBackupProtectionPolicyDetail

        # Check AzureVM Backup
        $script:AzRecoveryServicesVaultContainer = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $script:Vault.Id

        $script:AzRecoveryServicesVaultBackupItemDetail = @()
        $script:AzRecoveryServicesVaultBackupItemDetailTable = @()

        if ( $script:AzRecoveryServicesVaultContainer -ne $null ){
            $script:AzRecoveryServicesVaultContainer | ForEach-Object {
                $script:Container = $_            
    
                $script:AzRecoveryServicesBackupItem = Get-AzRecoveryServicesBackupItem -WorkloadType AzureVM -VaultId $script:Vault.Id -Container $script:Container
    
                $script:AzRecoveryServicesBackupItem | ForEach-Object {
                    $script:BackupItem = $_
                    $script:AzRecoveryServicesVaultBackupItemDetail += [PSCustomObject]@{
                        "Name"                      = "<a href=`"#$($script:BackupItem.VirtualMachineId.ToLower())`">$($script:BackupItem.Name)</a>"
                        "ContainerType"             = $script:BackupItem.ContainerType
                        "ContainerName"             = $script:BackupItem.ContainerName
                        "WorkloadType"              = $script:BackupItem.WorkloadType
                        "ProtectionPolicyName"      = $script:BackupItem.ProtectionPolicyName
                        "ProtectionStatus"          = $script:BackupItem.ProtectionStatus
                    }
                }
    
            }
            $script:AzRecoveryServicesVaultBackupItemDetailTable  = New-HTMLTable -InputObject $script:AzRecoveryServicesVaultBackupItemDetail
        }


        <#
        # TODO:https://github.com/Azure/azure-powershell/issues/6595
        # Check Azure Agent Backup
        $script:AzRecoveryServicesVaultContainer = Get-AzRecoveryServicesBackupContainer -ContainerType Windows -BackupManagementType MARS -VaultId $script:Vault.Id

        $script:AzRecoveryServicesVaultContainer | ForEach-Object {
            $script:Container = $_            

            $script:AzRecoveryServicesBackupItem = Get-AzRecoveryServicesBackupItem -WorkloadType AzureVM -VaultId $script:Vault.Id -Container $script:Container
 $script:Container
            $script:AzRecoveryServicesBackupItem | ForEach-Object {
                $script:BackupItem = $_
                $script:AzRecoveryServicesVaultBackupItemDetail += [PSCustomObject]@{
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



        $script:AzRecoveryServicesBackupStorageRedundancy = (Get-AzRecoveryServicesBackupProperties -Vault $script:Vault).BackupStorageRedundancy

        $script:AzRecoveryServicesVaultDetail = [PSCustomObject]@{
            "Name"                          = $script:Vault.Name
            "ResourceGroupName"             = $script:Vault.ResourceGroupName
            "Location"                      = $script:Vault.Location
            "Id"                            = $script:Vault.Id
            "Type"                          = $script:Vault.Type
            "BackupStorageRedundancy"       = $script:AzRecoveryServicesBackupStorageRedundancy
            "ProvisioningState"             = $script:Vault.Properties.ProvisioningState
            "ProtectionPolicy"              = $script:AzRecoveryServicesVaultBackupProtectionPolicyDetailTable 
            "BackupItem"                    = $script:AzRecoveryServicesVaultBackupItemDetailTable
        }
        $script:AzRecoveryServicesVaultDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzRecoveryServicesVaultDetail) 

        $script:AzRecoveryServicesVaultTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($Vault.Id.ToLower())`">$($Vault.Name)</a>"
            "ResourceGroupName"             = $script:Vault.ResourceGroupName
            "Location"                      = $script:Vault.Location
            "BackupStorageRedundancy"       = $script:AzRecoveryServicesBackupStorageRedundancy
            "ProvisioningState"             = $script:Vault.Properties.ProvisioningState
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzRecoveryServicesVaultDetailTable
        }        
    }

    $script:Report += "<h3>Recovery Service Vault</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzRecoveryServicesVaultTable))
}