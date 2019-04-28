function Save-AzureRmVirtualNetworkGatewayConnection{
    $script:AzureRmVirtualNetworkGatewayConnectionTable = @()
    $script:AzureRmVirtualNetworkGatewayConnection | foreach{
        $script:AzureRmVirtualNetworkGatewayConnectionVirtualNetworkGateway1Id = $null
        if($_.VirtualNetworkGateway1.Id -ne $null){
            $script:AzureRmVirtualNetworkGatewayConnectionVirtualNetworkGateway1Id = "<a href=`"#$(($_.VirtualNetworkGateway1.Id).ToLower())`">$($_.VirtualNetworkGateway1.Id)</a>"
        }
        $script:AzureRmVirtualNetworkGatewayConnectionVirtualNetworkGateway2Id = $null
        if($_.VirtualNetworkGateway2.Id -ne $null){
            $script:AzureRmVirtualNetworkGatewayConnectionVirtualNetworkGateway2Id = "<a href=`"#$(($_.VirtualNetworkGateway2.Id).ToLower())`">$($_.VirtualNetworkGateway2.Id)</a>"
        }
        $script:AzureRmVirtualNetworkGatewayConnectionLocalNetworkGateway2Id = $null
        if($_.LocalNetworkGateway2.Id -ne $null){
            $script:AzureRmVirtualNetworkGatewayConnectionLocalNetworkGateway2Id = "<a href=`"#$(($_.LocalNetworkGateway2.Id).ToLower())`">$($_.LocalNetworkGateway2.Id)</a>"
        }
        $script:AzureRmVirtualNetworkGatewayConnectionPeerId = $null
        if($_.Peer.Id -ne $null){
            $script:AzureRmVirtualNetworkGatewayConnectionPeerId = "<a href=`"#$(($_.Peer.Id).ToLower())`">$($_.Peer.Id)</a>"
        }
        $script:AzureRmVirtualNetworkGatewayConnectionDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "AuthorizationKey"          = $_.AuthorizationKey
            "VirtualNetworkGateway1"    = $script:AzureRmVirtualNetworkGatewayConnectionVirtualNetworkGateway1Id
            "VirtualNetworkGateway2"    = $script:AzureRmVirtualNetworkGatewayConnectionVirtualNetworkGateway2Id
            "LocalNetworkGateway2"      = $script:AzureRmVirtualNetworkGatewayConnectionLocalNetworkGateway2Id
            "Peer"                      = $script:AzureRmVirtualNetworkGatewayConnectionPeerId
            "RoutingWeight"             = $_.RoutingWeight
            "SharedKey"                 = $_.SharedKey
            "ConnectionStatus"          = $_.ConnectionStatus
            "EgressBytesTransferred"    = $_.EgressBytesTransferred
            "IngressBytesTransferred"   = $_.IngressBytesTransferred
            "TunnelConnectionStatus"    = $_.TunnelConnectionStatus
        }
        $script:AzureRmVirtualNetworkGatewayConnectionDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVirtualNetworkGatewayConnectionDetail)

        $script:AzureRmVirtualNetworkGatewayConnectionTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkGatewayConnectionDetailTable
        }
    }
    $script:Report += "<h3>Virtual Network Gateway Connection</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmVirtualNetworkGatewayConnectionTable))
}