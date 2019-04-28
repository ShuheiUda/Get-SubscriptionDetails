function Save-AzureRmNetworkInterfaceTable{
    $script:AzureRmNetworkInterfaceTable = @()
    $Script:AzureRmNetworkInterface | foreach{
        $VirtualMachine = $null
        $NetworkSecurityGroup = $null
        if($_.VirtualMachine.Id -match "/providers/Microsoft.Compute/virtualMachines/.{1,15}$"){
            $VirtualMachine = $Matches[0] -replace "/providers/Microsoft.Compute/virtualMachines/", ""
        }
        if($_.NetworkSecurityGroup.Id -match "/providers/Microsoft.Network/networkSecurityGroups/[a-zA-Z0-9_.-]{1,80}$"){
            $NetworkSecurityGroup = $Matches[0] -replace "/providers/Microsoft.Network/networkSecurityGroups/", ""
        }

        $script:AzureRmNetworkInterfaceIpConfigurationsDetail = @()
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
                
                $script:AzureRmNetworkInterfaceIpConfigurationsPublicIpAddressId = $null
                if($_.PublicIpAddress.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsPublicIpAddressId = "<a href=`"#$(($_.PublicIpAddress.Id).ToLower())`">$($_.PublicIpAddress.Id)</a>"
                }
                <#
                $script:AzureRmNetworkInterfaceIpConfigurationsServiceEndpointsId = $null
                if($_.Subnet.ServiceEndpoints.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsServiceEndpointsId = "<a href=`"#$((($_.Subnet.ServiceEndpoints.Id) -Replace `"/subnets/.*$`",`"`").ToLower())`">$($_.Subnet.ServiceEndpoints.Id)</a>"
                }
                $script:AzureRmNetworkInterfaceIpConfigurationsResourceNavigationLinksId = $null
                if($_.Subnet.ResourceNavigationLinks.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsResourceNavigationLinksId = "<a href=`"#$(($_.Subnet.ResourceNavigationLinks.Id).ToLower())`">$($_.Subnet.ResourceNavigationLinks.Id)</a>"
                }
                #>
                $script:AzureRmNetworkInterfaceIpConfigurationsLoadBalancerBackendAddressPoolsId = $null
                if($_.LoadBalancerBackendAddressPools.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsLoadBalancerBackendAddressPoolsId = "<a href=`"#$((($_.LoadBalancerBackendAddressPools.Id) -Replace `"/backendAddressPools/.*$`",`"`").ToLower())`">$($_.LoadBalancerBackendAddressPools.Id)</a>"
                }
                $script:AzureRmNetworkInterfaceIpConfigurationsLoadBalancerInboundNatRulesId = $null
                if($_.LoadBalancerInboundNatRules.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsLoadBalancerInboundNatRulesId = "<a href=`"#$((($_.LoadBalancerInboundNatRules.Id) -Replace `"/inboundNatRules/.*$`",`"`").ToLower())`">$($_.LoadBalancerInboundNatRules.Id)</a>"
                }
                $script:AzureRmNetworkInterfaceIpConfigurationsApplicationGatewayBackendAddressPoolsId = $null
                if($_.ApplicationGatewayBackendAddressPools.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsApplicationGatewayBackendAddressPoolsId = "<a href=`"#$((($_.ApplicationGatewayBackendAddressPools.Id) -Replace `"/backendAddressPools/.*$`",`"`").ToLower())`">$($_.ApplicationGatewayBackendAddressPools.Id)</a>"
                }
                $script:AzureRmNetworkInterfaceIpConfigurationsApplicationSecurityGroupsId = $null
                if($_.ApplicationSecurityGroups.Id -ne $null){
                    $script:AzureRmNetworkInterfaceIpConfigurationsApplicationSecurityGroupsId = "<a href=`"#$(($_.ApplicationSecurityGroups.Id).ToLower())`">$($_.ApplicationSecurityGroups.Id)</a>"
                }
                $script:AzureRmNetworkInterfaceIpConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Primary"                   = $_.Primary
                    "PrivateIpAddress"          = $_.PrivateIpAddress
                    "PrivateIpAddressVersion"   = $_.PrivateIpAddressVersion
                    "PrivateIpAllocationMethod" = $_.PrivateIpAllocationMethod
                    "VirtualNetwork"            = $VirtualNetwork
                    "Subnet"                    = $Subnet
                    "PublicIpAddress"           = $script:AzureRmNetworkInterfaceIpConfigurationsPublicIpAddressId
                    #"ServiceEndpoints"          = $script:AzureRmNetworkInterfaceIpConfigurationsServiceEndpointsId
                    #"ResourceNavigationLinks"   = $script:AzureRmNetworkInterfaceIpConfigurationsResourceNavigationLinksId
                    "LoadBalancerBackendAddressPools" = $script:AzureRmNetworkInterfaceIpConfigurationsLoadBalancerBackendAddressPoolsId
                    "LoadBalancerInboundNatRules" = $script:AzureRmNetworkInterfaceIpConfigurationsLoadBalancerInboundNatRulesId
                    "ApplicationGatewayBackendAddressPools" = $script:AzureRmNetworkInterfaceIpConfigurationsApplicationGatewayBackendAddressPoolsId
                    "ApplicationSecurityGroups" = $script:AzureRmNetworkInterfaceIpConfigurationsApplicationSecurityGroupsId
                }
            }
            $script:AzureRmNetworkInterfaceIpConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmNetworkInterfaceIpConfigurationsDetail

        }
        
        $script:AzureRmNetworkInterfaceVirtualMachineId = $null
        if($_.VirtualMachine.Id -ne $null){
            $script:AzureRmNetworkInterfaceVirtualMachineId = "<a href=`"#$(($_.VirtualMachine.Id).ToLower())`">$($_.VirtualMachine.Id)</a>"
        }
        $script:AzureRmNetworkInterfaceNetworkSecurityGroupId = $null
        if($_.NetworkSecurityGroup.Id -ne $null){
            $script:AzureRmNetworkInterfaceNetworkSecurityGroupId = "<a href=`"#$(($_.NetworkSecurityGroup.Id).ToLower())`">$($_.NetworkSecurityGroup.Id)</a>"
        }
        $script:AzureRmNetworkInterfaceDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "Id"                            = $_.Id
            "ResourceGuid"                  = $_.ResourceGuid
            "Virtual Machine"               = $script:AzureRmNetworkInterfaceVirtualMachineId
            "IpConfigurations"              = ConvertTo-DetailView -InputObject $script:AzureRmNetworkInterfaceIpConfigurationsDetailTable
            "MacAddress"                    = $_.MacAddress
            "DnsServers"                    = $_.DnsSettings.DnsServers -join "<br>"
            "AppliedDnsServers"             = $_.DnsSettings.AppliedDnsServers -join "<br>"
            "NetworkSecurityGroup"          = $script:AzureRmNetworkInterfaceNetworkSecurityGroupId
            "EnableIPForwarding"            = $_.EnableIPForwarding
            "EnableAcceleratedNetworking"   = $_.EnableAcceleratedNetworking
            "Primary"                       = $_.Primary
        }
        $script:AzureRmNetworkInterfaceDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmNetworkInterfaceDetail)

        $script:AzureRmNetworkInterfaceTable += [PSCustomObject]@{
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
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmNetworkInterfaceDetailTable
        }
    }
    $script:Report += "<h3>Network Interface</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmNetworkInterfaceTable))
}
