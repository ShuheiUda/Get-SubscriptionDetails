
function Save-AzImageTable{
    $script:AzImageTable = @()
    if($script:AzImage -ne $null){
        $script:AzImage | foreach{
            $script:AzImageStorageProfileOsDiskDetail = @()
            $script:AzImageStorageProfileOsDiskDetailTable = @()
            $script:AzImageStorageProfileOsDiskDetail = [PSCustomObject]@{
                "OsType"                    = $_.StorageProfile.OsDisk.OsType
                "OsState"                   = $_.StorageProfile.OsDisk.OsState
                "StorageAccountType"        = $_.StorageProfile.OsDisk.StorageAccountType
                "Caching"                   = $_.StorageProfile.OsDisk.Caching
                "DiskSizeGB"                = $_.StorageProfile.OsDisk.DiskSizeGB
                "Snapshot"                  = $_.StorageProfile.OsDisk.Snapshot.Id
                "ManagedDisk"               = $_.StorageProfile.OsDisk.ManagedDisk.Id
                "BlobUri"                   = $_.StorageProfile.OsDisk.BlobUri
            }
            $script:AzImageStorageProfileOsDiskDetailTable = New-HTMLTable -InputObject $script:AzImageStorageProfileOsDiskDetail
        
            $script:AzImageStorageProfileDataDisksDetail = @()
            $script:AzImageStorageProfileDataDisksDetailTable = @()
            if($_.StorageProfile.DataDisks -ne $null){
                $_.StorageProfile.DataDisks | foreach{
                    $script:AzImageStorageProfileDataDisksDetail += [PSCustomObject]@{
                    "Lun"                       = $_.Lun
                    "StorageAccountType"        = $_.StorageAccountType
                    "Caching"                   = $_.Caching
                    "DiskSizeGB"                = $_.DiskSizeGB
                    "Snapshot"                  = $_.Snapshot.Id
                    "ManagedDisk"               = $_.ManagedDisk.Id
                    "BlobUri"                   = $_.BlobUri
                    }
                }
                $script:AzImageStorageProfileDataDisksDetailTable = New-HTMLTable -InputObject $script:AzImageStorageProfileDataDisksDetail
            }

            $script:AzImageDetail = [PSCustomObject]@{
                "Name"                          = $_.Name
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "Id"                            = $_.Id
                "ProvisioningState"             = $_.ProvisioningState
                "Type"                          = $_.Type
                "SourceVirtualMachine"          = $_.SourceVirtualMachine.Id
                "OsDisk"                        = ConvertTo-DetailView -InputObject $script:AzImageStorageProfileOsDiskDetailTable
                "DataDisks"                     = ConvertTo-DetailView -InputObject $script:AzImageStorageProfileDataDisksDetailTable
            }
            $script:AzImageDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzImageDetail) 

            $script:AzImageTable += [PSCustomObject]@{
                "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "ProvisioningState"             = $_.ProvisioningState
                "Detail"                        = ConvertTo-DetailView -InputObject $script:AzImageDetailTable
            }
        }
    }

    $script:Report += "<h3>Managed Disk (Image)</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzImageTable))
}