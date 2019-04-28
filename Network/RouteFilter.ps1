function Save-AzureRmRouteFilter{
    $script:AzureRmRouteFilterTable = @()
    $script:AzureRmRouteFilter | foreach{
        if($_.Rules -ne $null){
            $script:AzureRmRouteFilterRulesDetail = @()
            $script:AzureRmRouteFilterRulesDetailTable = $null
            $_.Rules | foreach{
                $script:AzureRmRouteFilterRulesDetail += [PSCustomObject]@{
                    "Name"              = $_.Name
                    "Access"            = $_.Access
                    "Communities"       = $_.Communities -join "<br>"
                }
            }
            $script:AzureRmRouteFilterRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmRouteFilterRulesDetail
        }

        $script:AzureRmRouteFilterDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "Rules"                     = $script:AzureRmRouteFilterRulesDetailTable
            "Peerings.AzureASN"         = $_.Peerings.AzureASN -join "<br>"
            "Peerings.Id"               = $_.Peerings.Id -join "<br>"
        }
        $script:AzureRmRouteFilterDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRouteFilterDetail)

        $script:AzureRmRouteFilterTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmRouteFilterDetailTable
        }
    }
    $script:Report += "<h3>Route Filter</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmRouteFilterTable))
}