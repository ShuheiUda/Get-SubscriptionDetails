function Save-AzVirtualNetworkTable{
    $script:AzVirtualNetworkTable = @()
    $script:AzVirtualNetwork | foreach{
        $script:AzVirtualNetworkSubnetsDetail = @()
        $_.Subnets | foreach{
            $script:AzVirtualNetworkSubnetServiceEndpointsDetail = @()
            $script:AzVirtualNetworkSubnetServiceEndpointsDetailTable = $null
            if($_.ServiceEndpoints -ne $null){
                $_.ServiceEndpoints | foreach{
                    $script:AzVirtualNetworkSubnetServiceEndpointsDetail += [PSCustomObject]@{
                        "Service"               = $_.Service
                        "ProvisioningState"     = $_.ProvisioningState
                        "Locations"             = $_.Locations -join ", "
                    }
                }
                $script:AzVirtualNetworkSubnetServiceEndpointsDetailTable = New-HTMLTable -InputObject $script:AzVirtualNetworkSubnetServiceEndpointsDetail
            }

            $script:AzVirtualNetworkSubnetsRouteTableId = $null
            if($_.RouteTable.Id -ne $null){
                $script:AzVirtualNetworkSubnetsRouteTableId = "<a href=`"#$(($_.RouteTable.Id).ToLower())`">$($_.RouteTable.Id)</a>"
            }
            $script:AzVirtualNetworkSubnetsNetworkSecurityGroupId = $null
            if($_.NetworkSecurityGroup.Id -ne $null){
                $script:AzVirtualNetworkSubnetsNetworkSecurityGroupId = "<a href=`"#$(($_.NetworkSecurityGroup.Id).ToLower())`">$($_.NetworkSecurityGroup.Id)</a>"
            }
            $script:AzVirtualNetworkSubnetsDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "AddressPrefix"             = $_.AddressPrefix -join ""
                "ProvisioningState"         = $_.ProvisioningState
                "RouteTable"                = $script:AzVirtualNetworkSubnetsRouteTableId
                "NetworkSecurityGroup"      = $script:AzVirtualNetworkSubnetsNetworkSecurityGroupId
                "ServiceEndpoints"          = $script:AzVirtualNetworkSubnetServiceEndpointsDetailTable
                "IpConfigurations"          = $_.IpConfigurations.Id -join  "<br>"
            }
            $script:AzVirtualNetworkSubnetsDetailTable = New-HTMLTable -InputObject $script:AzVirtualNetworkSubnetsDetail
        }
        
        $script:AzVirtualNetworkPeering = Get-AzVirtualNetworkPeering -VirtualNetworkName $_.Name -ResourceGroupName $_.ResourceGroupName

        $script:AzVirtualNetworkPeeringsDetail = @()
        $script:AzVirtualNetworkPeeringsDetailTable = $null
        $script:AzVirtualNetworkPeeringRemoteVirtualNetworkId = @()
        if($script:AzVirtualNetworkPeering -ne $null){
            $script:AzVirtualNetworkPeering | foreach{
                $_.RemoteVirtualNetwork.id | foreach{
                    $script:AzVirtualNetworkPeeringRemoteVirtualNetworkId += "<a href=`"#$($_.ToLower())`">$_</a>"
                }
                $script:AzVirtualNetworkPeeringsDetail += [PSCustomObject]@{
                    "Name"                              = $_.Name
                    "ResourceGroupName"                 = $_.ResourceGroupName
                    "ProvisioningState"                 = $_.ProvisioningState
                    "PeeringState"                      = $_.PeeringState
                    "VirtualNetworkName"                = $_.VirtualNetworkName
                    "RemoteVirtualNetwork"              = $script:AzVirtualNetworkPeeringRemoteVirtualNetworkId -join "<br>"
                    "AllowVirtualNetworkAccess"         = $_.AllowVirtualNetworkAccess
                    "AllowForwardedTraffic"             = $_.AllowForwardedTraffic
                    "AllowGatewayTransit"               = $_.AllowGatewayTransit
                    "UseRemoteGateways"                 = $_.UseRemoteGateways
                    "RemoteGateways"                    = $_.RemoteGateways
                    "RemoteVirtualNetworkAddressSpace"  = $_.RemoteVirtualNetworkAddressSpace.AddressPrefixes -join "<br>"
                }
                $script:AzVirtualNetworkPeeringsDetailTable = New-HTMLTable -InputObject $script:AzVirtualNetworkPeeringsDetail
            }
        }

        $script:AzVirtualNetworkDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "AddressSpace"              = $_.AddressSpace.AddressPrefixes -join "<br>"
            "Subnets"                   = ConvertTo-DetailView -InputObject $script:AzVirtualNetworkSubnetsDetailTable
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
            "VirtualNetworkPeerings"    = ConvertTo-DetailView -InputObject $script:AzVirtualNetworkPeeringsDetailTable
            "EnableDDoSProtection"      = $_.EnableDDoSProtection
            "EnableVmProtection"        = $_.EnableVmProtection
        }
        $script:AzVirtualNetworkDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzVirtualNetworkDetail)

        $script:AzVirtualNetworkTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Address Space"             = $_.AddressSpace.AddressPrefixes -join ", "
            "Subnets"                   = $_.Subnets.AddressPrefix -join ", "
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzVirtualNetworkDetailTable
        }
    }
    $script:Report += "<h3>Virtual Network</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzVirtualNetworkTable))
}
