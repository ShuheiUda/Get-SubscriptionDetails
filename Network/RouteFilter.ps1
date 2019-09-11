function Save-AzRouteFilter{
    $script:AzRouteFilterTable = @()
    $script:AzRouteFilter | foreach{
        if($_.Rules -ne $null){
            $script:AzRouteFilterRulesDetail = @()
            $script:AzRouteFilterRulesDetailTable = $null
            $_.Rules | foreach{
                $script:AzRouteFilterRulesDetail += [PSCustomObject]@{
                    "Name"              = $_.Name
                    "Access"            = $_.Access
                    "Communities"       = $_.Communities -join "<br>"
                }
            }
            $script:AzRouteFilterRulesDetailTable = New-HTMLTable -InputObject $script:AzRouteFilterRulesDetail
        }

        $script:AzRouteFilterDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "Rules"                     = $script:AzRouteFilterRulesDetailTable
            "Peerings.AzureASN"         = $_.Peerings.AzureASN -join "<br>"
            "Peerings.Id"               = $_.Peerings.Id -join "<br>"
        }
        $script:AzRouteFilterDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzRouteFilterDetail)

        $script:AzRouteFilterTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzRouteFilterDetailTable
        }
    }
    $script:Report += "<h3>Route Filter</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzRouteFilterTable))
}