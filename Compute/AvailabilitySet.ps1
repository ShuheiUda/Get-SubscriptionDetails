function Save-AzureRmAvailabilitySetTable{
    $script:AzureRmAvailabilitySetTable = @()
    $script:AzureRmAvailabilitySet | foreach{
        $script:AzureRmAvailabilitySetVirtualMachineReferences = @()
        
        if ( $_.VirtualMachinesReferences.id -ne $null ){
            $_.VirtualMachinesReferences.id | foreach{
                $script:AzureRmAvailabilitySetVirtualMachineReferences += "<a href=`"#$($_.ToLower())`">$_</a>"
            }
        }

        $script:AzureRmAvailabilitySetDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Statuses"                  = $_.Statuses
            "Id"                        = $_.Id
            "Type"                      = $_.Type
            "Managed"                   = $_.Managed
            "Sku"                       = $_.Sku
            "FaultDomainCount"          = $_.PlatformFaultDomainCount
            "UpdateDomainCount"         = $_.PlatformUpdateDomainCount
            "VirtualMachineReferences"  = $script:AzureRmAvailabilitySetVirtualMachineReferences -join "<br>"
        }
        $script:AzureRmAvailabilitySetDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmAvailabilitySetDetail)
        $VirtualMachines = @()
        $_.VirtualMachinesReferences.Id | foreach{
            if($_ -match "/providers/Microsoft.Compute/virtualMachines/.{1,15}$"){
                $VirtualMachines += $Matches[0] -replace "/providers/Microsoft.Compute/virtualMachines/", ""
            }
        }
        $script:AzureRmAvailabilitySetTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Managed"                   = $_.Managed
            "Sku"                       = $_.Sku
            "FaultDomainCount"          = $_.PlatformFaultDomainCount
            "UpdateDomainCount"         = $_.PlatformUpdateDomainCount
            "VirtualMachineReferences"  = $VirtualMachines -join ", "
            "Detail"                    = $script:AzureRmAvailabilitySetDetailTable
        }
    }
    $script:Report += "<h3>Availability Sets</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmAvailabilitySetTable)
}