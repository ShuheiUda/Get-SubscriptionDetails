function Save-AzureRmLogAnalytics {
    $script:AzureRmLogAnalyticsWorkspaceTable = @()
    if($script:AzureRmLogAnalyticsWorkspace -ne $null){
        $script:AzureRmLogAnalyticsWorkspace | foreach{

            $script:AzureRmLogAnalyticsWorkspaceTableDetailTable = $null

            $script:AzureRmLogAnalyticsWorkspaceTableDetail = [PSCustomObject]@{
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
            $script:AzureRmLogAnalyticsWorkspaceTableDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmLogAnalyticsWorkspaceTableDetail) 
            
            $script:AzureRmLogAnalyticsWorkspaceTable += [PSCustomObject]@{
                "Name"                          = "<a name=`"$($_.ResourceId.ToLower())`">$($_.Name)</a>"
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "ProvisioningState"             = $_.provisioningState
                "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmLogAnalyticsWorkspaceTableDetailTable
            }
        }
    }

    $script:Report += "<h3>Log Analytics workspaces</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmLogAnalyticsWorkspaceTable))
}