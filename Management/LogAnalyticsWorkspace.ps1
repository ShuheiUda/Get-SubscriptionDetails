function Save-AzLogAnalytics {
    $script:AzLogAnalyticsWorkspaceTable = @()
    if($script:AzLogAnalyticsWorkspace -ne $null){
        $script:AzLogAnalyticsWorkspace | foreach{

            $script:AzLogAnalyticsWorkspaceTableDetailTable = $null

            $script:AzLogAnalyticsWorkspaceTableDetail = [PSCustomObject]@{
                "Name"                          = $_.Name
                "Id"                            = $_.ResourceId
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "Sku"                           = $_.Sku
                "retentionInDays"               = $_.retentionInDays
                "customerId"                    = $_.CustomerId
                "PortalUrl"                     = $_.PortalUrl
                "ProvisioningState"             = $_.ProvisioningState
            }
            $script:AzLogAnalyticsWorkspaceTableDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzLogAnalyticsWorkspaceTableDetail) 
            
            $script:AzLogAnalyticsWorkspaceTable += [PSCustomObject]@{
                "Name"                          = "<a name=`"$($_.ResourceId.ToLower())`">$($_.Name)</a>"
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "ProvisioningState"             = $_.provisioningState
                "Detail"                        = ConvertTo-DetailView -InputObject $script:AzLogAnalyticsWorkspaceTableDetailTable
            }
        }
    }

    $script:Report += "<h3>Log Analytics workspaces</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzLogAnalyticsWorkspaceTable))
}