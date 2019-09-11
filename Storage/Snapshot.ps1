

function Save-AzSnapshotTable{
    $script:AzSnapshotTable = @()
    $script:AzSnapshot | foreach{
        $script:AzSnapshotSkuDetailTable = $null
        $script:AzSnapshotCreationDataDetailTable = $null

        if($_.Sku -ne $null){
            $script:AzSnapshotSkuDetailTable = New-HTMLTable -InputObject $_.Sku
        }
        if($_.CreationData -ne $null){
            $script:AzSnapshotCreationDataDetail = [PSCustomObject]@{
                "CreateOption"                      = $_.CreationData.CreateOption
                "StorageAccountId"                  = $_.CreationData.StorageAccountId
                "ImageReference.Lun"                = $_.CreationData.ImageReference.Lun
                "ImageReference.Id"                 = $_.CreationData.ImageReference.Id
                "SourceUri"                         = $_.CreationData.SourceUri
                "SourceResourceId"                  = $_.CreationData.SourceResourceId
            }
            $script:AzSnapshotCreationDataDetailTable = New-HTMLTable -InputObject $script:AzSnapshotCreationDataDetail
        }
        
        $script:AzSnapshotManagedBy = $null
        if($_.ManagedBy -ne $null){
            $script:AzSnapshotManagedBy = "<a href=`"#$(($_.ManagedBy).ToLower())`">$($_.ManagedBy)</a>"
        }
        $script:AzSnapshotDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "TimeCreated"                   = $_.TimeCreated
            "Type"                          = $_.Type
            "Sku"                           = $script:AzSnapshotSkuDetailTable
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "CreationData"                  = $script:AzSnapshotCreationDataDetailTable
            "EncryptionSettings"            = $_.EncryptionSettings
            "ManagedBy"                     = $script:AzSnapshotManagedBy
        }
        $script:AzSnapshotDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzSnapshotDetail) 

        $script:AzSnapshotTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzSnapshotDetailTable
        }
    }

    $script:Report += "<h3>Managed Disk (Snapshot)</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzSnapshotTable))
}