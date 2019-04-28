function Save-AzureRmApplicationGatewayTable{
    $script:AzureRmApplicationGatewayTable = @()
    $script:AzureRmApplicationGateway | foreach{
        if($_.FrontendIPConfigurations.publicIPAddress.Id -match "/providers/Microsoft.Network/publicIPAddresses/[a-zA-Z0-9_.-]{1,80}$"){
            $FrontendPublicIPAddress = $Matches[0] -replace "/providers/Microsoft.Network/publicIPAddresses/", ""
        }
        
        $script:AzureRmApplicationGatewayAuthenticationCertificatesDetail = @()
        if($_.AuthenticationCertificates -ne $null){
            $_.AuthenticationCertificates | foreach{
                $script:AzureRmApplicationGatewayAuthenticationCertificatesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                }
            }
            $script:AzureRmApplicationGatewayAuthenticationCertificatesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayAuthenticationCertificatesDetail
        }
        
        $script:AzureRmApplicationGatewaySslCertificatesDetail = @()
        if($_.SslCertificates -ne $null){
            $_.SslCertificates | foreach{
                $script:AzureRmApplicationGatewaySslCertificatesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "PublicCertData"            = $_.PublicCertData
                }
            }
            $script:AzureRmApplicationGatewaySslCertificatesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewaySslCertificatesDetail
        }
        
        $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetail = @()
        if($_.GatewayIPConfigurations -ne $null){
            $_.GatewayIPConfigurations | foreach{
                $script:AzureRmApplicationGatewayGatewayIPConfigurationsSubnetId = $null
                if($_.Subnet.Id -ne $null){
                    $script:AzureRmApplicationGatewayGatewayIPConfigurationsSubnetId = "<a href=`"#$((($_.Subnet.Id) -Replace `"/subnets/.*$`",`"`").ToLower())`">$($_.Subnet.Id)</a>"
                }
                $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Subnet"                    = $script:AzureRmApplicationGatewayGatewayIPConfigurationsSubnetId
                }
            }
            $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetail
        }
        
        $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetail = @()
        if($_.FrontendIPConfigurations -ne $null){
            $_.FrontendIPConfigurations | foreach{
                $script:AzureRmApplicationGatewayGatewayIPConfigurationsPublicIPAddressId = $null
                if($_.PublicIPAddress.Id -ne $null){
                    $script:AzureRmApplicationGatewayGatewayIPConfigurationsPublicIPAddressId = "<a href=`"#$(($_.PublicIPAddress.Id).ToLower())`">$($_.PublicIPAddress.Id)</a>"
                }
                $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "PrivateIPAddress"          = $_.PrivateIPAddress
                    "PublicIPAddress"           = $script:AzureRmApplicationGatewayGatewayIPConfigurationsPublicIPAddressId
                    "PrivateIPAllocationMethod" = $_.PrivateIPAllocationMethod
                    "Subnet"                    = $_.Subnet
                }
            }
            $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetail
        }
        
        $script:AzureRmApplicationGatewayFrontendPortsDetail = @()
        if($_.FrontendPorts -ne $null){
            $_.FrontendPorts | foreach{
                $script:AzureRmApplicationGatewayFrontendPortsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Port"                      = $_.Port
                }
            }
            $script:AzureRmApplicationGatewayFrontendPortsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayFrontendPortsDetail
        }
        
        $script:AzureRmApplicationGatewayProbesDetail = @()
        if($_.Probes -ne $null){
            $_.Probes | foreach{
                $script:AzureRmApplicationGatewayProbesDetail += [PSCustomObject]@{
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
            $script:AzureRmApplicationGatewayProbesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayProbesDetail
        }
        
        $script:AzureRmApplicationGatewayHttpListenersDetail = @()
        if($_.HttpListeners -ne $null){
            $_.HttpListeners | foreach{
                $script:AzureRmApplicationGatewayHttpListenersDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "HostName"                      = $_.HostName
                    "Protocol"                      = $_.Protocol
                    "RequireServerNameIndication"   = $_.RequireServerNameIndication
                }
            }
            $script:AzureRmApplicationGatewayHttpListenersDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayHttpListenersDetail
        }

        $script:AzureRmApplicationGatewayUrlPathMapsDetail = @()
        if($_.UrlPathMaps -ne $null){
            $_.UrlPathMaps | foreach{
                $script:AzureRmApplicationGatewayUrlPathMapsDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "PathRules"                     = $_.PathRules
                }
            }
            $script:AzureRmApplicationGatewayUrlPathMapsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayUrlPathMapsDetail
        }

        $script:AzureRmApplicationGatewayRequestRoutingRulesDetail = @()
        if($_.RequestRoutingRules -ne $null){
            $_.RequestRoutingRules | foreach{
                $script:AzureRmApplicationGatewayRequestRoutingRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "RuleType"                  = $_.RuleType
                }
            }
            $script:AzureRmApplicationGatewayRequestRoutingRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayRequestRoutingRulesDetail
        }
        
        $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetail = @()
        if($_.BackendHttpSettingsCollection -ne $null){
            $_.BackendHttpSettingsCollection | foreach{
                $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "CookieBasedAffinity"           = $_.CookieBasedAffinity
                    "Port"                          = $_.Port
                    "Probe"                         = $_.Probe
                    "Protocol"                      = $_.Protocol
                    "RequestTimeout"                = $_.RequestTimeout
                }
            }
            $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetail
        }

        $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetail = @()
        if($_.WebApplicationFirewallConfiguration -ne $null){
            $_.WebApplicationFirewallConfiguration | foreach{
                $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetail += [PSCustomObject]@{
                    "Enabled"                   = $_.Enabled
                    "FirewallMode"              = $_.FirewallMode
                }
            }
            $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetail
        }

        $script:AzureRmApplicationGatewayRedirectConfigurationsDetail = @()
        if($_.RedirectConfigurations -ne $null){
            $_.RedirectConfigurations | foreach{
                $script:AzureRmApplicationGatewayRedirectConfigurationsDetail += [PSCustomObject]@{
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
            $script:AzureRmApplicationGatewayRedirectConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayRedirectConfigurationsDetail
        }

        $script:AzureRmApplicationGatewayDetail = [PSCustomObject]@{
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
            "AuthenticationCertificates"= ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayAuthenticationCertificatesDetailTable
            "SslCertificates"           = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewaySslCertificatesDetailTable
            "GatewayIPConfigurations"   = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetailTable
            "FrontendIPConfigurations"  = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetailTable
            "FrontendPublicIPAddress"   = ($script:AzureRmPublicIpAddress | where {($_.Name -eq $FrontendPublicIPAddress)}).IpAddress
            "FrontendPorts"             = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayFrontendPortsDetailTable
            "Probes"                    = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayProbesDetailTable
            "HttpListeners"             = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayHttpListenersDetailTable
            "UrlPathMaps"               = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayUrlPathMapsDetailTable
            "RequestRoutingRules"       = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayRequestRoutingRulesDetailTable
            "BackendAddressPools"       = $_.BackendAddressPools.BackendAddresses.IpAddress -join "<br>"
            "BackendHttpSettingsCollection" = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetailTable
            "WebApplicationFirewallConfiguration" = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetailTable
            "RedirectConfigurations"    = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayRedirectConfigurationsDetailTable
        }
        $script:AzureRmApplicationGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmApplicationGatewayDetail)

        $script:AzureRmApplicationGatewayTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Sku"                       = $_.Sku.Name
            "Capacity"                  = $_.Sku.Capacity
            "FrontendPrivateIPAddress"  = $_.FrontendIPConfigurations.PrivateIPAddress
            "FrontendPublicIPAddress"   = ($script:AzureRmPublicIpAddress | where {($_.Name -eq $FrontendPublicIPAddress)}).IpAddress
            "BackendAddressPools"       = $_.BackendAddressPools.BackendAddresses.IpAddress -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayDetailTable
        }
    }
    $script:Report += "<h3>Application Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmApplicationGatewayTable))
}