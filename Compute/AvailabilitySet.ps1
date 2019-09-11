function Save-AzAvailabilitySetTable{
    $script:AzAvailabilitySetTable = @()
    $script:AzAvailabilitySet | foreach{
        $script:AzAvailabilitySetVirtualMachineReferences = @()
        
        if ( $_.VirtualMachinesReferences.id -ne $null ){
            $_.VirtualMachinesReferences.id | foreach{
                $script:AzAvailabilitySetVirtualMachineReferences += "<a href=`"#$($_.ToLower())`">$_</a>"
            }
        }

        $script:AzAvailabilitySetDetail = [PSCustomObject]@{
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
            "VirtualMachineReferences"  = $script:AzAvailabilitySetVirtualMachineReferences -join "<br>"
        }
        $script:AzAvailabilitySetDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzAvailabilitySetDetail)
        $VirtualMachines = @()
        $_.VirtualMachinesReferences.Id | foreach{
            if($_ -match "/providers/Microsoft.Compute/virtualMachines/.{1,15}$"){
                $VirtualMachines += $Matches[0] -replace "/providers/Microsoft.Compute/virtualMachines/", ""
            }
        }
        $script:AzAvailabilitySetTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Managed"                   = $_.Managed
            "Sku"                       = $_.Sku
            "FaultDomainCount"          = $_.PlatformFaultDomainCount
            "UpdateDomainCount"         = $_.PlatformUpdateDomainCount
            "VirtualMachineReferences"  = $VirtualMachines -join ", "
            "Detail"                    = $script:AzAvailabilitySetDetailTable
        }
    }
    $script:Report += "<h3>Availability Sets</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzAvailabilitySetTable)
}