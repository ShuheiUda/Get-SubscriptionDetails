function Save-AzVirtualNetworkGatewayConnection{
    $script:AzVirtualNetworkGatewayConnectionTable = @()
    $script:AzVirtualNetworkGatewayConnection | foreach{
        $script:AzVirtualNetworkGatewayConnectionVirtualNetworkGateway1Id = $null
        if($_.VirtualNetworkGateway1.Id -ne $null){
            $script:AzVirtualNetworkGatewayConnectionVirtualNetworkGateway1Id = "<a href=`"#$(($_.VirtualNetworkGateway1.Id).ToLower())`">$($_.VirtualNetworkGateway1.Id)</a>"
        }
        $script:AzVirtualNetworkGatewayConnectionVirtualNetworkGateway2Id = $null
        if($_.VirtualNetworkGateway2.Id -ne $null){
            $script:AzVirtualNetworkGatewayConnectionVirtualNetworkGateway2Id = "<a href=`"#$(($_.VirtualNetworkGateway2.Id).ToLower())`">$($_.VirtualNetworkGateway2.Id)</a>"
        }
        $script:AzVirtualNetworkGatewayConnectionLocalNetworkGateway2Id = $null
        if($_.LocalNetworkGateway2.Id -ne $null){
            $script:AzVirtualNetworkGatewayConnectionLocalNetworkGateway2Id = "<a href=`"#$(($_.LocalNetworkGateway2.Id).ToLower())`">$($_.LocalNetworkGateway2.Id)</a>"
        }
        $script:AzVirtualNetworkGatewayConnectionPeerId = $null
        if($_.Peer.Id -ne $null){
            $script:AzVirtualNetworkGatewayConnectionPeerId = "<a href=`"#$(($_.Peer.Id).ToLower())`">$($_.Peer.Id)</a>"
        }
        $script:AzVirtualNetworkGatewayConnectionDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "AuthorizationKey"          = $_.AuthorizationKey
            "VirtualNetworkGateway1"    = $script:AzVirtualNetworkGatewayConnectionVirtualNetworkGateway1Id
            "VirtualNetworkGateway2"    = $script:AzVirtualNetworkGatewayConnectionVirtualNetworkGateway2Id
            "LocalNetworkGateway2"      = $script:AzVirtualNetworkGatewayConnectionLocalNetworkGateway2Id
            "Peer"                      = $script:AzVirtualNetworkGatewayConnectionPeerId
            "RoutingWeight"             = $_.RoutingWeight
            "SharedKey"                 = $_ | Get-AzVirtualNetworkGatewayConnectionSharedKey
            "ConnectionStatus"          = $_.ConnectionStatus
            "EgressBytesTransferred"    = $_.EgressBytesTransferred
            "IngressBytesTransferred"   = $_.IngressBytesTransferred
            "TunnelConnectionStatus"    = $_.TunnelConnectionStatus
        }
        $script:AzVirtualNetworkGatewayConnectionDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzVirtualNetworkGatewayConnectionDetail)

        $script:AzVirtualNetworkGatewayConnectionTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzVirtualNetworkGatewayConnectionDetailTable
        }
    }
    $script:Report += "<h3>Virtual Network Gateway Connection</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzVirtualNetworkGatewayConnectionTable))
}