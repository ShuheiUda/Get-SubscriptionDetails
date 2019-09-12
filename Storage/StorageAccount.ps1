

function Save-AzStorageAccountTable{
    $script:AzStorageAccountTable = @()
    $script:AzStorageAccount | foreach{
        $script:AzStorageSkuDetailTable = $null
        $script:AzStorageNetworkRuleSetDetailTable = $null
        $script:AzStorageEncryptionDetail = $null
        $script:AzStorageEncryptionDetailTable = $null
        $script:AzStorageVirtualNetworkRulesDetail = $null
        $script:AzStorageVirtualNetworkRulesDetailTable = $null
        $script:AzStorageIpRulesDetail = $null
        $script:AzStorageIpRulesDetailTable = $null
        
        if($_.Sku -ne $null){
            $script:AzStorageSkuDetailTable = New-HTMLTable -InputObject $_.Sku
        }
        
        if ($_.NetworkRuleSet.VirtualNetworkRules -ne $Null){
            $script:AzStorageVirtualNetworkRulesDetail = @()
            $script:AzStorageVirtualNetworkRulesDetailTable = @()
            $_.NetworkRuleSet.VirtualNetworkRules | ForEach-Object {
                $script:AzStorageVirtualNetworkRulesDetail += [PSCustomObject]@{
                    "Action"                    = $_.Action
                    "VirtualNetworkResourceId"  = $_.VirtualNetworkResourceId
                }
            }
            $script:AzStorageVirtualNetworkRulesDetailTable = New-HTMLTable -InputObject $script:AzStorageVirtualNetworkRulesDetail
        }

        if ($_.NetworkRuleSet.IpRules -ne $Null){
            $script:AzStorageIpRulesDetail = @()
            $script:AzStorageIpRulesDetailTable = @()
            $_.NetworkRuleSet.IpRules | ForEach-Object {
                $script:AzStorageIpRulesDetail += [PSCustomObject]@{
                    "Action"                = $_.Action
                    "IPAddressOrRange"      = $_.IPAddressOrRange
                }
            }
            $script:AzStorageIpRulesDetailTable = New-HTMLTable -InputObject $script:AzStorageIpRulesDetail
        }

        if($_.NetworkRuleSet -ne $null){
            $script:AzStorageNetworkRuleSetDetail = [PSCustomObject]@{
                "DefaultAction"             = $_.NetworkRuleSet.DefaultAction
                "Bypass"                    = $_.NetworkRuleSet.Bypass.ToString() -replace ", ","<br>"
                "VirtualNetworkRules"       = $script:AzStorageVirtualNetworkRulesDetailTable
                "IpRules"                   = $script:AzStorageIpRulesDetailTable
            }
            $script:AzStorageNetworkRuleSetDetailTable = New-HTMLTable -InputObject $script:AzStorageNetworkRuleSetDetail
        }

        if($_.Encryption -ne $null){
            $script:AzStorageEncryptionDetail = [PSCustomObject]@{
                "Blob.Enabled"              = $_.Encryption.Services.Blob.Enabled
                "Blob.LastEnabledTime"      = $_.Encryption.Services.Blob.LastEnabledTime
                "File.Enabled"              = $_.Encryption.Services.File.Enabled
                "File.LastEnabledTime"      = $_.Encryption.Services.File.LastEnabledTime
            }
            $script:AzStorageEncryptionDetailTable = New-HTMLTable -InputObject $script:AzStorageEncryptionDetail
        }

        $script:AzStorageAccountDetail = [PSCustomObject]@{
            "StorageAccountName"            = $_.StorageAccountName
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "CreationTime"                  = $_.CreationTime
            "LastGeoFailoverTime"           = $_.LastGeoFailoverTime
            "CustomDomain"                  = $_.CustomDomain.Name
            "Sku"                           = $script:AzStorageSkuDetailTable
            "Kind"                          = $_.Kind
            "AccessTier"                    = $_.AccessTier
            "EnableHttpsTrafficOnly"        = $_.EnableHttpsTrafficOnly
            "Encryption"                    = $script:AzStorageEncryptionDetailTable
            "NetworkRuleSet"                = $script:AzStorageNetworkRuleSetDetailTable
            "PrimaryLocation"               = $_.PrimaryLocation
            "PrimaryEndpoints"              = $_.PrimaryEndpoints.Blob
            "StatusOfPrimary"               = $_.StatusOfPrimary
            "SecondaryLocation"             = $_.SecondaryLocation
            "SecondaryEndpoints"            = $_.SecondaryEndpoints.Blob
            "StatusOfSecondary"             = $_.StatusOfSecondary;            
        }
        $script:AzStorageAccountDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzStorageAccountDetail) 

        $script:AzStorageAccountTable += [PSCustomObject]@{
            "StorageAccountName"        = "<a name=`"$($_.Id.ToLower())`">$($_.StorageAccountName)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Sku"                       = $_.Sku.Name
            "StatusOfPrimary"           = $_.StatusOfPrimary
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzStorageAccountDetailTable
        }
    }
    $script:Report += "<h3>StorageAccount</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzStorageAccountTable))
}
