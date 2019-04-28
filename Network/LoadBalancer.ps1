function Save-AzureRmLoadBalancerTable{
    $script:AzureRmLoadBalancerTable = @()
    $script:AzureRmLoadBalancer | foreach{
        $script:AzureRmLoadBalancerFrontendIpConfigurationsDetail = @()
        $script:AzureRmLoadBalancerBackendAddressPoolsDetail = @()
        $script:AzureRmLoadBalancerLoadBalancingRulesDetail = @()
        $script:AzureRmLoadBalancerProbesDetail = @()
        $script:AzureRmLoadBalancerInboundNatRulesDetail = @()
        $script:AzureRmLoadBalancerInboundNatPoolsDetail = @()

        if($_.FrontendIpConfigurations -ne $null){
            $_.FrontendIpConfigurations | foreach{
                $script:AzureRmLoadBalancerFrontendIpConfigurationsPublicIpAddressId = $null
                if($_.PublicIpAddress.Id -ne $null){
                    $script:AzureRmLoadBalancerFrontendIpConfigurationsPublicIpAddressId = "<a href=`"#$(($_.PublicIpAddress.Id).ToLower())`">$($_.PublicIpAddress.Id)</a>"
                }
                $script:AzureRmLoadBalancerFrontendIpConfigurationsSubnetId = $null
                if($_.Subnet.Id -ne $null){
                    $script:AzureRmLoadBalancerFrontendIpConfigurationsSubnetId = "<a href=`"#$((($_.Subnet.Id) -Replace `"/subnets/.*$`",`"`").ToLower())`">$($_.Subnet.Id)</a>"
                }
                $script:AzureRmLoadBalancerFrontendIpConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "Zones"                     = $_.Zones -join "<br>"
                    "ProvisioningState"         = $_.ProvisioningState
                    "PublicIpAddress"           = $_.PublicIpAddress.IpAddress
                    "PublicIpAddress.Id"        = $script:AzureRmLoadBalancerFrontendIpConfigurationsPublicIpAddressId
                    "PrivateIpAddress"          = $_.PrivateIpAddress
                    "PrivateIpAllocationMethod" = $_.PrivateIpAllocationMethod
                    "Subnet.Id"                 = $script:AzureRmLoadBalancerFrontendIpConfigurationsSubnetId
                    "LoadBalancingRules.Id"     = $_.LoadBalancingRules.Id -join "<br>"
                    "InboundNatRules.Id"        = $_.InboundNatRules.Id -join "<br>"
                    "InboundNatPools.Id"        = $_.InboundNatPools.Id -join "<br>"
                }
            }
            $script:AzureRmLoadBalancerFrontendIpConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerFrontendIpConfigurationsDetail
        }

        if($_.BackendAddressPools -ne $null){
            $_.BackendAddressPools | foreach{
                $script:AzureRmLoadBalancerBackendAddressPoolsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "BackendIpConfigurations"   = $_.BackendIpConfigurations.Id -join "<br>"
                    "LoadBalancingRules"        = $_.LoadBalancingRules.Id -join "<br>"
                }
            }
            $script:AzureRmLoadBalancerBackendAddressPoolsDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerBackendAddressPoolsDetail
        }
        
        if($_.InboundNatPools -ne $null){
            $_.InboundNatPools | foreach{
                $script:AzureRmLoadBalancerInboundNatPoolsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPortRangeStart"    = $_.FrontendPortRangeStart
                    "FrontendPortRangeEnd"      = $_.FrontendPortRangeEnd
                    "BackendPort"               = $_.BackendPort
                    "Capacity"                  = $_.Capacity
                }
            }
            $script:AzureRmLoadBalancerDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerInboundNatPoolsDetail
        }

        if($_.Probes -ne $null){
            $_.Probes | foreach{
                $script:AzureRmLoadBalancerProbesDetail += [PSCustomObject]@{
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
            $script:AzureRmLoadBalancerProbesDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerProbesDetail
        }

        if($_.LoadBalancingRules -ne $null){
            $_.LoadBalancingRules | foreach{
                $script:AzureRmLoadBalancerLoadBalancingRulesDetail += [PSCustomObject]@{
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
            $script:AzureRmLoadBalancerLoadBalancingRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerLoadBalancingRulesDetail
        }
        
        if($_.InboundNatRules -ne $null){
            $_.InboundNatRules | foreach{
                $script:AzureRmLoadBalancerInboundNatRulesDetail += [PSCustomObject]@{
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
            $script:AzureRmLoadBalancerInboundNatRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerInboundNatRulesDetail
        }

        $script:AzureRmLoadBalancerDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "ProvisioningState"         = $_.ProvisioningState
            "Sku"                       = $_.Sku.Name
            "FrontendIpConfigurations"  = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerFrontendIpConfigurationsDetailTable
            "BackendAddresspools"       = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerBackendAddressPoolsDetailTable
            "InboundNatPools"           = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerInboundNatPoolsDetailTable
            "Probes"                    = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerProbesDetailTable
            "LoadBalancingRules"        = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerLoadBalancingRulesDetailTable
            "InboundNatRules"           = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerInboundNatRulesDetailTable
        }
        $script:AzureRmLoadBalancerDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmLoadBalancerDetail)

        $script:AzureRmLoadBalancerTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "FrontendIpConfigurations"  = $_.FrontendIpConfigurations.Name -join ", "
            "BackendAddresspools"       = $_.BackendAddressPools.Name -join ", "
            "InboundNatPools"           = $_.InboundNatPools.Name -join ", "
            "Probes"                    = $_.Probes.Name -join ", "
            "LoadBalancingRules"        = $_.LoadBalancingRules.Name -join ", "
            "InboundNatRules"           = $_.InboundNatRules.Name -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerDetailTable

        }
    }
    $script:Report += "<h3>Load Balancer</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmLoadBalancerTable))
}