function Save-AzResourceProviderTable{
    $script:AzResourceProviderTable = @()
    $script:AzResourceProvider | foreach{
        $script:AzResourceProviderDetail = [PSCustomObject]@{
            "ProviderNamespace"           = $_.ProviderNamespace
            "RegistrationState"           = $_.RegistrationState
            "ResourceTypes"               = $_.ResourceTypes.ResourceTypeName -join "<br>"
            "Locations"                   = $_.Locations -join "<br>"
        }
        $script:AzResourceProviderDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzResourceProviderDetail)

        $script:AzResourceProviderTable += [PSCustomObject]@{
            "ProviderNamespace"           = $_.ProviderNamespace
            "RegistrationState"           = $_.RegistrationState
            "Detail"                      = ConvertTo-DetailView -InputObject $script:AzResourceProviderDetailTable
        }
    }
    $script:Report += "<h3>Resource Provider</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-RegistrationStateColor(New-ResourceHTMLTable -InputObject $script:AzResourceProviderTable))
}
