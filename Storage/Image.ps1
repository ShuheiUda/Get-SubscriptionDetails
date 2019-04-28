
function Save-AzureRmImageTable{
    $script:AzureRmImageTable = @()
    if($script:AzureRmImage -ne $null){
        $script:AzureRmImage | foreach{
            $script:AzureRmImageStorageProfileOsDiskDetail = @()
            $script:AzureRmImageStorageProfileOsDiskDetailTable = @()
            $script:AzureRmImageStorageProfileOsDiskDetail = [PSCustomObject]@{
                "OsType"                    = $_.StorageProfile.OsDisk.OsType
                "OsState"                   = $_.StorageProfile.OsDisk.OsState
                "StorageAccountType"        = $_.StorageProfile.OsDisk.StorageAccountType
                "Caching"                   = $_.StorageProfile.OsDisk.Caching
                "DiskSizeGB"                = $_.StorageProfile.OsDisk.DiskSizeGB
                "Snapshot"                  = $_.StorageProfile.OsDisk.Snapshot.Id
                "ManagedDisk"               = $_.StorageProfile.OsDisk.ManagedDisk.Id
                "BlobUri"                   = $_.StorageProfile.OsDisk.BlobUri
            }
            $script:AzureRmImageStorageProfileOsDiskDetailTable = New-HTMLTable -InputObject $script:AzureRmImageStorageProfileOsDiskDetail
        
            $script:AzureRmImageStorageProfileDataDisksDetail = @()
            $script:AzureRmImageStorageProfileDataDisksDetailTable = @()
            if($_.StorageProfile.DataDisks -ne $null){
                $_.StorageProfile.DataDisks | foreach{
                    $script:AzureRmImageStorageProfileDataDisksDetail += [PSCustomObject]@{
                    "Lun"                       = $_.Lun
                    "StorageAccountType"        = $_.StorageAccountType
                    "Caching"                   = $_.Caching
                    "DiskSizeGB"                = $_.DiskSizeGB
                    "Snapshot"                  = $_.Snapshot.Id
                    "ManagedDisk"               = $_.ManagedDisk.Id
                    "BlobUri"                   = $_.BlobUri
                    }
                }
                $script:AzureRmImageStorageProfileDataDisksDetailTable = New-HTMLTable -InputObject $script:AzureRmImageStorageProfileDataDisksDetail
            }

            $script:AzureRmImageDetail = [PSCustomObject]@{
                "Name"                          = $_.Name
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "Id"                            = $_.Id
                "ProvisioningState"             = $_.ProvisioningState
                "Type"                          = $_.Type
                "SourceVirtualMachine"          = $_.SourceVirtualMachine.Id
                "OsDisk"                        = ConvertTo-DetailView -InputObject $script:AzureRmImageStorageProfileOsDiskDetailTable
                "DataDisks"                     = ConvertTo-DetailView -InputObject $script:AzureRmImageStorageProfileDataDisksDetailTable
            }
            $script:AzureRmImageDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmImageDetail) 

            $script:AzureRmImageTable += [PSCustomObject]@{
                "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "ProvisioningState"             = $_.ProvisioningState
                "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmImageDetailTable
            }
        }
    }

    $script:Report += "<h3>Managed Disk (Image)</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmImageTable))
}