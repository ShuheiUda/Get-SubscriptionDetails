

function Save-AzureRmVmLinuxTable{
    $script:AzureRmVmLinuxTable = @()
    $AzureRmVmLinux = $Script:AzureRmVm | where{$_.StorageProfile.OsDisk.OsType -eq "Linux"}
    $AzureRmVmLinux | foreach{
        $ResourceGroupName = $_.ResourceGroupName
        $AvailabilitySet = ($_.AvailabilitySetReference.Id -replace "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/availabilitySets/", "")
        
        $script:AzureRmVmLinuxNetworkInterfaceIDsDetail = @()
        if($_.NetworkProfile.NetworkInterfaces -ne $null){
            $_.NetworkProfile.NetworkInterfaces | foreach{
                $script:AzureRmVmLinuxNetworkInterfaceIDsDetail += [PSCustomObject]@{
                    "Primary"   = $_.Primary
                    "Id"        = "<a href=#`"$($_.Id.ToLower())`">$($_.Id)</a>"
                }
            }
        $script:AzureRmVmLinuxNetworkInterfaceIDsDetailTable = New-HTMLTable -InputObject $script:AzureRmVmLinuxNetworkInterfaceIDsDetail
        }
        
        if($_.StorageProfile.ImageReference -ne $null){
            $script:AzureRmVmLinuxImageReferenceDetailTable = New-HTMLTable -InputObject $_.StorageProfile.ImageReference
        }
        if($_.StorageProfile.OsDisk -ne $null){
            $script:AzureRmVmLinuxOsDisksManagedDiskId = $null
            if($_.StorageProfile.OsDisk.ManagedDisk.Id -ne $null){
                $script:AzureRmVmLinuxOsDisksManagedDiskId = "<a href=`"#$(($_.StorageProfile.OsDisk.ManagedDisk.Id).ToLower())`">$($_.StorageProfile.OsDisk.ManagedDisk.Id)</a>"
            }
            $script:AzureRmVmLinuxOsDiskDetail = [PSCustomObject]@{
                "Name"                              = $_.StorageProfile.OsDisk.Name
                "OsType"                            = $_.StorageProfile.OsDisk.OsType
                "EncryptionSettings"                = $_.StorageProfile.OsDisk.EncryptionSettings
                "Image"                             = $_.StorageProfile.OsDisk.Image
                "Caching"                           = $_.StorageProfile.OsDisk.Caching
                "CreateOption"                      = $_.StorageProfile.OsDisk.CreateOption
                "DiskSizeGB"                        = $_.StorageProfile.OsDisk.DiskSizeGB
                "ManagedDisk.StorageAccountType"    = $_.StorageProfile.OsDisk.ManagedDisk.StorageAccountType
                "ManagedDisk.Id"                    = $script:AzureRmVmLinuxOsDisksManagedDiskId
                "Vhd"                               = $_.StorageProfile.OsDisk.Vhd.Uri
            }
            $script:AzureRmVmLinuxOsDiskDetailTable = New-HTMLTable -InputObject $script:AzureRmVmLinuxOsDiskDetail
        }
        if($_.StorageProfile.DataDisks -ne $null){
            $script:AzureRmVmLinuxDataDisksDetail = @()
            $_.StorageProfile.DataDisks | foreach{
                $script:AzureRmVmLinuxDataDisksManagedDiskId = $null
                if($_.ManagedDisk.Id -ne $null){
                    $script:AzureRmVmLinuxDataDisksManagedDiskId = "<a href=`"#$(($_.ManagedDisk.Id).ToLower())`">$($_.ManagedDisk.Id)</a>"
                }
                $script:AzureRmVmLinuxDataDisksDetail += [PSCustomObject]@{
                    "Lun"                               = $_.Lun
                    "Name"                              = $_.Name
                    "Image"                             = $_.Image
                    "Caching"                           = $_.Caching
                    "CreateOption"                      = $_.CreateOption
                    "DiskSizeGB"                        = $_.DiskSizeGB
                    "ManagedDisk.StorageAccountType"    = $_.ManagedDisk.StorageAccountType
                    "ManagedDisk.Id"                    = $script:AzureRmVmLinuxDataDisksManagedDiskId
                    "Vhd"                               = $_.Vhd.Uri
                }
            }
            $script:AzureRmVmLinuxDataDisksDetailTable = New-HTMLTable -InputObject $script:AzureRmVmLinuxDataDisksDetail
        }

        if($_.Plan -ne $null){
            $script:AzureRmVmLinuxPlanDetailTable = New-HTMLTable -InputObject $_.Plan
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
        
        $script:AzureRmVmLinuxAvailabilitySetReference = $null
        if($_.AvailabilitySetReference.Id -ne $null){
            $script:AzureRmVmLinuxAvailabilitySetReference = "<a href=`"#$(($_.AvailabilitySetReference.Id).ToLower())`">$($_.AvailabilitySetReference.Id)</a>"
        }

        $script:AzureRmVmLinuxVmExtensionsDetail = @()
        $script:AzureRmVmLinuxVmExtensionsDetailTable = @()
        $script:VmExtensions = Get-AzureRmVMExtension -ResourceGroupName $_.ResourceGroupName -VMName $_.Name
        if ( $script:VmExtensions -ne $null ){
            $script:VmExtensions | ForEach-Object {
                $script:AzureRmVmLinuxVmExtensionsDetail += [PSCustomObject]@{
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
        $script:AzureRmVmLinuxVmExtensionsDetailTable = New-HTMLTable -InputObject $script:AzureRmVmLinuxVmExtensionsDetail

        $script:AzureRmVmLinuxDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "VmId"                          = $_.VmId
            "Type"                          = $_.Type
            "AvailabilitySetReference"      = $script:AzureRmVmLinuxAvailabilitySetReference
            "Zones"                         = $_.Zones
            "ProvisioningState"             = $_.ProvisioningState
            "StatusCode"                    = $_.StatusCode
            "VmSize"                        = $_.HardwareProfile.VmSize
            "LicenseType"                   = $_.LicenseType
            "Plan"                          = $script:AzureRmVmLinuxPlanDetailTable
            "ComputerName"                  = $_.OSProfile.ComputerName
            "AdminUsername"                 = $_.OSProfile.AdminUsername
            "DisablePasswordAuthentication" = $_.OSProfile.LinuxConfiguration.DisablePasswordAuthentication
            "ImageReference"                = $script:AzureRmVmLinuxImageReferenceDetailTable
            "OsDisk"                        = $script:AzureRmVmLinuxOsDiskDetailTable
            "DataDisks"                     = $script:AzureRmVmLinuxDataDisksDetailTable
            "NetworkInterfaces"             = $script:AzureRmVmLinuxNetworkInterfaceIDsDetailTable
            "BootDiagnostics.Enabled"       = $_.DiagnosticsProfile.BootDiagnostics.Enabled
            "BootDiagnostics.StorageUri"    = $_.DiagnosticsProfile.BootDiagnostics.StorageUri
            "VM Extension"                  = $script:AzureRmVmLinuxVmExtensionsDetailTable
        }
        $script:AzureRmVmLinuxDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVmLinuxDetail) 

        $script:AzureRmVmLinuxTable += [PSCustomObject]@{
            "Name"                      = "<a name=`"$($_.Id.ToLower())`">$($_.Name)</a>"
            "computerName"              = $_.OSProfile.ComputerName
            "ResourceGroupName"         = $ResourceGroupName
            "ProvisioningState"         = $_.ProvisioningState
            "vmSize"                    = $_.HardwareProfile.VmSize
            "AvailabilitySetName"       = $AvailabilitySet
            "VirtualNetworkName"        = $VirtualNetwork
            "SubnetNames"               = $Subnet -join "<br>"
            "PrivateIpAddress"          = $PrivateIpAddress -join "<br>"
            "PublicIPAddress"           = $PublicIpAddress -join "<br>"
            "NetworkSecurityGroup"      = $NetworkSecurityGroup
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVmLinuxDetailTable
        }
    }
    $script:Report += "<h3>Linux VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-ProvisioningStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmVmLinuxTable))
}