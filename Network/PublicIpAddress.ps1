
function Save-AzureRmPublicIpAddressTable{
    $script:AzureRmPublicIpAddressTable = @()
    $script:AzureRmPublicIpAddress | foreach{
        $script:AzureRmPublicIpAddress = $null
        if($_.IpConfiguration.Id -ne $null){
            $script:AzureRmPublicIpAddress = "<a href=`"#$((($_.IpConfiguration.Id) -Replace `"/[frontend]*IPConfigurations/.*$`",`"`").ToLower())`">$($_.IpConfiguration.Id)</a>"
        }
        $script:AzureRmPublicIpAddressDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Zones"                     = $_.Zones
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "Sku"                       = $_.Sku.Name
            "PublicIpAllocationMethod"  = $_.PublicIpAllocationMethod
            "IpAddress"                 = $_.IpAddress
            "PublicIpAddressVersion"    = $_.PublicIpAddressVersion
            "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
            "IpConfiguration"           = $script:AzureRmPublicIpAddress
            "DomainNameLabel"           = $_.DnsSettings.DomainNameLabel -join "<br>"
            "Fqdn"                      = $_.DnsSettings.Fqdn -join "<br>"
            "ReverseFqdn"               = $_.DnsSettings.ReverseFqdn -join "<br>"
        }
        $script:AzureRmPublicIpAddressDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmPublicIpAddressDetail)

        $script:AzureRmPublicIpAddressTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "PublicIpAllocationMethod"  = $_.PublicIpAllocationMethod
            "IpAddress"                 = $_.IpAddress
            "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmPublicIpAddressDetailTable
        }
    }
    $script:Report += "<h3>Public IP Address</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmPublicIpAddressTable))
}