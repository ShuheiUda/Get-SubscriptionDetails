function Save-AzRouteTableTable{
    $script:AzRouteTableTable= @()
    $script:AzRouteTable | foreach{
        $script:AzRouteTableRoutesDetail = @()
        if($_.Routes -ne $null){
            $_.Routes | foreach{
                $script:AzRouteTableRoutesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "AddressPrefix"             = $_.AddressPrefix
                    "NextHopType"               = $_.NextHopType
                    "NextHopIpAddress"          = $_.NextHopIpAddress
                }
            }
        $script:AzRouteTableRoutesDetailTable = New-HTMLTable -InputObject $script:AzRouteTableRoutesDetail
        }
        
        $script:AzRouteTableSubnetsId = @()
        if($_.Subnets.Id -ne $null){
            $_.Subnets.Id | foreach{
                $script:AzRouteTableSubnetsId += "<a href=`"#$(($_ -Replace `"/subnets/.*$`",`"`").ToLower())`">$_</a>"
            }
        }
        $script:AzRouteTableDetail = [PSCustomObject]@{
        "Name"                      = $_.Name
        "ResourceGroupName"         = $_.ResourceGroupName
        "Location"                  = $_.Location
        "Id"                        = $_.Id
        "ProvisioningState"         = $_.ProvisioningState
        "Routes"                    = ConvertTo-DetailView -InputObject $script:AzRouteTableRoutesDetailTable
        "Subnets"                   = $script:AzRouteTableSubnetsId -join "<br>"
        "ResourceNavigationLinks"   = $_.Subnets.ResourceNavigationLinks -join "<br>"
        "ServiceEndpoints"          = $_.Subnets.ServiceEndpoints -join "<br>"
        }
        $script:AzRouteTableDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzRouteTableDetail)

        $script:AzRouteTableTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzRouteTableDetailTable
        }
    }
    $script:Report += "<h3>Route Table</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzRouteTableTable))
}