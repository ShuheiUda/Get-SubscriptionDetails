function Save-AzureRmVirtualNetworkTable{
    $script:AzureRmVirtualNetworkTable = @()
    $script:AzureRmVirtualNetwork | foreach{
        $script:AzureRmVirtualNetworkSubnetsDetail = @()
        $_.Subnets | foreach{
            $script:AzureRmVirtualNetworkSubnetServiceEndpointsDetail = @()
            $script:AzureRmVirtualNetworkSubnetServiceEndpointsDetailTable = $null
            if($_.ServiceEndpoints -ne $null){
                $_.ServiceEndpoints | foreach{
                    $script:AzureRmVirtualNetworkSubnetServiceEndpointsDetail += [PSCustomObject]@{
                        "Service"               = $_.Service
                        "ProvisioningState"     = $_.ProvisioningState
                        "Locations"             = $_.Locations -join ", "
                    }
                }
                $script:AzureRmVirtualNetworkSubnetServiceEndpointsDetailTable = New-HTMLTable -InputObject $script:AzureRmVirtualNetworkSubnetServiceEndpointsDetail
            }

            $script:AzureRmVirtualNetworkSubnetsRouteTableId = $null
            if($_.RouteTable.Id -ne $null){
                $script:AzureRmVirtualNetworkSubnetsRouteTableId = "<a href=`"#$(($_.RouteTable.Id).ToLower())`">$($_.RouteTable.Id)</a>"
            }
            $script:AzureRmVirtualNetworkSubnetsNetworkSecurityGroupId = $null
            if($_.NetworkSecurityGroup.Id -ne $null){
                $script:AzureRmVirtualNetworkSubnetsNetworkSecurityGroupId = "<a href=`"#$(($_.NetworkSecurityGroup.Id).ToLower())`">$($_.NetworkSecurityGroup.Id)</a>"
            }
            $script:AzureRmVirtualNetworkSubnetsDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "AddressPrefix"             = $_.AddressPrefix
                "ProvisioningState"         = $_.ProvisioningState
                "RouteTable"                = $script:AzureRmVirtualNetworkSubnetsRouteTableId
                "NetworkSecurityGroup"      = $script:AzureRmVirtualNetworkSubnetsNetworkSecurityGroupId
                "ServiceEndpoints"          = $script:AzureRmVirtualNetworkSubnetServiceEndpointsDetailTable
                "IpConfigurations"          = $_.IpConfigurations.Id -join  "<br>"
            }
            $script:AzureRmVirtualNetworkSubnetsDetailTable = New-HTMLTable -InputObject $script:AzureRmVirtualNetworkSubnetsDetail
        }
        
        $script:AzureRmVirtualNetworkPeering = Get-AzureRmVirtualNetworkPeering -VirtualNetworkName $_.Name -ResourceGroupName $_.ResourceGroupName

        $script:AzureRmVirtualNetworkPeeringsDetail = @()
        $script:AzureRmVirtualNetworkPeeringsDetailTable = $null
        $script:AzureRmVirtualNetworkPeeringRemoteVirtualNetworkId = @()
        if($script:AzureRmVirtualNetworkPeering -ne $null){
            $script:AzureRmVirtualNetworkPeering | foreach{
                $_.RemoteVirtualNetwork.id | foreach{
                    $script:AzureRmVirtualNetworkPeeringRemoteVirtualNetworkId += "<a href=`"#$($_.ToLower())`">$_</a>"
                }
                $script:AzureRmVirtualNetworkPeeringsDetail += [PSCustomObject]@{
                    "Name"                              = $_.Name
                    "ResourceGroupName"                 = $_.ResourceGroupName
                    "ProvisioningState"                 = $_.ProvisioningState
                    "PeeringState"                      = $_.PeeringState
                    "VirtualNetworkName"                = $_.VirtualNetworkName
                    "RemoteVirtualNetwork"              = $script:AzureRmVirtualNetworkPeeringRemoteVirtualNetworkId -join "<br>"
                    "AllowVirtualNetworkAccess"         = $_.AllowVirtualNetworkAccess
                    "AllowForwardedTraffic"             = $_.AllowForwardedTraffic
                    "AllowGatewayTransit"               = $_.AllowGatewayTransit
                    "UseRemoteGateways"                 = $_.UseRemoteGateways
                    "RemoteGateways"                    = $_.RemoteGateways
                    "RemoteVirtualNetworkAddressSpace"  = $_.RemoteVirtualNetworkAddressSpace
                }
                $script:AzureRmVirtualNetworkPeeringsDetailTable = New-HTMLTable -InputObject $script:AzureRmVirtualNetworkPeeringsDetail
            }
        }

        $script:AzureRmVirtualNetworkDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "AddressSpace"              = $_.AddressSpace.AddressPrefixes -join "<br>"
            "Subnets"                   = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkSubnetsDetailTable
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
            "VirtualNetworkPeerings"    = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkPeeringsDetailTable
            "EnableDDoSProtection"      = $_.EnableDDoSProtection
            "EnableVmProtection"        = $_.EnableVmProtection
        }
        $script:AzureRmVirtualNetworkDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVirtualNetworkDetail)

        $script:AzureRmVirtualNetworkTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Address Space"             = $_.AddressSpace.AddressPrefixes -join ", "
            "Subnets"                   = $_.Subnets.AddressPrefix -join ", "
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkDetailTable
        }
    }
    $script:Report += "<h3>Virtual Network</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmVirtualNetworkTable))
}
