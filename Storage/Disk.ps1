
function Save-AzDiskTable{
    $script:AzDiskTable = @()
    $script:AzDisk | foreach{
        $script:AzDiskSkuDetailTable = $null
        $script:AzDiskCreationDataDetailTable = $null

        if($_.Sku -ne $null){
            $script:AzDiskSkuDetailTable = New-HTMLTable -InputObject $_.Sku
        }
        if($_.CreationData -ne $null){
            $script:AzDiskCreationDataDetail = [PSCustomObject]@{
                "CreateOption"                      = $_.CreationData.CreateOption
                "StorageAccountId"                  = $_.CreationData.StorageAccountId
                "ImageReference.Lun"                = $_.CreationData.ImageReference.Lun
                "ImageReference.Id"                 = $_.CreationData.ImageReference.Id
                "SourceUri"                         = $_.CreationData.SourceUri
                "SourceResourceId"                  = $_.CreationData.SourceResourceId
            }
            $script:AzDiskCreationDataDetailTable = New-HTMLTable -InputObject $script:AzDiskCreationDataDetail
        }

        $script:AzDiskManagedBy = $null
        if($_.ManagedBy -ne $null){
            $script:AzDiskManagedBy = "<a href=`"#$(($_.ManagedBy).ToLower())`">$($_.ManagedBy)</a>"
        }
        $script:AzDiskDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Zones"                         = $_.Zones
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "TimeCreated"                   = $_.TimeCreated
            "Type"                          = $_.Type
            "Sku"                           = $script:AzDiskSkuDetailTable
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "CreationData"                  = $script:AzDiskCreationDataDetailTable
            "EncryptionSettings"            = $_.EncryptionSettings
            "ManagedBy"                     = $script:AzDiskManagedBy
        }
        $script:AzDiskDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzDiskDetail) 

        $script:AzDiskTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "OsType"                        = $_.OsType  
            "DiskSizeGB"                    = $_.DiskSizeGB
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzDiskDetailTable
        }
    }

    $script:Report += "<h3>Managed Disk</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzDiskTable))
}