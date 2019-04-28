function Save-AzureRmRouteTableTable{
    $script:AzureRmRouteTableTable= @()
    $script:AzureRmRouteTable | foreach{
        $script:AzureRmRouteTableRoutesDetail = @()
        if($_.Routes -ne $null){
            $_.Routes | foreach{
                $script:AzureRmRouteTableRoutesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "AddressPrefix"             = $_.AddressPrefix
                    "NextHopType"               = $_.NextHopType
                    "NextHopIpAddress"          = $_.NextHopIpAddress
                }
            }
        $script:AzureRmRouteTableRoutesDetailTable = New-HTMLTable -InputObject $script:AzureRmRouteTableRoutesDetail
        }
        
        $script:AzureRmRouteTableSubnetsId = @()
        if($_.Subnets.Id -ne $null){
            $_.Subnets.Id | foreach{
                $script:AzureRmRouteTableSubnetsId += "<a href=`"#$(($_ -Replace `"/subnets/.*$`",`"`").ToLower())`">$_</a>"
            }
        }
        $script:AzureRmRouteTableDetail = [PSCustomObject]@{
        "Name"                      = $_.Name
        "ResourceGroupName"         = $_.ResourceGroupName
        "Location"                  = $_.Location
        "Id"                        = $_.Id
        "ProvisioningState"         = $_.ProvisioningState
        "Routes"                    = ConvertTo-DetailView -InputObject $script:AzureRmRouteTableRoutesDetailTable
        "Subnets"                   = $script:AzureRmRouteTableSubnetsId -join "<br>"
        "ResourceNavigationLinks"   = $_.Subnets.ResourceNavigationLinks -join "<br>"
        "ServiceEndpoints"          = $_.Subnets.ServiceEndpoints -join "<br>"
        }
        $script:AzureRmRouteTableDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRouteTableDetail)

        $script:AzureRmRouteTableTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmRouteTableDetailTable
        }
    }
    $script:Report += "<h3>Route Table</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmRouteTableTable))
}