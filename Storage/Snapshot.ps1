

function Save-AzureRmSnapshotTable{
    $script:AzureRmSnapshotTable = @()
    $script:AzureRmSnapshot | foreach{
        $script:AzureRmSnapshotSkuDetailTable = $null
        $script:AzureRmSnapshotCreationDataDetailTable = $null

        if($_.Sku -ne $null){
            $script:AzureRmSnapshotSkuDetailTable = New-HTMLTable -InputObject $_.Sku
        }
        if($_.CreationData -ne $null){
            $script:AzureRmSnapshotCreationDataDetail = [PSCustomObject]@{
                "CreateOption"                      = $_.CreationData.CreateOption
                "StorageAccountId"                  = $_.CreationData.StorageAccountId
                "ImageReference.Lun"                = $_.CreationData.ImageReference.Lun
                "ImageReference.Id"                 = $_.CreationData.ImageReference.Id
                "SourceUri"                         = $_.CreationData.SourceUri
                "SourceResourceId"                  = $_.CreationData.SourceResourceId
            }
            $script:AzureRmSnapshotCreationDataDetailTable = New-HTMLTable -InputObject $script:AzureRmSnapshotCreationDataDetail
        }
        
        $script:AzureRmSnapshotManagedBy = $null
        if($_.ManagedBy -ne $null){
            $script:AzureRmSnapshotManagedBy = "<a href=`"#$(($_.ManagedBy).ToLower())`">$($_.ManagedBy)</a>"
        }
        $script:AzureRmSnapshotDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "TimeCreated"                   = $_.TimeCreated
            "Type"                          = $_.Type
            "Sku"                           = $script:AzureRmSnapshotSkuDetailTable
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "CreationData"                  = $script:AzureRmSnapshotCreationDataDetailTable
            "EncryptionSettings"            = $_.EncryptionSettings
            "ManagedBy"                     = $script:AzureRmSnapshotManagedBy
        }
        $script:AzureRmSnapshotDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmSnapshotDetail) 

        $script:AzureRmSnapshotTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmSnapshotDetailTable
        }
    }

    $script:Report += "<h3>Managed Disk (Snapshot)</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmSnapshotTable))
}