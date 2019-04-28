function Save-AzureRmLocalNetworkGatewayTable{
    $script:AzureRmLocalNetworkGatewayTable = @()
    $script:AzureRmLocalNetworkGateway | foreach{
        $script:AzureRmLocalNetworkGatewayDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "GatewayIpAddress"          = $_.GatewayIpAddress
            "LocalNetworkAddressSpace"  = $_.LocalNetworkAddressSpace.AddressPrefixes -join "<br>"
            "Asn"                       = $_.BgpSettings.Asn
            "BgpPeeringAddress"         = $_.BgpSettings.BgpPeeringAddress
            "PeerWeight"                = $_.BgpSettings.PeerWeight
        }
        $script:AzureRmLocalNetworkGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmLocalNetworkGatewayDetail)

        $script:AzureRmLocalNetworkGatewayTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "GatewayIpAddress"          = $_.GatewayIpAddress
            "LocalNetworkAddressSpace"  = $_.LocalNetworkAddressSpace.AddressPrefixes -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmLocalNetworkGatewayDetailTable
        }
    }
    $script:Report += "<h3>Local Network Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmLocalNetworkGatewayTable))
}