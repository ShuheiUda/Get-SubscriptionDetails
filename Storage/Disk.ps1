
function Save-AzureRmDiskTable{
    $script:AzureRmDiskTable = @()
    $script:AzureRmDisk | foreach{
        $script:AzureRmDiskSkuDetailTable = $null
        $script:AzureRmDiskCreationDataDetailTable = $null

        if($_.Sku -ne $null){
            $script:AzureRmDiskSkuDetailTable = New-HTMLTable -InputObject $_.Sku
        }
        if($_.CreationData -ne $null){
            $script:AzureRmDiskCreationDataDetail = [PSCustomObject]@{
                "CreateOption"                      = $_.CreationData.CreateOption
                "StorageAccountId"                  = $_.CreationData.StorageAccountId
                "ImageReference.Lun"                = $_.CreationData.ImageReference.Lun
                "ImageReference.Id"                 = $_.CreationData.ImageReference.Id
                "SourceUri"                         = $_.CreationData.SourceUri
                "SourceResourceId"                  = $_.CreationData.SourceResourceId
            }
            $script:AzureRmDiskCreationDataDetailTable = New-HTMLTable -InputObject $script:AzureRmDiskCreationDataDetail
        }

        $script:AzureRmDiskManagedBy = $null
        if($_.ManagedBy -ne $null){
            $script:AzureRmDiskManagedBy = "<a href=`"#$(($_.ManagedBy).ToLower())`">$($_.ManagedBy)</a>"
        }
        $script:AzureRmDiskDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Zones"                         = $_.Zones
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "TimeCreated"                   = $_.TimeCreated
            "Type"                          = $_.Type
            "Sku"                           = $script:AzureRmDiskSkuDetailTable
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "CreationData"                  = $script:AzureRmDiskCreationDataDetailTable
            "EncryptionSettings"            = $_.EncryptionSettings
            "ManagedBy"                     = $script:AzureRmDiskManagedBy
        }
        $script:AzureRmDiskDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmDiskDetail) 

        $script:AzureRmDiskTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmDiskDetailTable
        }
    }

    $script:Report += "<h3>Managed Disk</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmDiskTable))
}