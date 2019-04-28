

function Save-AzureRmStorageAccountTable{
    $script:AzureRmStorageAccountTable = @()
    $script:AzureRmStorageAccount | foreach{
        $script:AzureRmStorageSkuDetailTable = $null
        $script:AzureRmStorageNetworkRuleSetDetailTable = $null
        $script:AzureRmStorageEncryptionDetail = $null
        $script:AzureRmStorageEncryptionDetailTable = $null
    
        if($_.Sku -ne $null){
            $script:AzureRmStorageSkuDetailTable = New-HTMLTable -InputObject $_.Sku
        }
        if($_.NetworkRuleSet -ne $null){
            $script:AzureRmStorageNetworkRuleSetDetail = [PSCustomObject]@{
                "DefaultAction"             = $_.NetworkRuleSet.DefaultAction
                "Bypass"                    = $_.NetworkRuleSet.Bypass
                "VirtualNetworkRules"       = $_.NetworkRuleSet.VirtualNetworkRules
                "IpRules"                   = $_.NetworkRuleSet.IpRules
            }
            $script:AzureRmStorageNetworkRuleSetDetailTable = New-HTMLTable -InputObject $script:AzureRmStorageNetworkRuleSetDetail
        }
        if($_.Encryption -ne $null){
            $script:AzureRmStorageEncryptionDetail = [PSCustomObject]@{
                "Blob.Enabled"              = $_.Encryption.Services.Blob.Enabled
                "Blob.LastEnabledTime"      = $_.Encryption.Services.Blob.LastEnabledTime
                "File.Enabled"              = $_.Encryption.Services.File.Enabled
                "File.LastEnabledTime"      = $_.Encryption.Services.File.LastEnabledTime
            }
            $script:AzureRmStorageEncryptionDetailTable = New-HTMLTable -InputObject $script:AzureRmStorageEncryptionDetail
        }

        $script:AzureRmStorageAccountDetail = [PSCustomObject]@{
            "StorageAccountName"            = $_.StorageAccountName
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "CreationTime"                  = $_.CreationTime
            "LastGeoFailoverTime"           = $_.LastGeoFailoverTime
            "CustomDomain"                  = $_.CustomDomain.Name
            "Sku"                           = $script:AzureRmStorageSkuDetailTable
            "Kind"                          = $_.Kind
            "AccessTier"                    = $_.AccessTier
            "EnableHttpsTrafficOnly"        = $_.EnableHttpsTrafficOnly
            "Encryption"                    = $script:AzureRmStorageEncryptionDetailTable
            "NetworkRuleSet"                = $script:AzureRmStorageNetworkRuleSetDetailTable
            "PrimaryLocation"               = $_.PrimaryLocation
            "PrimaryEndpoints"              = $_.PrimaryEndpoints.Blob
            "StatusOfPrimary"               = $_.StatusOfPrimary
            "SecondaryLocation"             = $_.SecondaryLocation
            "SecondaryEndpoints"            = $_.SecondaryEndpoints.Blob
            "StatusOfSecondary"             = $_.StatusOfSecondary;            
        }
        $script:AzureRmStorageAccountDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmStorageAccountDetail) 

        $script:AzureRmStorageAccountTable += [PSCustomObject]@{
            "StorageAccountName"        = "<a name=`"$($_.Id.ToLower())`">$($_.StorageAccountName)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Sku"                       = $_.Sku.Name
            "StatusOfPrimary"           = $_.StatusOfPrimary
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmStorageAccountDetailTable
        }
    }
    $script:Report += "<h3>StorageAccount</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmStorageAccountTable))
}
