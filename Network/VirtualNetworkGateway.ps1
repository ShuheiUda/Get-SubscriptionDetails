
function Save-AzureRmVirtualNetworkGatewayTable{
    $script:AzureRmVirtualNetworkGatewayTable = @()
    $script:AzureRmVirtualNetworkGateway | foreach{
        $script:AzureRmVirtualNetworkGatewayDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "Id"                            = $_.Id
            "ResourceGuid"                  = $_.ResourceGuid
            "GatewayType"                   = $_.GatewayType
            "VpnType"                       = $_.VpnType
            "PublicIpAddress"               = "<a href=`"#$($_.IpConfigurations.PublicIpAddress.Id.ToLower())`">$($_.IpConfigurations.PublicIpAddress.Id)</a>"
            "Subnet"                        = "<a href=`"#$($_.IpConfigurations.Subnet.Id.Replace(`"/subnets/GatewaySubnet`",`"`").ToLower())`">$($_.IpConfigurations.Subnet.Id)</a>"
            "ActiveActive"                  = $_.ActiveActive
            "GatewayDefaultSite"            = $_.GatewayDefaultSite.Id
            "Sku"                           = $_.Sku.Name
            "VpnClientAddressPool"          = $_.VpnClientConfiguration.VpnClientAddressPool.AddressPrefixes
            "VpnClientRevokedCertificates"  = $_.VpnClientConfiguration.VpnClientRevokedCertificates.Name -join "<br>"
            "VpnClientRootCertificates"     = $_.VpnClientConfiguration.VpnClientRootCertificates.Name -join "<br>"
            "EnableBgp"                     = $_.EnableBgp
            "Asn"                           = $_.BgpSettings.Asn
            "BgpPeeringAddress"             = $_.BgpSettings.BgpPeeringAddress
            "PeerWeight"                    = $_.BgpSettings.PeerWeight
        }
        $script:AzureRmVirtualNetworkGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVirtualNetworkGatewayDetail)

        $script:AzureRmVirtualNetworkGatewayTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "GatewayType"                   = $_.GatewayType
            "VpnType"                       = $_.VpnType
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkGatewayDetailTable
        }
    }
    $script:Report += "<h3>Virtual Network Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmVirtualNetworkGatewayTable))
}
