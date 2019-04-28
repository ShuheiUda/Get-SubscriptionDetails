
function Save-AzureRmExpressRouteCircuitTable{
    $script:AzureRmExpressRouteCircuitTable = @()
    if($script:AzureRmExpressRouteCircuit -ne $null){
        $script:AzureRmExpressRouteCircuit | foreach{
            $AzureRmExpressRouteCircuitName = $_.Name
            $AzureRmExpressRouteCircuitResourceGroupName = $_.ResourceGroupName
            $script:AzureRmExpressRouteCircuitPeeringsDetail = @()
            if($_.peerings -ne $null){
                $_.Peerings | foreach{
                    $script:AzureRmExpressRouteCircuitPeeringARPTablePrimaryDetail = @()
                    $script:AzureRmExpressRouteCircuitPeeringARPTableSecondaryDetail = @()
                    $script:AzureRmExpressRouteCircuitPeeringARPTablePrimaryDetailTable = $null
                    $script:AzureRmExpressRouteCircuitPeeringARPTableSecondaryDetailTable = $null
                    $script:AzureRmExpressRouteCircuitPeeringARPTablePrimary = Get-AzureRmExpressRouteCircuitARPTable -ExpressRouteCircuitName $AzureRmExpressRouteCircuitName -ResourceGroupName $AzureRmExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Primary
                    $script:AzureRmExpressRouteCircuitPeeringARPTableSecondary = Get-AzureRmExpressRouteCircuitARPTable -ExpressRouteCircuitName $AzureRmExpressRouteCircuitName -ResourceGroupName $AzureRmExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Secondary

                    $script:AzureRmExpressRouteCircuitPeeringARPTablePrimary | foreach{
                        $script:AzureRmExpressRouteCircuitPeeringARPTablePrimaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Primary"
                            "Age"                           = $_.Age
                            "InterfaceProperty"             = $_.InterfaceProperty
                            "IpAddress"                     = $_.IpAddress
                            "MacAddress"                    = $_.MacAddress
                        }
                    }
                    $script:AzureRmExpressRouteCircuitPeeringARPTablePrimaryDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitPeeringARPTablePrimaryDetail

                    $script:AzureRmExpressRouteCircuitPeeringARPTableSecondary | foreach{
                        $script:AzureRmExpressRouteCircuitPeeringARPTableSecondaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Secondary"
                            "Age"                           = $_.Age
                            "InterfaceProperty"             = $_.InterfaceProperty
                            "IpAddress"                     = $_.IpAddress
                            "MacAddress"                    = $_.MacAddress
                        }
                    }
                    $script:AzureRmExpressRouteCircuitPeeringARPTableSecondaryDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitPeeringARPTableSecondaryDetail

                    $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimaryDetail = @()
                    $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondaryDetail = @()
                    $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimaryDetailTable = $null
                    $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondaryDetailTable = $null
                    $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimary = Get-AzureRmExpressRouteCircuitRouteTable -ExpressRouteCircuitName $AzureRmExpressRouteCircuitName -ResourceGroupName $AzureRmExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Primary
                    $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondary = Get-AzureRmExpressRouteCircuitRouteTable -ExpressRouteCircuitName $AzureRmExpressRouteCircuitName -ResourceGroupName $AzureRmExpressRouteCircuitResourceGroupName -PeeringType $_.PeeringType -DevicePath Secondary

                    $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimary | foreach{
                        $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Primary"
                            "Network"                       = $_.Network
                            "NextHop"                       = $_.NextHop
                            "Path"                          = $_.Path
                            "LocPrf"                        = $_.LocPrf
                            "Weight"                        = $_.Weight
                        }
                    }
                    $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimaryDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimaryDetail

                    $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondary | foreach{
                        $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondaryDetail += [PSCustomObject]@{
                            "DevicePath"                    = "Secondary"
                            "Network"                       = $_.Network
                            "NextHop"                       = $_.NextHop
                            "Path"                          = $_.Path
                            "LocPrf"                        = $_.LocPrf
                            "Weight"                        = $_.Weight
                        }
                    }
                    $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondaryDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondaryDetail

                    $script:AzureRmExpressRouteCircuitPeeringsDetail += [PSCustomObject]@{
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
                        "ARPTable.Primary"                                = $script:AzureRmExpressRouteCircuitPeeringARPTablePrimaryDetailTable
                        "ARPTable.Secondary"                              = $script:AzureRmExpressRouteCircuitPeeringARPTableSecondaryDetailTable
                        "RouteTable.Primary"                              = $script:AzureRmExpressRouteCircuitPeeringRouteTablePrimaryDetailTable
                        "RouteTable.Secondary"                            = $script:AzureRmExpressRouteCircuitPeeringRouteTableSecondaryDetailTable
                    }
                }
                $script:AzureRmExpressRouteCircuitPeeringsDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitPeeringsDetail
            }

            $script:AzureRmExpressRouteCircuitAuthorizationDetail = @()
            $script:AzureRmExpressRouteCircuitAuthorizationDetailTable = $null
            $_.Authorizations | foreach{
                $script:AzureRmExpressRouteCircuitAuthorizationDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "AuthorizationKey"          = $_.AuthorizationKey
                    "AuthorizationUseStatus"    = $_.AuthorizationUseStatus
                    "Id"                        = $_.Id
                }
                $script:AzureRmExpressRouteCircuitAuthorizationDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitAuthorizationDetail
            }

            $script:AzureRmExpressRouteCircuitDetail = [PSCustomObject]@{
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
                "Stats"                             = New-HTMLTable -InputObject ($_ | Get-AzureRmExpressRouteCircuitStats)
                "Authorization"                     = $script:AzureRmExpressRouteCircuitAuthorizationDetailTable
                "Peerings"                          = ConvertTo-DetailView -InputObject $script:AzureRmExpressRouteCircuitPeeringsDetailTable
            }
            $script:AzureRmExpressRouteCircuitDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmExpressRouteCircuitDetail)

            $script:AzureRmExpressRouteCircuitTable += [PSCustomObject]@{
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
                "Detail"                            = ConvertTo-DetailView -InputObject $script:AzureRmExpressRouteCircuitDetailTable
            }
        }
    }
    $script:Report += "<h3>ExpressRoute Circuit</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmExpressRouteCircuitTable))
}