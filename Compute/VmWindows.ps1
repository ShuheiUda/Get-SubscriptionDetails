
function Save-AzureRmVmWindowsTable{
    $script:AzureRmVmWindowsTable = @()
    $AzureRmVmWindows = $Script:AzureRmVm | where{$_.StorageProfile.OsDisk.OsType -eq "Windows"}
    $AzureRmVmWindows | foreach{
        $ResourceGroupName = $_.ResourceGroupName
        $AvailabilitySet = ($_.AvailabilitySetReference.Id -replace "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/availabilitySets/", "")
        
        $script:AzureRmVmWindowsNetworkInterfaceIDsDetail = @()
        if($_.NetworkProfile.NetworkInterfaces -ne $null){
            $_.NetworkProfile.NetworkInterfaces | foreach{
                $script:AzureRmVmWindowsNetworkInterfaceIDsDetail += [PSCustomObject]@{
                    "Primary"   = $_.Primary
                    "Id"        = "<a href=`"#$($_.Id.ToLower())`">$($_.Id)</a>"
                }
            }
        $script:AzureRmVmWindowsNetworkInterfaceIDsDetailTable = New-HTMLTable -InputObject $script:AzureRmVmWindowsNetworkInterfaceIDsDetail
        }

        if($_.StorageProfile.ImageReference -ne $null){
            $script:AzureRmVmWindowsImageReferenceDetailTable = New-HTMLTable -InputObject $_.StorageProfile.ImageReference
        }
        if($_.StorageProfile.OsDisk -ne $null){
            $script:AzureRmVmWindowsOsDisksManagedDiskId = $null
            if($_.StorageProfile.OsDisk.ManagedDisk.Id -ne $null){
                $script:AzureRmVmWindowsOsDisksManagedDiskId = "<a href=`"#$(($_.StorageProfile.OsDisk.ManagedDisk.Id).ToLower())`">$($_.StorageProfile.OsDisk.ManagedDisk.Id)</a>"
            }
            $script:AzureRmVmWindowsOsDiskDetail = [PSCustomObject]@{
                "Name"                              = $_.StorageProfile.OsDisk.Name
                "OsType"                            = $_.StorageProfile.OsDisk.OsType
                "EncryptionSettings"                = $_.StorageProfile.OsDisk.EncryptionSettings
                "Image"                             = $_.StorageProfile.OsDisk.Image
                "Caching"                           = $_.StorageProfile.OsDisk.Caching
                "CreateOption"                      = $_.StorageProfile.OsDisk.CreateOption
                "DiskSizeGB"                        = $_.StorageProfile.OsDisk.DiskSizeGB
                "ManagedDisk.StorageAccountType"    = $_.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
                "ManagedDisk.Id"                    = $script:AzureRmVmWindowsOsDisksManagedDiskId
                "Vhd"                               = $_.StorageProfile.OsDisk.Vhd.Uri
            }
            $script:AzureRmVmWindowsOsDiskDetailTable = New-HTMLTable -InputObject $script:AzureRmVmWindowsOsDiskDetail
        }
        if($_.StorageProfile.DataDisks -ne $null){
            $script:AzureRmVmWindowsDataDisksDetail = @()
            $_.StorageProfile.DataDisks | foreach{
                $script:AzureRmVmWindowsDataDisksManagedDiskId = $null
                if($_.ManagedDisk.Id -ne $null){
                    $script:AzureRmVmWindowsDataDisksManagedDiskId = "<a href=`"#$(($_.ManagedDisk.Id).ToLower())`">$($_.ManagedDisk.Id)</a>"
                }
                $script:AzureRmVmWindowsDataDisksDetail += [PSCustomObject]@{
                    "Lun"                               = $_.Lun
                    "Name"                              = $_.Name
                    "Image"                             = $_.Image
                    "Caching"                           = $_.Caching
                    "CreateOption"                      = $_.CreateOption
                    "DiskSizeGB"                        = $_.DiskSizeGB
                    "ManagedDisk.StorageAccountType"    = $_.ManagedDisk.StorageAccountType
                    "ManagedDisk.Id"                    = $script:AzureRmVmWindowsDataDisksManagedDiskId
                    "Vhd"                               = $_.Vhd.Uri
                }
            }
            $script:AzureRmVmWindowsDataDisksDetailTable = New-HTMLTable -InputObject $script:AzureRmVmWindowsDataDisksDetail
        }


        if($_.Plan -ne $null){
            $script:AzureRmVmWindowsPlanDetailTable = New-HTMLTable -InputObject $_.Plan
        }
        
        if($_.NetworkProfile.NetworkInterfaces[0].Id -match "/providers/Microsoft.Network/networkInterfaces/.{1,80}$"){
            $NetworkInterface = $Matches[0] -replace "/providers/Microsoft.Network/networkInterfaces/", ""
            $script:AzureRmNetworkInterface | foreach{
                if($_.Name -eq $NetworkInterface){
                    $VirtualMachine = $null
                    $PrivateIpAddress = @()
                    $PublicIPAddress = @()
                    $PublicIpAddressName = $null
                    $NetworkSecurityGroup = $null
                    $TempSubnetId = $null
                    $VirtualNetwork = $null
                    $Subnet = @()

                    $PrivateIpAddress = $_.IpConfigurations.PrivateIpAddress
                    if($_.IpConfigurations.PublicIpAddress.Id -ne $null){
                        $_.IpConfigurations.PublicIpAddress.Id | foreach{
                            if($_ -match "/providers/Microsoft.Network/publicIPAddresses/.{1,80}$"){
                                $PublicIpAddressName = $Matches[0] -replace "/providers/Microsoft.Network/publicIPAddresses/", ""
                                $script:AzureRmPublicIpAddress | foreach{
                                    if($_.Name -eq $PublicIpAddressName){
                                        $PublicIpAddress += $_.IpAddress
                                    }
                                }
                            }
                        }
                    }
                    if($_.NetworkSecurityGroup.Id -ne $null){
                        $_.NetworkSecurityGroup.Id | foreach{
                            if($_ -match "/providers/Microsoft.Network/networkSecurityGroups/[a-zA-Z0-9_.-]{1,80}$"){
                                $NetworkSecurityGroup += $Matches[0] -replace "/providers/Microsoft.Network/networkSecurityGroups/", ""
                            }
                        }
                    }
                    if($_.IpConfigurations.Subnet.Id -ne $null){
                        $_.IpConfigurations.Subnet.Id | foreach{
                            if($_ -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
                                $TempSubnetId = $Matches[0] -split "/"
                                $VirtualNetwork = $TempSubnetId[4]
                                $Subnet += $TempSubnetId[6]
                            }
                        }
                    }
                }
            }
        }
        
        $script:AzureRmVmWindowsAvailabilitySetReference = $null
        if($_.AvailabilitySetReference.Id -ne $null){
            $script:AzureRmVmWindowsAvailabilitySetReference = "<a href=`"#$(($_.AvailabilitySetReference.Id).ToLower())`">$($_.AvailabilitySetReference.Id)</a>"
        }
        $script:AzureRmVmWindowsDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "VmId"                          = $_.VmId
            "Type"                          = $_.Type
            "AvailabilitySetReference"      = $script:AzureRmVmWindowsAvailabilitySetReference
            "Zones"                         = $_.Zones
            "ProvisioningState"             = $_.ProvisioningState
            "StatusCode"                    = $_.StatusCode
            "VmSize"                        = $_.HardwareProfile.VmSize
            "LicenseType"                   = $_.LicenseType
            "Plan"                          = $script:AzureRmVmWindowsPlanDetailTable
            "ComputerName"                  = $_.OSProfile.ComputerName
            "AdminUsername"                 = $_.OSProfile.AdminUsername
            "ProvisionVMAgent"              = $_.OSProfile.WindowsConfiguration.ProvisionVMAgent
            "ImageReference"                = $script:AzureRmVmWindowsImageReferenceDetailTable
            "OsDisk"                        = $script:AzureRmVmWindowsOsDiskDetailTable
            "DataDisks"                     = $script:AzureRmVmWindowsDataDisksDetailTable
            "NetworkInterfaces"             = $script:AzureRmVmWindowsNetworkInterfaceIDsDetailTable
            "BootDiagnostics.Enabled"       = $_.DiagnosticsProfile.BootDiagnostics.Enabled
            "BootDiagnostics.StorageUri"    = $_.DiagnosticsProfile.BootDiagnostics.StorageUri
        }
        $script:AzureRmVmWindowsDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVmWindowsDetail) 

        $script:AzureRmVmWindowsTable += [PSCustomObject]@{
            "Name"                          = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "ComputerName"                  = $_.OSProfile.ComputerName
            "ResourceGroupName"             = $ResourceGroupName
            "ProvisioningState"             = $_.ProvisioningState
            "VmSize    "                    = $_.HardwareProfile.VmSize
            "AvailabilitySetName"           = $AvailabilitySet
            "VirtualNetworkName"            = $VirtualNetwork
            "SubnetNames"                   = $Subnet -join "<br>"
            "PrivateIpAddress"              = $PrivateIpAddress -join "<br>"
            "PublicIPAddress"               = $PublicIpAddress -join "<br>"
            "NetworkSecurityGroup"          = $NetworkSecurityGroup
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmVmWindowsDetailTable
        }
    }
    $script:Report += "<h3>Windows VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmVmWindowsTable))
}