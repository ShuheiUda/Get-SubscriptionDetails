function Save-AzLoadBalancerTable{
    $script:AzLoadBalancerTable = @()
    $script:AzLoadBalancer | foreach{
        $script:AzLoadBalancerFrontendIpConfigurationsDetail = @()
        $script:AzLoadBalancerBackendAddressPoolsDetail = @()
        $script:AzLoadBalancerLoadBalancingRulesDetail = @()
        $script:AzLoadBalancerProbesDetail = @()
        $script:AzLoadBalancerInboundNatRulesDetail = @()
        $script:AzLoadBalancerInboundNatPoolsDetail = @()

        if($_.FrontendIpConfigurations -ne $null){
            $_.FrontendIpConfigurations | foreach{
                $script:AzLoadBalancerFrontendIpConfigurationsPublicIpAddressId = $null
                if($_.PublicIpAddress.Id -ne $null){
                    $script:AzLoadBalancerFrontendIpConfigurationsPublicIpAddressId = "<a href=`"#$(($_.PublicIpAddress.Id).ToLower())`">$($_.PublicIpAddress.Id)</a>"
                }
                $script:AzLoadBalancerFrontendIpConfigurationsSubnetId = $null
                if($_.Subnet.Id -ne $null){
                    $script:AzLoadBalancerFrontendIpConfigurationsSubnetId = "<a href=`"#$((($_.Subnet.Id) -Replace `"/subnets/.*$`",`"`").ToLower())`">$($_.Subnet.Id)</a>"
                }
                $script:AzLoadBalancerFrontendIpConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "Zones"                     = $_.Zones -join "<br>"
                    "ProvisioningState"         = $_.ProvisioningState
                    "PublicIpAddress"           = $_.PublicIpAddress.IpAddress
                    "PublicIpAddress.Id"        = $script:AzLoadBalancerFrontendIpConfigurationsPublicIpAddressId
                    "PrivateIpAddress"          = $_.PrivateIpAddress
                    "PrivateIpAllocationMethod" = $_.PrivateIpAllocationMethod
                    "Subnet.Id"                 = $script:AzLoadBalancerFrontendIpConfigurationsSubnetId
                    "LoadBalancingRules.Id"     = $_.LoadBalancingRules.Id -join "<br>"
                    "InboundNatRules.Id"        = $_.InboundNatRules.Id -join "<br>"
                    "InboundNatPools.Id"        = $_.InboundNatPools.Id -join "<br>"
                }
            }
            $script:AzLoadBalancerFrontendIpConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzLoadBalancerFrontendIpConfigurationsDetail
        }

        if($_.BackendAddressPools -ne $null){
            $_.BackendAddressPools | foreach{
                $script:AzLoadBalancerBackendAddressPoolsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "BackendIpConfigurations"   = $_.BackendIpConfigurations.Id -join "<br>"
                    "LoadBalancingRules"        = $_.LoadBalancingRules.Id -join "<br>"
                }
            }
            $script:AzLoadBalancerBackendAddressPoolsDetailTable = New-HTMLTable -InputObject $script:AzLoadBalancerBackendAddressPoolsDetail
        }
        
        if($_.InboundNatPools -ne $null){
            $_.InboundNatPools | foreach{
                $script:AzLoadBalancerInboundNatPoolsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPortRangeStart"    = $_.FrontendPortRangeStart
                    "FrontendPortRangeEnd"      = $_.FrontendPortRangeEnd
                    "BackendPort"               = $_.BackendPort
                    "Capacity"                  = $_.Capacity
                }
            }
            $script:AzLoadBalancerDetailTable = New-HTMLTable -InputObject $script:AzLoadBalancerInboundNatPoolsDetail
        }

        if($_.Probes -ne $null){
            $_.Probes | foreach{
                $script:AzLoadBalancerProbesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "Port"                      = $_.Port
                    "IntervalInSeconds"         = $_.IntervalInSeconds
                    "NumberOfProbes"            = $_.NumberOfProbes
                    "RequestPath"               = $_.RequestPath
                    "LoadBalancingRules"        = $_.LoadBalancingRules.Id
                }
            }
            $script:AzLoadBalancerProbesDetailTable = New-HTMLTable -InputObject $script:AzLoadBalancerProbesDetail
        }

        if($_.LoadBalancingRules -ne $null){
            $_.LoadBalancingRules | foreach{
                $script:AzLoadBalancerLoadBalancingRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPort"              = $_.FrontendPort
                    "BackendPort"               = $_.BackendPort
                    "LoadDistribution"          = $_.LoadDistribution
                    "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
                    "EnableFloatingIP"          = $_.EnableFloatingIP
                    "FrontendIPConfiguration"   = $_.FrontendIPConfiguration.Id
                    "BackendAddressPool"        = $_.BackendAddressPool.Id
                    "Probe"                     = $_.Probe.Id
                }
            }
            $script:AzLoadBalancerLoadBalancingRulesDetailTable = New-HTMLTable -InputObject $script:AzLoadBalancerLoadBalancingRulesDetail
        }
        
        if($_.InboundNatRules -ne $null){
            $_.InboundNatRules | foreach{
                $script:AzLoadBalancerInboundNatRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPort"              = $_.FrontendPort
                    "BackendPort"               = $_.BackendPort
                    "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
                    "EnableFloatingIP"          = $_.EnableFloatingIP
                    "FrontendIPConfiguration"   = $_.FrontendIPConfiguration.Id
                    "BackendIPConfiguration"    = $_.BackendIPConfiguration.Id
                }
            }
            $script:AzLoadBalancerInboundNatRulesDetailTable = New-HTMLTable -InputObject $script:AzLoadBalancerInboundNatRulesDetail
        }

        $script:AzLoadBalancerDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "ProvisioningState"         = $_.ProvisioningState
            "Sku"                       = $_.Sku.Name
            "FrontendIpConfigurations"  = ConvertTo-DetailView -InputObject $script:AzLoadBalancerFrontendIpConfigurationsDetailTable
            "BackendAddresspools"       = ConvertTo-DetailView -InputObject $script:AzLoadBalancerBackendAddressPoolsDetailTable
            "InboundNatPools"           = ConvertTo-DetailView -InputObject $script:AzLoadBalancerInboundNatPoolsDetailTable
            "Probes"                    = ConvertTo-DetailView -InputObject $script:AzLoadBalancerProbesDetailTable
            "LoadBalancingRules"        = ConvertTo-DetailView -InputObject $script:AzLoadBalancerLoadBalancingRulesDetailTable
            "InboundNatRules"           = ConvertTo-DetailView -InputObject $script:AzLoadBalancerInboundNatRulesDetailTable
        }
        $script:AzLoadBalancerDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzLoadBalancerDetail)

        $script:AzLoadBalancerTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Sku"                       = $_.Sku.Name
            "FrontendIpConfigurations"  = $_.FrontendIpConfigurations.Name -join ", "
            "BackendAddresspools"       = $_.BackendAddressPools.Name -join ", "
            "InboundNatPools"           = $_.InboundNatPools.Name -join ", "
            "Probes"                    = $_.Probes.Name -join ", "
            "LoadBalancingRules"        = $_.LoadBalancingRules.Name -join ", "
            "InboundNatRules"           = $_.InboundNatRules.Name -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzLoadBalancerDetailTable

        }
    }
    $script:Report += "<h3>Load Balancer</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzLoadBalancerTable))
}