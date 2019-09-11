function Save-AzNetworkInterfaceTable{
    $script:AzNetworkInterfaceTable = @()
    $Script:AzNetworkInterface | foreach{
        $VirtualMachine = $null
        $NetworkSecurityGroup = $null
        if($_.VirtualMachine.Id -match "/providers/Microsoft.Compute/virtualMachines/.{1,15}$"){
            $VirtualMachine = $Matches[0] -replace "/providers/Microsoft.Compute/virtualMachines/", ""
        }
        if($_.NetworkSecurityGroup.Id -match "/providers/Microsoft.Network/networkSecurityGroups/[a-zA-Z0-9_.-]{1,80}$"){
            $NetworkSecurityGroup = $Matches[0] -replace "/providers/Microsoft.Network/networkSecurityGroups/", ""
        }

        $script:AzNetworkInterfaceIpConfigurationsDetail = @()
        if($_.IpConfigurations -ne $null){
            $_.IpConfigurations | foreach{
                $TempSubnetId = $null
                $VirtualNetwork = $null
                $Subnet = $null
                if($_.Subnet.Id -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
                    $TempSubnetId = $Subnet = $Matches[0] -split "/"
                    $VirtualNetwork = $TempSubnetId[4]
                    $Subnet = $TempSubnetId[6]
                }
                
                $script:AzNetworkInterfaceIpConfigurationsPublicIpAddressId = $null
                if($_.PublicIpAddress.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsPublicIpAddressId = "<a href=`"#$(($_.PublicIpAddress.Id).ToLower())`">$($_.PublicIpAddress.Id)</a>"
                }
                <#
                $script:AzNetworkInterfaceIpConfigurationsServiceEndpointsId = $null
                if($_.Subnet.ServiceEndpoints.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsServiceEndpointsId = "<a href=`"#$((($_.Subnet.ServiceEndpoints.Id) -Replace `"/subnets/.*$`",`"`").ToLower())`">$($_.Subnet.ServiceEndpoints.Id)</a>"
                }
                $script:AzNetworkInterfaceIpConfigurationsResourceNavigationLinksId = $null
                if($_.Subnet.ResourceNavigationLinks.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsResourceNavigationLinksId = "<a href=`"#$(($_.Subnet.ResourceNavigationLinks.Id).ToLower())`">$($_.Subnet.ResourceNavigationLinks.Id)</a>"
                }
                #>
                $script:AzNetworkInterfaceIpConfigurationsLoadBalancerBackendAddressPoolsId = $null
                if($_.LoadBalancerBackendAddressPools.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsLoadBalancerBackendAddressPoolsId = "<a href=`"#$((($_.LoadBalancerBackendAddressPools.Id) -Replace `"/backendAddressPools/.*$`",`"`").ToLower())`">$($_.LoadBalancerBackendAddressPools.Id)</a>"
                }
                $script:AzNetworkInterfaceIpConfigurationsLoadBalancerInboundNatRulesId = $null
                if($_.LoadBalancerInboundNatRules.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsLoadBalancerInboundNatRulesId = "<a href=`"#$((($_.LoadBalancerInboundNatRules.Id) -Replace `"/inboundNatRules/.*$`",`"`").ToLower())`">$($_.LoadBalancerInboundNatRules.Id)</a>"
                }
                $script:AzNetworkInterfaceIpConfigurationsApplicationGatewayBackendAddressPoolsId = $null
                if($_.ApplicationGatewayBackendAddressPools.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsApplicationGatewayBackendAddressPoolsId = "<a href=`"#$((($_.ApplicationGatewayBackendAddressPools.Id) -Replace `"/backendAddressPools/.*$`",`"`").ToLower())`">$($_.ApplicationGatewayBackendAddressPools.Id)</a>"
                }
                $script:AzNetworkInterfaceIpConfigurationsApplicationSecurityGroupsId = $null
                if($_.ApplicationSecurityGroups.Id -ne $null){
                    $script:AzNetworkInterfaceIpConfigurationsApplicationSecurityGroupsId = "<a href=`"#$(($_.ApplicationSecurityGroups.Id).ToLower())`">$($_.ApplicationSecurityGroups.Id)</a>"
                }
                $script:AzNetworkInterfaceIpConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Primary"                   = $_.Primary
                    "PrivateIpAddress"          = $_.PrivateIpAddress
                    "PrivateIpAddressVersion"   = $_.PrivateIpAddressVersion
                    "PrivateIpAllocationMethod" = $_.PrivateIpAllocationMethod
                    "VirtualNetwork"            = $VirtualNetwork
                    "Subnet"                    = $Subnet
                    "PublicIpAddress"           = $script:AzNetworkInterfaceIpConfigurationsPublicIpAddressId
                    #"ServiceEndpoints"          = $script:AzNetworkInterfaceIpConfigurationsServiceEndpointsId
                    #"ResourceNavigationLinks"   = $script:AzNetworkInterfaceIpConfigurationsResourceNavigationLinksId
                    "LoadBalancerBackendAddressPools" = $script:AzNetworkInterfaceIpConfigurationsLoadBalancerBackendAddressPoolsId
                    "LoadBalancerInboundNatRules" = $script:AzNetworkInterfaceIpConfigurationsLoadBalancerInboundNatRulesId
                    "ApplicationGatewayBackendAddressPools" = $script:AzNetworkInterfaceIpConfigurationsApplicationGatewayBackendAddressPoolsId
                    "ApplicationSecurityGroups" = $script:AzNetworkInterfaceIpConfigurationsApplicationSecurityGroupsId
                }
            }
            $script:AzNetworkInterfaceIpConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzNetworkInterfaceIpConfigurationsDetail

        }
        
        $script:AzNetworkInterfaceVirtualMachineId = $null
        if($_.VirtualMachine.Id -ne $null){
            $script:AzNetworkInterfaceVirtualMachineId = "<a href=`"#$(($_.VirtualMachine.Id).ToLower())`">$($_.VirtualMachine.Id)</a>"
        }
        $script:AzNetworkInterfaceNetworkSecurityGroupId = $null
        if($_.NetworkSecurityGroup.Id -ne $null){
            $script:AzNetworkInterfaceNetworkSecurityGroupId = "<a href=`"#$(($_.NetworkSecurityGroup.Id).ToLower())`">$($_.NetworkSecurityGroup.Id)</a>"
        }
        $script:AzNetworkInterfaceDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "Id"                            = $_.Id
            "ResourceGuid"                  = $_.ResourceGuid
            "Virtual Machine"               = $script:AzNetworkInterfaceVirtualMachineId
            "IpConfigurations"              = ConvertTo-DetailView -InputObject $script:AzNetworkInterfaceIpConfigurationsDetailTable
            "MacAddress"                    = $_.MacAddress
            "DnsServers"                    = $_.DnsSettings.DnsServers -join "<br>"
            "AppliedDnsServers"             = $_.DnsSettings.AppliedDnsServers -join "<br>"
            "NetworkSecurityGroup"          = $script:AzNetworkInterfaceNetworkSecurityGroupId
            "EnableIPForwarding"            = $_.EnableIPForwarding
            "EnableAcceleratedNetworking"   = $_.EnableAcceleratedNetworking
            "Primary"                       = $_.Primary
        }
        $script:AzNetworkInterfaceDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzNetworkInterfaceDetail)

        $script:AzNetworkInterfaceTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "Virtual Machine"               = $VirtualMachine
            "VirtualNetwork"                = $VirtualNetwork
            "Subnet"                        = $Subnet
            "PrivateIpAddress"              = $_.IpConfigurations.PrivateIpAddress -join ", "
            "PrivateIpAllocationMethod"     = $_.IpConfigurations.PrivateIpAllocationMethod -join ", "
            "CustomeDnsSettings"            = $_.DnsSettings.DnsServers -join ", "
            "NetworkSecurityGroup"          = $NetworkSecurityGroup
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzNetworkInterfaceDetailTable
        }
    }
    $script:Report += "<h3>Network Interface</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzNetworkInterfaceTable))
}
