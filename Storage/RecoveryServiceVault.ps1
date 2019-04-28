
function Save-AzureRmRecoveryServicesVault{
    $script:AzureRmRecoveryServicesVaultTable = @()
    $script:AzureRmRecoveryServicesVaultDetailTable = @()
    $script:AzureRmRecoveryServicesVault | foreach{

        $script:AzureRmRecoveryServicesVaultDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "Type"                          = $_.Type
            "ProvisioningState"             = $_.Properties.ProvisioningState
        }
        $script:AzureRmRecoveryServicesVaultDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRecoveryServicesVaultDetail) 

        $script:AzureRmRecoveryServicesVaultTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.Properties.ProvisioningState
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmRecoveryServicesVaultDetailTable
        }        
    }

    $script:Report += "<h3>Recovery Service Vault</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $Script:AzureRmRecoveryServicesVaultTable))
}