
function Save-AzExpressRouteCircuitTable{
    $script:AzExpressRouteCircuitTable = @()
    if($script:AzExpressRouteCircuit -ne $null){
        $script:AzExpressRouteCircuit | foreach{
            $AzExpressRouteCircuitName = $_.Name
            $AzExpressRouteCircuitResourceGroupName = $_.ResourceGroupName
            $script:AzExpressRouteCircuitPeeringsDetail = @()
            if($_.peerings -ne $null){
                $_.Peerings | foreach{
                    $script:AzExpressRouteCircuitPeeringARPTablePrimaryDetail = @()
                    $script:AzExpressRouteCircuitPeeringARPTableSecondaryDetail = @()
                    $script:AzExpressRouteCircuitPeeringARPTablePrimaryDetailTable = $null
                    $script:AzExpressRouteCircuitPeeringARPTableSecondaryDetailTable = $null
                    $script:AzExpressRouteCircuitPeeringARPTablePrimary = Get-AzExpressRouteCircuitARPTable -ExpressRouteCircuitName $AzExpressRouteCircuitName -ResourceGroupName $AzExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Primary
                    $script:AzExpressRouteCircuitPeeringARPTableSecondary = Get-AzExpressRouteCircuitARPTable -ExpressRouteCircuitName $AzExpressRouteCircuitName -ResourceGroupName $AzExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Secondary

                    $script:AzExpressRouteCircuitPeeringARPTablePrimary | foreach{
                        $script:AzExpressRouteCircuitPeeringARPTablePrimaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Primary"
                            "Age"                           = $_.Age
                            "InterfaceProperty"             = $_.InterfaceProperty
                            "IpAddress"                     = $_.IpAddress
                            "MacAddress"                    = $_.MacAddress
                        }
                    }
                    $script:AzExpressRouteCircuitPeeringARPTablePrimaryDetailTable = New-HTMLTable -InputObject $script:AzExpressRouteCircuitPeeringARPTablePrimaryDetail

                    $script:AzExpressRouteCircuitPeeringARPTableSecondary | foreach{
                        $script:AzExpressRouteCircuitPeeringARPTableSecondaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Secondary"
                            "Age"                           = $_.Age
                            "InterfaceProperty"             = $_.InterfaceProperty
                            "IpAddress"                     = $_.IpAddress
                            "MacAddress"                    = $_.MacAddress
                        }
                    }
                    $script:AzExpressRouteCircuitPeeringARPTableSecondaryDetailTable = New-HTMLTable -InputObject $script:AzExpressRouteCircuitPeeringARPTableSecondaryDetail

                    $script:AzExpressRouteCircuitPeeringRouteTablePrimaryDetail = @()
                    $script:AzExpressRouteCircuitPeeringRouteTableSecondaryDetail = @()
                    $script:AzExpressRouteCircuitPeeringRouteTablePrimaryDetailTable = $null
                    $script:AzExpressRouteCircuitPeeringRouteTableSecondaryDetailTable = $null
                    $script:AzExpressRouteCircuitPeeringRouteTablePrimary = Get-AzExpressRouteCircuitRouteTable -ExpressRouteCircuitName $AzExpressRouteCircuitName -ResourceGroupName $AzExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Primary
                    $script:AzExpressRouteCircuitPeeringRouteTableSecondary = Get-AzExpressRouteCircuitRouteTable -ExpressRouteCircuitName $AzExpressRouteCircuitName -ResourceGroupName $AzExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Secondary

                    $script:AzExpressRouteCircuitPeeringRouteTablePrimary | foreach{
                        $script:AzExpressRouteCircuitPeeringRouteTablePrimaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Primary"
                            "Network"                       = $_.Network
                            "NextHop"                       = $_.NextHop
                            "Path"                          = $_.Path
                            "LocPrf"                        = $_.LocPrf
                            "Weight"                        = $_.Weight
                        }
                    }
                    $script:AzExpressRouteCircuitPeeringRouteTablePrimaryDetailTable = New-HTMLTable -InputObject $script:AzExpressRouteCircuitPeeringRouteTablePrimaryDetail

                    $script:AzExpressRouteCircuitPeeringRouteTableSecondary | foreach{
                        $script:AzExpressRouteCircuitPeeringRouteTableSecondaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Secondary"
                            "Network"                       = $_.Network
                            "NextHop"                       = $_.NextHop
                            "Path"                          = $_.Path
                            "LocPrf"                        = $_.LocPrf
                            "Weight"                        = $_.Weight
                        }
                    }
                    $script:AzExpressRouteCircuitPeeringRouteTableSecondaryDetailTable = New-HTMLTable -InputObject $script:AzExpressRouteCircuitPeeringRouteTableSecondaryDetail

                    $script:AzExpressRouteCircuitPeeringsDetail += [PSCustomObject]@{
                        "Name"                                            = $_.Name
                        "ProvisioningState"                               = $_.ProvisioningState
                        "PeeringType"                                     = $_.PeeringType
                        "AzureASN"                                        = $_.AzureASN
                        "PeerASN"                                         = $_.PeerASN
                        "PrimaryPeerAddressPrefix"                        = $_.PrimaryPeerAddressPrefix
                        "SecondaryPeerAddressPrefix"                      = $_.SecondaryPeerAddressPrefix
                        "PrimaryAzurePort"                                = $_.PrimaryAzurePort
                        "SecondaryAzurePort"                              = $_.SecondaryAzurePort
                        "SharedKey"                                       = $_.SharedKey
                        "VlanId"                                          = $_.VlanId
                        "MicrosoftPeeringConfig.CustomerASN"              = $_.MicrosoftPeeringConfig.CustomerASN
                        "MicrosoftPeeringConfig.RoutingRegistryName"      = $_.MicrosoftPeeringConfig.RoutingRegistryName
                        "MicrosoftPeeringConfig.AdvertisedCommunities"    = $_.MicrosoftPeeringConfig.AdvertisedCommunities
                        "MicrosoftPeeringConfig.AdvertisedPublicPrefixes" = $_.MicrosoftPeeringConfig.AdvertisedPublicPrefixes
                        "MicrosoftPeeringConfig.LegacyMode"               = $_.MicrosoftPeeringConfig.LegacyMode
                        "LastModifiedBy"                                  = $_.LastModifiedBy
                        "ARPTable.Primary"                                = $script:AzExpressRouteCircuitPeeringARPTablePrimaryDetailTable
                        "ARPTable.Secondary"                              = $script:AzExpressRouteCircuitPeeringARPTableSecondaryDetailTable
                        "RouteTable.Primary"                              = $script:AzExpressRouteCircuitPeeringRouteTablePrimaryDetailTable
                        "RouteTable.Secondary"                            = $script:AzExpressRouteCircuitPeeringRouteTableSecondaryDetailTable
                    }
                }
                $script:AzExpressRouteCircuitPeeringsDetailTable = New-HTMLTable -InputObject $script:AzExpressRouteCircuitPeeringsDetail
            }

            $script:AzExpressRouteCircuitAuthorizationDetail = @()
            $script:AzExpressRouteCircuitAuthorizationDetailTable = $null
            $_.Authorizations | foreach{
                $script:AzExpressRouteCircuitAuthorizationDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "AuthorizationKey"          = $_.AuthorizationKey
                    "AuthorizationUseStatus"    = $_.AuthorizationUseStatus
                    "Id"                        = $_.Id
                }
                $script:AzExpressRouteCircuitAuthorizationDetailTable = New-HTMLTable -InputObject $script:AzExpressRouteCircuitAuthorizationDetail
            }

            $script:AzExpressRouteCircuitDetail = [PSCustomObject]@{
                "Name"                              = $_.Name
                "ResourceGroupName"                 = $_.ResourceGroupName
                "ServiceKey"                        = $_.ServiceKey
                "Location"                          = $_.Location
                "ProvisioningState"                 = $_.ProvisioningState
                "CircuitProvisioningState"          = $_.CircuitProvisioningState
                "Id"                                = $_.Id
                "Sku"                               = $_.Sku.Name
                "ServiceProviderName"               = $_.ServiceProviderProperties.ServiceProviderName
                "ServiceProviderProvisioningState"  = $_.ServiceProviderProvisioningState
                "PeeringLocation"                   = $_.ServiceProviderProperties.PeeringLocation
                "BandwidthInMbps"                   = $_.ServiceProviderProperties.BandwidthInMbps
                "ServiceProviderNotes"              = $_.ServiceProviderNotes
                "AllowClassicOperations"            = $_.AllowClassicOperations
                "Stats"                             = New-HTMLTable -InputObject ($_ | Get-AzExpressRouteCircuitStats)
                "Authorization"                     = $script:AzExpressRouteCircuitAuthorizationDetailTable
                "Peerings"                          = ConvertTo-DetailView -InputObject $script:AzExpressRouteCircuitPeeringsDetailTable
            }
            $script:AzExpressRouteCircuitDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzExpressRouteCircuitDetail)

            $script:AzExpressRouteCircuitTable += [PSCustomObject]@{
                "Name"                              = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
                "ResourceGroupName"                 = $_.ResourceGroupName
                "ServiceKey"                        = $_.ServiceKey
                "Location"                          = $_.Location
                "ProvisioningState"                 = $_.ProvisioningState
                "CircuitProvisioningState"          = $_.CircuitProvisioningState
                "Sku"                               = $_.Sku.Name
                "ServiceProviderName"               = $_.ServiceProviderProperties.ServiceProviderName
                "PeeringLocation"                   = $_.ServiceProviderProperties.PeeringLocation
                "BandwidthInMbps"                   = $_.ServiceProviderProperties.BandwidthInMbps
                "AllowClassicOperations"            = $_.AllowClassicOperations
                "Detail"                            = ConvertTo-DetailView -InputObject $script:AzExpressRouteCircuitDetailTable
            }
        }
    }
    $script:Report += "<h3>ExpressRoute Circuit</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzExpressRouteCircuitTable))
}