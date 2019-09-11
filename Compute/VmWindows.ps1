
function Save-AzVmWindowsTable{
    $script:AzVmWindowsTable = @()
    $AzVmWindows = $Script:AzVm | where{$_.StorageProfile.OsDisk.OsType -eq "Windows"}
    $AzVmWindows | foreach{
        $ResourceGroupName = $_.ResourceGroupName
        $AvailabilitySet = ($_.AvailabilitySetReference.Id -replace "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/availabilitySets/", "")
        
        $script:AzVmWindowsNetworkInterfaceIDsDetail = @()
        if($_.NetworkProfile.NetworkInterfaces -ne $null){
            $_.NetworkProfile.NetworkInterfaces | foreach{
                $script:AzVmWindowsNetworkInterfaceIDsDetail += [PSCustomObject]@{
                    "Primary"   = $_.Primary
                    "Id"        = "<a href=`"#$($_.Id.ToLower())`">$($_.Id)</a>"
                }
            }
        $script:AzVmWindowsNetworkInterfaceIDsDetailTable = New-HTMLTable -InputObject $script:AzVmWindowsNetworkInterfaceIDsDetail
        }

        if($_.StorageProfile.ImageReference -ne $null){
            $script:AzVmWindowsImageReferenceDetailTable = New-HTMLTable -InputObject $_.StorageProfile.ImageReference
        }
        if($_.StorageProfile.OsDisk -ne $null){
            $script:AzVmWindowsOsDisksManagedDiskId = $null
            if($_.StorageProfile.OsDisk.ManagedDisk.Id -ne $null){
                $script:AzVmWindowsOsDisksManagedDiskId = "<a href=`"#$(($_.StorageProfile.OsDisk.ManagedDisk.Id).ToLower())`">$($_.StorageProfile.OsDisk.ManagedDisk.Id)</a>"
            }
            $script:AzVmWindowsOsDiskDetail = [PSCustomObject]@{
                "Name"                              = $_.StorageProfile.OsDisk.Name
                "OsType"                            = $_.StorageProfile.OsDisk.OsType
                "EncryptionSettings"                = $_.StorageProfile.OsDisk.EncryptionSettings
                "Image"                             = $_.StorageProfile.OsDisk.Image
                "Caching"                           = $_.StorageProfile.OsDisk.Caching
                "CreateOption"                      = $_.StorageProfile.OsDisk.CreateOption
                "DiskSizeGB"                        = $_.StorageProfile.OsDisk.DiskSizeGB
                "ManagedDisk.StorageAccountType"    = $_.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
                "ManagedDisk.Id"                    = $script:AzVmWindowsOsDisksManagedDiskId
                "Vhd"                               = $_.StorageProfile.OsDisk.Vhd.Uri
            }
            $script:AzVmWindowsOsDiskDetailTable = New-HTMLTable -InputObject $script:AzVmWindowsOsDiskDetail
        }
        if($_.StorageProfile.DataDisks -ne $null){
            $script:AzVmWindowsDataDisksDetail = @()
            $_.StorageProfile.DataDisks | foreach{
                $script:AzVmWindowsDataDisksManagedDiskId = $null
                if($_.ManagedDisk.Id -ne $null){
                    $script:AzVmWindowsDataDisksManagedDiskId = "<a href=`"#$(($_.ManagedDisk.Id).ToLower())`">$($_.ManagedDisk.Id)</a>"
                }
                $script:AzVmWindowsDataDisksDetail += [PSCustomObject]@{
                    "Lun"                               = $_.Lun
                    "Name"                              = $_.Name
                    "Image"                             = $_.Image
                    "Caching"                           = $_.Caching
                    "CreateOption"                      = $_.CreateOption
                    "DiskSizeGB"                        = $_.DiskSizeGB
                    "ManagedDisk.StorageAccountType"    = $_.ManagedDisk.StorageAccountType
                    "ManagedDisk.Id"                    = $script:AzVmWindowsDataDisksManagedDiskId
                    "Vhd"                               = $_.Vhd.Uri
                }
            }
            $script:AzVmWindowsDataDisksDetailTable = New-HTMLTable -InputObject $script:AzVmWindowsDataDisksDetail
        }


        if($_.Plan -ne $null){
            $script:AzVmWindowsPlanDetailTable = New-HTMLTable -InputObject $_.Plan
        }
        
        if($_.NetworkProfile.NetworkInterfaces[0].Id -match "/providers/Microsoft.Network/networkInterfaces/.{1,80}$"){
            $NetworkInterface = $Matches[0] -replace "/providers/Microsoft.Network/networkInterfaces/", ""
            $script:AzNetworkInterface | foreach{
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
                                $script:AzPublicIpAddress | foreach{
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
        
        $script:AzVmWindowsAvailabilitySetReference = $null
        if($_.AvailabilitySetReference.Id -ne $null){
            $script:AzVmWindowsAvailabilitySetReference = "<a href=`"#$(($_.AvailabilitySetReference.Id).ToLower())`">$($_.AvailabilitySetReference.Id)</a>"
        }

        $script:AzVmWindowsVmExtensionsDetail = @()
        $script:AzVmWindowsVmExtensionsDetailTable = @()
        $script:VmExtensions = Get-AzVMExtension -ResourceGroupName $_.ResourceGroupName -VMName $_.Name
        if ( $script:VmExtensions -ne $null ){
            $script:VmExtensions | ForEach-Object {
                $script:AzVmWindowsVmExtensionsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "Location"                  = $_.Location
                    "Publisher"                 = $_.Publisher
                    "ExtensionType"             = $_.ExtensionType
                    "TypeHandlerVersion"        = $_.TypeHandlerVersion
                    #"Id"                        = $_.Id
                    "PublicSettings"            = $_.PublicSettings
                    "ProtectedSettings"         = $_.ProtectedSettings
                    "ProvisioningState"         = $_.ProvisioningState
                    "Statuses"                  = $_.Statuses
                    "SubStatuses"               = $_.SubStatuses
                    "AutoUpgradeMinorVersion"   = $_.AutoUpgradeMinorVersion
                    "ForceUpdateTag"            = $_.ForceUpdateTag
                }
            }
        }
        $script:AzVmWindowsVmExtensionsDetailTable = New-HTMLTable -InputObject $script:AzVmWindowsVmExtensionsDetail

        $script:AzVmWindowsDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "VmId"                          = $_.VmId
            "Type"                          = $_.Type
            "AvailabilitySetReference"      = $script:AzVmWindowsAvailabilitySetReference
            "Zones"                         = $_.Zones
            "ProvisioningState"             = $_.ProvisioningState
            "StatusCode"                    = $_.StatusCode
            "VmSize"                        = $_.HardwareProfile.VmSize
            "LicenseType"                   = $_.LicenseType
            "Plan"                          = $script:AzVmWindowsPlanDetailTable
            "ComputerName"                  = $_.OSProfile.ComputerName
            "AdminUsername"                 = $_.OSProfile.AdminUsername
            "ProvisionVMAgent"              = $_.OSProfile.WindowsConfiguration.ProvisionVMAgent
            "ImageReference"                = $script:AzVmWindowsImageReferenceDetailTable
            "OsDisk"                        = $script:AzVmWindowsOsDiskDetailTable
            "DataDisks"                     = $script:AzVmWindowsDataDisksDetailTable
            "NetworkInterfaces"             = $script:AzVmWindowsNetworkInterfaceIDsDetailTable
            "BootDiagnostics.Enabled"       = $_.DiagnosticsProfile.BootDiagnostics.Enabled
            "BootDiagnostics.StorageUri"    = $_.DiagnosticsProfile.BootDiagnostics.StorageUri
            "VM Extension"                  = $script:AzVmWindowsVmExtensionsDetailTable
        }
        $script:AzVmWindowsDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzVmWindowsDetail) 

        $script:AzVmWindowsTable += [PSCustomObject]@{
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
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzVmWindowsDetailTable
        }
    }
    $script:Report += "<h3>Windows VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzVmWindowsTable))
}