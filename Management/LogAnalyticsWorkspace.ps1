function Save-AzureRmLogAnalytics {
    $script:AzureRmLogAnalyticsWorkspaceTable = @()
    if($script:AzureRmLogAnalyticsWorkspace -ne $null){
        $script:AzureRmLogAnalyticsWorkspace | foreach{

            $script:AzureRmLogAnalyticsWorkspaceTableDetailTable = $null

            $script:AzureRmLogAnalyticsWorkspaceFeaturesDetailTable = $null
            if($_.Properties.features -ne $null){
                $script:AzureRmLogAnalyticsWorkspaceFeaturesDetailTable = New-HTMLTable -InputObject $_.Properties.features
            }

            $script:AzureRmLogAnalyticsWorkspaceWorkspaceCappingDetailTable = $null
            if($_.Properties.workspaceCapping -ne $null){
                $script:AzureRmLogAnalyticsWorkspaceWorkspaceCappingDetailTable = New-HTMLTable -InputObject $_.Properties.workspaceCapping
            }   

            $script:AzureRmLogAnalyticsWorkspaceTableDetail = [PSCustomObject]@{
                "Name"                          = $_.Name
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "Id"                            = $_.ResourceId
                "ProvisioningState"             = $_.Properties.ProvisioningState
                "source"                        = $_.Properties.source
                "customerId"                    = $_.Properties.customerId
                "sku"                           = $_.Properties.sku.name
                "retentionInDays"               = $_.Properties.retentionInDays
                "features"                      = $script:AzureRmLogAnalyticsWorkspaceFeaturesDetailTable
                "workspaceCapping"              = $script:AzureRmLogAnalyticsWorkspaceWorkspaceCappingDetailTable
            }
            $script:AzureRmLogAnalyticsWorkspaceTableDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmLogAnalyticsWorkspaceTableDetail) 
            
            $script:AzureRmLogAnalyticsWorkspaceTable += [PSCustomObject]@{
                "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
                "ResourceGroupName"             = $_.ResourceGroupName
                "Location"                      = $_.Location
                "ProvisioningState"             = $_.Properties.provisioningState
                "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmLogAnalyticsWorkspaceTableDetailTable
            }
        }
    }

    $script:Report += "<h3>Log Analytics workspaces</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmLogAnalyticsWorkspaceTable))
}