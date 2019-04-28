function Save-AzureRmNetworkSecurityGroupTable{
    $script:AzureRmNetworkSecurityGroupTable = @()
    $script:AzureRmNetworkSecurityGroup | foreach{
        $script:AzureRmNetworkSecurityGroupSecurityRulesDetail = @()
        $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetail = @()
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
            $_.SecurityRules | foreach{
                $script:AzureRmNetworkSecurityGroupSecurityRulesDetail += [PSCustomObject]@{
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
        $script:AzureRmNetworkSecurityGroupSecurityRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmNetworkSecurityGroupSecurityRulesDetail
        }
        
        if($_.DefaultSecurityRules -ne $null){
            $_.DefaultSecurityRules | foreach{
                $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetail += [PSCustomObject]@{
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
        $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetail
        }
        
        $script:AzureRmNetworkSecurityGroupNetworkInterfacesId = @()
        if($_.NetworkInterfaces.Id -ne $null){
            $_.NetworkInterfaces.Id | foreach{
                $script:AzureRmNetworkSecurityGroupNetworkInterfacesId += "<a href=`"#$($_.ToLower())`">$_</a>"
            }
        }
        $script:AzureRmNetworkSecurityGroupSubnetsId = @()
        if($_.Subnets.Id -ne $null){
            $_.Subnets.Id | foreach{
                $script:AzureRmNetworkSecurityGroupSubnetsId += "<a href=`"#$(($_ -Replace `"/subnets/.*$`",`"`").ToLower())`">$_</a>"
            }
        }
        $script:AzureRmNetworkSecurityGroupDetail = [PSCustomObject]@{
        "Name"                      = $_.Name
        "ResourceGroupName"         = $_.ResourceGroupName
        "Location"                  = $_.Location
        "Id"                        = $_.Id
        "ResourceGuid"              = $_.ResourceGuid
        "ProvisioningState"         = $_.ProvisioningState
        "NetworkInterfaces"         = $script:AzureRmNetworkSecurityGroupNetworkInterfacesId -join "<br>"
        "Subnets"                   = $script:AzureRmNetworkSecurityGroupSubnetsId -join "<br>"
        "SecurityRules"             = ConvertTo-DetailView -InputObject $script:AzureRmNetworkSecurityGroupSecurityRulesDetailTable
        "DefaultSecurityRules"      = ConvertTo-DetailView -InputObject $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetailTable
        }
        $script:AzureRmNetworkSecurityGroupDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmNetworkSecurityGroupDetail)

        $script:AzureRmNetworkSecurityGroupTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "NetworkInterfaces"         = $NetworkInterfaces -join ", "
            "Subnets"                   = $Subnets -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmNetworkSecurityGroupDetailTable
        }
    }
    $script:Report += "<h3>Network Security Group</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmNetworkSecurityGroupTable))
}