function Save-AzNetworkSecurityGroupTable{
    $script:AzNetworkSecurityGroupTable = @()
    $script:AzNetworkSecurityGroup | foreach{
        $script:AzNetworkSecurityGroupSecurityRulesDetail = @()
        $script:AzNetworkSecurityGroupDefaultSecurityRulesDetail = @()
        $NetworkInterfaces = @()
        $Subnets = @()
        $VirtualNetwork = $null
        $_.NetworkInterfaces | foreach{
            if($_.Id -match "/providers/Microsoft.Network/networkInterfaces/.{1,80}$"){
                $NetworkInterfaces += $Matches[0] -replace "/providers/Microsoft.Network/networkInterfaces/", ""
            }
        }
        $_.Subnets | foreach{
            if($_.Id -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
                $TempSubnetId = $Subnet = $Matches[0] -split "/"
                $VirtualNetwork = $TempSubnetId[4]
                $Subnet = $TempSubnetId[6]
                $Subnets += "$Subnet ($VirtualNetwork)"
            }
        }
        if($_.SecurityRules -ne $null){
            $_.SecurityRules | Sort-Object -Property Direction,Priority | foreach{
                $script:AzNetworkSecurityGroupSecurityRulesDetail += [PSCustomObject]@{
                    "Name"                                  = $_.Name
                    "ProvisioningState"                     = $_.ProvisioningState
                    "Access"                                = $_.Access
                    "Direction"                             = $_.Direction
                    "Priority"                              = $_.Priority
                    "Protocol"                              = $_.Protocol
                    "SourceAddressPrefix"                   = $_.SourceAddressPrefix -join ", "
                    "SourcePortRange"                       = $_.SourcePortRange -join ", "
                    "DestinationAddressPrefix"              = $_.DestinationAddressPrefix -join ", "
                    "DestinationPortRange"                  = $_.DestinationPortRange -join ", "
                    "SourceApplicationSecurityGroups"       = $_.SourceApplicationSecurityGroups -join ", "
                    "DestinationApplicationSecurityGroups"  = $_.DestinationApplicationSecurityGroups -join ", "
                }
            }
        $script:AzNetworkSecurityGroupSecurityRulesDetailTable = New-HTMLTable -InputObject $script:AzNetworkSecurityGroupSecurityRulesDetail
        }
        
        if($_.DefaultSecurityRules -ne $null){
            $_.DefaultSecurityRules | Sort-Object -Property Direction,Priority | foreach{
                $script:AzNetworkSecurityGroupDefaultSecurityRulesDetail += [PSCustomObject]@{
                    "Name"                                  = $_.Name
                    "ProvisioningState"                     = $_.ProvisioningState
                    "Access"                                = $_.Access
                    "Direction"                             = $_.Direction
                    "Priority"                              = $_.Priority
                    "Protocol"                              = $_.Protocol
                    "SourceAddressPrefix"                   = $_.SourceAddressPrefix -join ", "
                    "SourcePortRange"                       = $_.SourcePortRange -join ", "
                    "DestinationAddressPrefix"              = $_.DestinationAddressPrefix -join ", "
                    "DestinationPortRange"                  = $_.DestinationPortRange -join ", "
                    "SourceApplicationSecurityGroups"       = $_.SourceApplicationSecurityGroups -join ", "
                    "DestinationApplicationSecurityGroups"  = $_.DestinationApplicationSecurityGroups -join ", "
                }
            }
        $script:AzNetworkSecurityGroupDefaultSecurityRulesDetailTable = New-HTMLTable -InputObject $script:AzNetworkSecurityGroupDefaultSecurityRulesDetail
        }
        
        $script:AzNetworkSecurityGroupNetworkInterfacesId = @()
        if($_.NetworkInterfaces.Id -ne $null){
            $_.NetworkInterfaces.Id | foreach{
                $script:AzNetworkSecurityGroupNetworkInterfacesId += "<a href=`"#$($_.ToLower())`">$_</a>"
            }
        }
        $script:AzNetworkSecurityGroupSubnetsId = @()
        if($_.Subnets.Id -ne $null){
            $_.Subnets.Id | foreach{
                $script:AzNetworkSecurityGroupSubnetsId += "<a href=`"#$(($_ -Replace `"/subnets/.*$`",`"`").ToLower())`">$_</a>"
            }
        }
        $script:AzNetworkSecurityGroupDetail = [PSCustomObject]@{
        "Name"                      = $_.Name
        "ResourceGroupName"         = $_.ResourceGroupName
        "Location"                  = $_.Location
        "Id"                        = $_.Id
        "ResourceGuid"              = $_.ResourceGuid
        "ProvisioningState"         = $_.ProvisioningState
        "NetworkInterfaces"         = $script:AzNetworkSecurityGroupNetworkInterfacesId -join "<br>"
        "Subnets"                   = $script:AzNetworkSecurityGroupSubnetsId -join "<br>"
        "SecurityRules"             = ConvertTo-DetailView -InputObject $script:AzNetworkSecurityGroupSecurityRulesDetailTable
        "DefaultSecurityRules"      = ConvertTo-DetailView -InputObject $script:AzNetworkSecurityGroupDefaultSecurityRulesDetailTable
        }
        $script:AzNetworkSecurityGroupDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzNetworkSecurityGroupDetail)

        $script:AzNetworkSecurityGroupTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "NetworkInterfaces"         = $NetworkInterfaces -join ", "
            "Subnets"                   = $Subnets -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzNetworkSecurityGroupDetailTable
        }
    }
    $script:Report += "<h3>Network Security Group</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzNetworkSecurityGroupTable))
}