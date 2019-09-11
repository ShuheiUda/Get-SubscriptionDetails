function Save-AzApplicationGatewayTable{
    $script:AzApplicationGatewayTable = @()
    $script:AzApplicationGateway | foreach{
        if($_.FrontendIPConfigurations.publicIPAddress.Id -match "/providers/Microsoft.Network/publicIPAddresses/[a-zA-Z0-9_.-]{1,80}$"){
            $FrontendPublicIPAddress = $Matches[0] -replace "/providers/Microsoft.Network/publicIPAddresses/", ""
        }
        
        $script:AzApplicationGatewayAuthenticationCertificatesDetail = @()
        if($_.AuthenticationCertificates -ne $null){
            $_.AuthenticationCertificates | foreach{
                $script:AzApplicationGatewayAuthenticationCertificatesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                }
            }
            $script:AzApplicationGatewayAuthenticationCertificatesDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayAuthenticationCertificatesDetail
        }
        
        $script:AzApplicationGatewaySslCertificatesDetail = @()
        if($_.SslCertificates -ne $null){
            $_.SslCertificates | foreach{
                $script:AzApplicationGatewaySslCertificatesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "PublicCertData"            = $_.PublicCertData
                }
            }
            $script:AzApplicationGatewaySslCertificatesDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewaySslCertificatesDetail
        }
        
        $script:AzApplicationGatewayGatewayIPConfigurationsDetail = @()
        if($_.GatewayIPConfigurations -ne $null){
            $_.GatewayIPConfigurations | foreach{
                $script:AzApplicationGatewayGatewayIPConfigurationsSubnetId = $null
                if($_.Subnet.Id -ne $null){
                    $script:AzApplicationGatewayGatewayIPConfigurationsSubnetId = "<a href=`"#$((($_.Subnet.Id) -Replace `"/subnets/.*$`",`"`").ToLower())`">$($_.Subnet.Id)</a>"
                }
                $script:AzApplicationGatewayGatewayIPConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Subnet"                    = $script:AzApplicationGatewayGatewayIPConfigurationsSubnetId
                }
            }
            $script:AzApplicationGatewayGatewayIPConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayGatewayIPConfigurationsDetail
        }
        
        $script:AzApplicationGatewayFrontendIPConfigurationsDetail = @()
        if($_.FrontendIPConfigurations -ne $null){
            $_.FrontendIPConfigurations | foreach{
                $script:AzApplicationGatewayGatewayIPConfigurationsPublicIPAddressId = $null
                if($_.PublicIPAddress.Id -ne $null){
                    $script:AzApplicationGatewayGatewayIPConfigurationsPublicIPAddressId = "<a href=`"#$(($_.PublicIPAddress.Id).ToLower())`">$($_.PublicIPAddress.Id)</a>"
                }
                $script:AzApplicationGatewayFrontendIPConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "PrivateIPAddress"          = $_.PrivateIPAddress
                    "PublicIPAddress"           = $script:AzApplicationGatewayGatewayIPConfigurationsPublicIPAddressId
                    "PrivateIPAllocationMethod" = $_.PrivateIPAllocationMethod
                    "Subnet"                    = $_.Subnet
                }
            }
            $script:AzApplicationGatewayFrontendIPConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayFrontendIPConfigurationsDetail
        }
        
        $script:AzApplicationGatewayFrontendPortsDetail = @()
        if($_.FrontendPorts -ne $null){
            $_.FrontendPorts | foreach{
                $script:AzApplicationGatewayFrontendPortsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Port"                      = $_.Port
                }
            }
            $script:AzApplicationGatewayFrontendPortsDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayFrontendPortsDetail
        }
        
        $script:AzApplicationGatewayProbesDetail = @()
        if($_.Probes -ne $null){
            $_.Probes | foreach{
                $script:AzApplicationGatewayProbesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Host"                      = $_.Host
                    "Interval"                  = $_.Interval
                    "Path"                      = $_.Path
                    "Protocol"                  = $_.Protocol
                    "Timeout"                   = $_.Timeout
                    "UnhealthyThreshold"        = $_.UnhealthyThreshold
                }
            }
            $script:AzApplicationGatewayProbesDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayProbesDetail
        }
        
        $script:AzApplicationGatewayHttpListenersDetail = @()
        if($_.HttpListeners -ne $null){
            $_.HttpListeners | foreach{
                $script:AzApplicationGatewayHttpListenersDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "HostName"                      = $_.HostName
                    "Protocol"                      = $_.Protocol
                    "RequireServerNameIndication"   = $_.RequireServerNameIndication
                }
            }
            $script:AzApplicationGatewayHttpListenersDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayHttpListenersDetail
        }

        $script:AzApplicationGatewayUrlPathMapsDetail = @()
        if($_.UrlPathMaps -ne $null){
            $_.UrlPathMaps | foreach{
                $script:AzApplicationGatewayUrlPathMapsDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "PathRules"                     = $_.PathRules
                }
            }
            $script:AzApplicationGatewayUrlPathMapsDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayUrlPathMapsDetail
        }

        $script:AzApplicationGatewayRequestRoutingRulesDetail = @()
        if($_.RequestRoutingRules -ne $null){
            $_.RequestRoutingRules | foreach{
                $script:AzApplicationGatewayRequestRoutingRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "RuleType"                  = $_.RuleType
                }
            }
            $script:AzApplicationGatewayRequestRoutingRulesDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayRequestRoutingRulesDetail
        }
        
        $script:AzApplicationGatewayBackendHttpSettingsCollectionDetail = @()
        if($_.BackendHttpSettingsCollection -ne $null){
            $_.BackendHttpSettingsCollection | foreach{
                $script:AzApplicationGatewayBackendHttpSettingsCollectionDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "CookieBasedAffinity"           = $_.CookieBasedAffinity
                    "Port"                          = $_.Port
                    "Probe"                         = $_.Probe
                    "Protocol"                      = $_.Protocol
                    "RequestTimeout"                = $_.RequestTimeout
                }
            }
            $script:AzApplicationGatewayBackendHttpSettingsCollectionDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayBackendHttpSettingsCollectionDetail
        }

        $script:AzApplicationGatewayWebApplicationFirewallConfigurationDetail = @()
        if($_.WebApplicationFirewallConfiguration -ne $null){
            $_.WebApplicationFirewallConfiguration | foreach{
                $script:AzApplicationGatewayWebApplicationFirewallConfigurationDetail += [PSCustomObject]@{
                    "Enabled"                   = $_.Enabled
                    "FirewallMode"              = $_.FirewallMode
                }
            }
            $script:AzApplicationGatewayWebApplicationFirewallConfigurationDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayWebApplicationFirewallConfigurationDetail
        }

        $script:AzApplicationGatewayRedirectConfigurationsDetail = @()
        if($_.RedirectConfigurations -ne $null){
            $_.RedirectConfigurations | foreach{
                $script:AzApplicationGatewayRedirectConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "IncludePath"               = $_.IncludePath
                    "IncludeQueryString"        = $_.IncludeQueryString
                    "PathRules"                 = $_.PathRules
                    "RedirectType"              = $_.RedirectType
                    "RequestRoutingRules"       = $_.RequestRoutingRules.Id
                    "TargetListener"            = $_.TargetListener
                    "TargetUrl"                 = $_.TargetUrl
                    "UrlPathMaps"               = $_.UrlPathMaps.Id
                }
            }
            $script:AzApplicationGatewayRedirectConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzApplicationGatewayRedirectConfigurationsDetail
        }

        $script:AzApplicationGatewayDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Type"                      = $_.Type
            "OperationalState"          = $_.OperationalState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "Sku"                       = $_.Sku.Name
            "Capacity"                  = $_.Sku.Capacity
            "SslPolicy"                 = $_.SslPolicy
            "AuthenticationCertificates"= ConvertTo-DetailView -InputObject $script:AzApplicationGatewayAuthenticationCertificatesDetailTable
            "SslCertificates"           = ConvertTo-DetailView -InputObject $script:AzApplicationGatewaySslCertificatesDetailTable
            "GatewayIPConfigurations"   = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayGatewayIPConfigurationsDetailTable
            "FrontendIPConfigurations"  = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayFrontendIPConfigurationsDetailTable
            "FrontendPublicIPAddress"   = ($script:AzPublicIpAddress | where {($_.Name -eq $FrontendPublicIPAddress)}).IpAddress
            "FrontendPorts"             = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayFrontendPortsDetailTable
            "Probes"                    = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayProbesDetailTable
            "HttpListeners"             = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayHttpListenersDetailTable
            "UrlPathMaps"               = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayUrlPathMapsDetailTable
            "RequestRoutingRules"       = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayRequestRoutingRulesDetailTable
            "BackendAddressPools"       = $_.BackendAddressPools.BackendAddresses.IpAddress -join "<br>"
            "BackendHttpSettingsCollection" = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayBackendHttpSettingsCollectionDetailTable
            "WebApplicationFirewallConfiguration" = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayWebApplicationFirewallConfigurationDetailTable
            "RedirectConfigurations"    = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayRedirectConfigurationsDetailTable
        }
        $script:AzApplicationGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzApplicationGatewayDetail)

        $script:AzApplicationGatewayTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Sku"                       = $_.Sku.Name
            "Capacity"                  = $_.Sku.Capacity
            "FrontendPrivateIPAddress"  = $_.FrontendIPConfigurations.PrivateIPAddress
            "FrontendPublicIPAddress"   = ($script:AzPublicIpAddress | where {($_.Name -eq $FrontendPublicIPAddress)}).IpAddress
            "BackendAddressPools"       = $_.BackendAddressPools.BackendAddresses.IpAddress -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzApplicationGatewayDetailTable
        }
    }
    $script:Report += "<h3>Application Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzApplicationGatewayTable))
}