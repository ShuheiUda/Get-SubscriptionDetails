<#
.SYNOPSIS
Collect data from Azure PowerShell in troubleshooting your subscription.

.DESCRIPTION
Collect data from Azure PowerShell in troubleshooting your subscription.

.PARAMETER SubscriptionId (Required)
If a subscription ID is specified, subscription-wide information will be provided.

.EXAMPLE
	Get-SubscriptionDetails.ps1 -SubscriptionID 1b30dfe1-c2b7-468d-a5cd-b0662c94ec2f

.NOTES
    Name    : Get-SubscriptionDetails.ps1
    GitHub  : https://github.com/ShuheiUda/Get-SubscriptionDetails
    Version : 0.8.1
    Author  : Syuhei Uda
    
    HTML table functions by Cookie.Monster (MIT License) http://gallery.technet.microsoft.com/scriptcenter/PowerShell-HTML-Notificatio-e1c5759d
#>

Param(
    [string]$SubscriptionID
)

# Header
$script:Version = "0.8.1"
$script:LatestVersionUrl = "https://raw.githubusercontent.com/ShuheiUda/Get-SubscriptionDetails/master/LatestVersion.txt"

<# start of html function #>
function ConvertTo-PropertyValue {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromRemainingArguments=$false)]
        [PSObject]$InputObject,
        
        [validateset("AliasProperty", "CodeProperty", "Property", "NoteProperty", "ScriptProperty",
            "Properties", "PropertySet", "Method", "CodeMethod", "ScriptMethod", "Methods",
            "ParameterizedProperty", "MemberSet", "Event", "Dynamic", "All")]
        [string[]]$memberType = @( "NoteProperty", "Property", "ScriptProperty" ),
            
        [string]$leftHeader = "Property",
            
        [string]$rightHeader = "Value"
    )

    begin{
        #init array to dump all objects into
        $allObjects = New-Object System.Collections.ArrayList

    }
    process{
        #if we're taking from pipeline and get more than one object, this will build up an array
        [void]$allObjects.add($inputObject)
    }

    end{
        #use only the first object provided
        $allObjects = $allObjects[0]

        #Get properties.  Filter by memberType.
        $properties = $allObjects.psobject.properties | ?{$memberType -contains $_.memberType} | select -ExpandProperty Name

        #loop through properties and display property value pairs
        foreach($property in $properties){

            #Create object with property and value
            $temp = "" | select $leftHeader, $rightHeader
            $temp.$leftHeader = $property.replace('"',"")
            $temp.$rightHeader = try { $allObjects | select -ExpandProperty $temp.$leftHeader -erroraction SilentlyContinue } catch { $null }
            $temp
        }
    }
}

function New-HTMLHead {
    [cmdletbinding(DefaultParameterSetName="String")]    
    param(
        
        [Parameter(ParameterSetName='File')]
        [validatescript({test-path $_ -pathtype leaf})]$cssPath = $null,
        
        [Parameter(ParameterSetName='String')]
        [string]$style = "<style>
                    body {
                        color:#333333;
                        font-family:Calibri,Tahoma,arial,verdana;
                        font-size: 11pt;
                    }
                    h1 {
                        text-align:center;
                    }
                    h2 {
                        border-top:1px solid #666666;
                    }
                    table {
                        border-collapse:collapse;
                    }
                    th {
                        text-align:left;
                        font-weight:bold;
                        color:#eeeeee;
                        background-color:#333333;
                        border:1px solid black;
                        padding:5px;
                    }
                    td {
                        padding:5px;
                        border:1px solid black;
                    }
                    .odd { background-color:#ffffff; }
                    .even { background-color:#dddddd; }
                </style>",
        
        [string]$title = $null
    )

    #add css from file if specified
    if($cssPath){$style = "<style>$(get-content $cssPath | out-string)</style>"}

    #Return HTML
    @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            $(if($title){"<title>$title</title>"})
                $style
        </head>
        <body>

"@

}

function New-HTMLTable {
    [CmdletBinding()] 
    param ( 
        [Parameter( Position=0,
                    Mandatory=$true, 
                    ValueFromPipeline=$true)]
        [PSObject[]]$InputObject,

        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [string[]]$Properties,
        
        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [bool]$setAlternating = $true,

        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [string]$listTableHead = $null

        )
    
    BEGIN { 
        #requires -version 2.0
        add-type -AssemblyName System.xml.linq | out-null
        $Objects = New-Object System.Collections.ArrayList
    } 
 
    PROCESS { 

        #Loop through inputObject, add to collection.  Filter properties if specified.
        foreach($object in $inputObject){
            if($Properties){ [void]$Objects.add(($object | Select $Properties)) }
            else{ [void]$Objects.add( $object )}
        }

    } 
 
    END { 

        # Convert our data to x(ht)ml  
        $xml = [System.Xml.Linq.XDocument]::Parse("$($Objects | ConvertTo-Html -Fragment)")
        
        #replace * as table head if specified.  Note, this should only be done for a list...
        if($listTableHead){
            $xml = [System.Xml.Linq.XDocument]::parse( $xml.Document.ToString().replace("<th>*</th>","<th>$listTableHead</th>") )
        }

        if($setAlternating){
            #loop through descendents.  If their index is even mark with class even, odd with class odd.
            foreach($descendent in $($xml.Descendants("tr"))){
                if(($descendent.NodesBeforeSelf() | Measure-Object).count % 2 -eq 0){
                    $descendent.SetAttributeValue("class", "even") 
                }
                else{
                    $descendent.SetAttributeValue("class", "odd") 
                }
            }
        }
        #Provide full HTML or just the table depending on param
        $xml.Document.ToString()
    }
}

function Add-HTMLTableColor {
    [CmdletBinding()] 
    param ( 
        [Parameter( Mandatory=$true,  
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$false)]  
        [string]$HTML,
        
        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)]
        [String]$Column="Name",
        
        [Parameter( Mandatory=$false,
                    ValueFromPipeline=$false)]
        $Argument=0,
        
        [Parameter( ValueFromPipeline=$false)]
        [ScriptBlock]$ScriptBlock = {[string]$args[0] -eq [string]$args[1]},
        
        [Parameter( ValueFromPipeline=$false)]
        [String]$Attr = "style",
        
        [Parameter( Mandatory=$true, 
                    ValueFromPipeline=$false)] 
        [String]$AttrValue,
        
        [Parameter( Mandatory=$false, 
                    ValueFromPipeline=$false)] 
        [switch]$WholeRow=$false

        )
    
        #requires -version 2.0
        add-type -AssemblyName System.xml.linq | out-null

        # Convert our data to x(ht)ml  
        $xml = [System.Xml.Linq.XDocument]::Parse($HTML)   
        
        #Get column index.  try th with no namespace first, then default namespace provided by convertto-html
        try{ 
            $columnIndex = (($xml.Descendants("th") | Where-Object { $_.Value -eq $Column }).NodesBeforeSelf() | Measure-Object).Count 
        }
        catch { 
            Try {
                $columnIndex = (($xml.Descendants("{http://www.w3.org/1999/xhtml}th") | Where-Object { $_.Value -eq $Column }).NodesBeforeSelf() | Measure-Object).Count
            }
            Catch {
                Throw "Error:  Namespace incorrect."
            }
        }

        #if we got the column index...
        if($columnIndex -as [double] -ge 0){
            
            #take action on td descendents matching that index
            switch($xml.Descendants("td") | Where { ($_.NodesBeforeSelf() | Measure).Count -eq $columnIndex })
            {
                #run the script block.  If it is true, set attributes
                {$(Invoke-Command $ScriptBlock -ArgumentList @($_.Value, $Argument))} { 
                    
                    #mark the whole row or just a cell depending on param
                    if ($WholeRow)  { 
                        $_.Parent.SetAttributeValue($Attr, $AttrValue) 
                    } 
                    else { 
                        $_.SetAttributeValue($Attr, $AttrValue) 
                    }
                }
            }
        }
        
        #return the XML
        $xml.Document.ToString() 
}

function Close-HTML {
    [cmdletbinding()]
    param(
        [Parameter( Mandatory=$true,  
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$false)]  
        [string]$HTML,

        [switch]$Decode
    )
    #Thanks to 窶宗ashyoungblood!
    if($Decode)
    {
        Add-Type -AssemblyName System.Web
        $HTML = [System.Web.HttpUtility]::HtmlDecode($HTML)
    }
    "$HTML </body></html>"
}
<# end of html function #>

# Login and select Subscription
function New-AzureSession{
    if($SubscriptionID -eq ""){
        Write-Error "Please input SubscriptionID."
        break
    }
    Add-AzureAccount
    Login-AzureRmAccount    
    $AzureSubscription = Get-AzureSubscription
    $AzureRmSubscription = Get-AzureRmSubscription
    Select-AzureSubscription -SubscriptionId $SubscriptionID
    Select-AzureRmSubscription -SubscriptionId $SubscriptionID
}

function Initialize{
    $InformationPreference = "SilentlyContinue"
    $VerbosePreference = "SilentlyContinue"
    $DebugPreference = "SilentlyContinue"
    $WarningPreference = "SilentlyContinue"
    $script:ExecutedDate = Get-Date
    $script:ExecutedDateString = $script:ExecutedDate.ToString("yyyy-MM-ddTHH:mm:ss")

    # Version Check
    $script:LatestVersion = (Invoke-WebRequest $script:LatestVersionUrl).Content
    if($script:Version -ne $script:LatestVersion){
        Write-Warning "New version is available. ($script:LatestVersion)`nhttps://github.com/ShuheiUda/Get-SubscriptionDetails"
    }
}

# Get ASM Information
function Get-AsmInformation{
    $script:AzureServices = Get-AzureService
    $script:AzureVM = Get-AzureVM
    $script:AzureVNetConfig = [xml](Get-AzureVNetConfig).XMLConfiguration
    $script:AzureVirtualNetworkGateway = Get-AzureVirtualNetworkGateway
    $script:AzureStorageAccount = Get-AzureStorageAccount
    $script:AzureDisk = Get-AzureDisk
    $script:AzureVMImage = Get-AzureVMImage
}

# Get ARM Information
function Get-ArmInformation{
    $script:AzureRmLocation = ((Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Compute).ResourceTypes | Where-Object ResourceTypeName -eq virtualMachines).Locations
    $script:AzureRmVM = Get-AzureRmVM
    $script:AzureRmResourceGroup = Get-AzureRmResourceGroup
    $script:AzureRmVirtualNetwork = Get-AzureRmVirtualNetwork
    $script:AzureRmNetworkInterface = Get-AzureRmNetworkInterface
    $Script:AzureRmLocalNetworkGateway = ($Script:AzureRmResourceGroup | Get-AzureRmLocalNetworkGateway)
    $Script:AzureRmVirtualNetworkGateway = ($Script:AzureRmResourceGroup | Get-AzureRmVirtualNetworkGateway)
    $script:AzureRmPublicIpAddress = Get-AzureRmPublicIpAddress
    $script:AzureRmStorageAccount = Get-AzureRmStorageAccount
    $script:AzureRmLog = Get-AzureRmLog -StartTime $script:ExecutedDate.AddDays(-14)
}

# Create new html data
function Save-AzureReportHeader{
    $script:Report = New-HTMLHead -title "Get-SubscriptionDetails Report"
    $script:Report += "<h2>Get-SubscriptionDetails Report (Version: $script:Version)</h2>"
    $script:Report += "<h3>Subscription ID: $SubscriptionID ( Executed on : $script:ExecutedDateString )<br><a href=`"#CRP`">Virtual Machine</a> | <a href=`"#SRP`">Storage</a> | <a href=`"#NRP`">Network</a> | <a href=`"#Ops`">Operation</a></h3>"
}

# Save information for ASM VMs
function Save-AzureReportAsmVm{
    $script:AzureVmWindows = $Script:AzureVM | where{$_.VM.OSVirtualHardDisk.OS -eq "Windows"}
    $script:AzureVmLinux = $Script:AzureVM | where{$_.VM.OSVirtualHardDisk.OS -eq "Linux"}
    $script:AzureVmWindowsTable = @()
    $script:AzureVmLinuxTable = @()

    $script:AzureVmWindows | foreach{
         $script:AzureVmWindowsTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "HostName"                  = $_.HostName;
            "Status"                    = $_.Status;
            "InstanceStatus"            = $_.InstanceStatus;
            "PowerState"                = $_.PowerState;
            "InstanceSize"              = $_.InstanceSize;
            "ServiceName"               = $_.ServiceName;
            "DNSName"                   = $_.DNSName;
            "AvailabilitySetName"       = $_.AvailabilitySetName;
            "VirtualNetworkName"        = $_.VirtualNetworkName;
            "SubnetNames"               = $_.VM.ConfigurationSets.SubnetNames;
            "IpAddress"                 = $_.IpAddress;
            "PublicIPAddress"           = $_.PublicIPAddress;
            "RDP EndPoint"              = (($_.VM.ConfigurationSets.InputEndPoints | where{($_.LocalPort -eq "3389") -or ($_.Name -eq "Remote Desktop")})).Port;
            "PowerShell EndPoint"       = (($_.VM.ConfigurationSets.InputEndPoints) | where{($_.LocalPort -eq "5986") -or ($_.Name -eq "PowerShell")}).Port
        }
    }

    $AzureVmLinux | foreach{
         $script:AzureVmLinuxTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "HostName"                  = $_.HostName;
            "Status"                    = $_.Status;
            "InstanceStatus"            = $_.InstanceStatus;
            "PowerState"                = $_.PowerState;
            "InstanceSize"              = $_.InstanceSize;
            "ServiceName"               = $_.ServiceName;
            "DNSName"                   = $_.DNSName;
            "AvailabilitySetName"       = $_.AvailabilitySetName;
            "VirtualNetworkName"        = $_.VirtualNetworkName;
            "SubnetNames"               = $_.VM.ConfigurationSets.SubnetNames;
            "IpAddress"                 = $_.IpAddress;
            "PublicIPAddress"           = $_.PublicIPAddress;
            "SSH EndPoint"              = (($_.VM.ConfigurationSets.InputEndPoints) | where{($_.LocalPort -eq "22") -or ($_.Name -eq "SSH")}).Port;
         }
    }
    
    # Create Tables
    $script:Report += "<a name=`"CRP`"><h2>Virtual Machine</h2></a>"
    $script:Report += "<h3>ASM Windows VM</h3>"
    $script:Report += New-HTMLTable -InputObject $AzureVmWindowsTable
    $script:Report += "<h3>ASM Linux VM</h3>"
    $script:Report += New-HTMLTable -InputObject $AzureVmLinuxTable
}

function Save-AzureReportArmVm{
    # Save information for ARM VMs
    $AzureRmVmWindows = $Script:AzureRmVm | where{$_.StorageProfile.OsDisk.OsType -eq "Windows"}
    $AzureRmVmLinux = $Script:AzureRmVm | where{$_.StorageProfile.OsDisk.OsType -eq "Linux"}

    $script:AzureRmVmWindowsTable = @()
    $AzureRmVmWindows | foreach{
        $ResourceGroupName = $_.ResourceGroupName
        $AvailabilitySet = ($_.AvailabilitySetReference.Id -replace "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/availabilitySets/", "")
        
        if($_.NetworkInterfaceIDs[0] -match "/providers/Microsoft.Network/networkInterfaces/.{1,80}$"){
            $NetworkInterface = $Matches[0] -replace "/providers/Microsoft.Network/networkInterfaces/", ""
            $script:AzureRmNetworkInterface | foreach{
                if($_.Name -eq $NetworkInterface){
                    $VirtualMachine = $null
                    $PrivateIpAddress = $null
                    $PublicIPAddress = $null
                    $PublicIpAddressName = $null
                    $NetworkSecurityGroup = $null
                    $TempSubnetId = $null
                    $VirtualNetwork = $null
                    $Subnet = $null

                    $PrivateIpAddress = $_.IpConfigurations.PrivateIpAddress
                    if($_.IpConfigurations.PublicIpAddress.Id -match "/providers/Microsoft.Network/publicIPAddresses/.{1,80}$"){
                        $PublicIpAddressName = $Matches[0] -replace "/providers/Microsoft.Network/publicIPAddresses/", ""
                        $script:AzureRmPublicIpAddress | foreach{
                            if($_.Name -eq $PublicIpAddressName){
                                $PublicIpAddress = $_.IpAddress
                            }
                        }
                    }
                    if($_.NetworkSecurityGroup.Id -match "/providers/Microsoft.Network/networkSecurityGroups/[a-zA-Z0-9_.-]{1,80}$"){
                        $NetworkSecurityGroup = $Matches[0] -replace "/providers/Microsoft.Network/networkSecurityGroups/", ""
                    }
                    if($_.IpConfigurations.Subnet.Id -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
                        $TempSubnetId = $Subnet = $Matches[0] -split "/"
                        $VirtualNetwork = $TempSubnetId[4]
                        $Subnet = $TempSubnetId[6]
                    }
                }
            }
        }
        $script:AzureRmVmWindowsTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "computerName"              = $_.OSProfile.ComputerName;
            "ResourceGroupName"         = $ResourceGroupName;
            "ProvisioningState"         = $_.ProvisioningState;
            "vmSize"                    = $_.HardwareProfile.VmSize;
            "AvailabilitySetName"       = $AvailabilitySet;
            "VirtualNetworkName"        = $VirtualNetwork;
            "SubnetNames"               = $Subnet;
            "PrivateIpAddress"          = $PrivateIpAddress;
            "PublicIPAddress"           = $PublicIpAddress;
            "NetworkSecurityGroup"      = $NetworkSecurityGroup
        }
    }
 
    $script:AzureRmVmLinuxTable = @()
    $AzureRmVmLinux | foreach{
        $ResourceGroupName = $_.ResourceGroupName
        $AvailabilitySet = ($_.AvailabilitySetReference.Id -replace "/subscriptions/$SubscriptionID/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/availabilitySets/", "")
        
        if($_.NetworkInterfaceIDs[0] -match "/providers/Microsoft.Network/networkInterfaces/.{1,80}$"){
            $NetworkInterface = $Matches[0] -replace "/providers/Microsoft.Network/networkInterfaces/", ""
            $script:AzureRmNetworkInterface | foreach{
                if($_.Name -eq $NetworkInterface){
                    $VirtualMachine = $null
                    $PrivateIpAddress = $null
                    $PublicIPAddress = $null
                    $PublicIpAddressName = $null
                    $NetworkSecurityGroup = $null
                    $TempSubnetId = $null
                    $VirtualNetwork = $null
                    $Subnet = $null

                    $PrivateIpAddress = $_.IpConfigurations.PrivateIpAddress
                    if($_.IpConfigurations.PublicIpAddress.Id -match "/providers/Microsoft.Network/publicIPAddresses/.{1,80}$"){
                        $PublicIpAddressName = $Matches[0] -replace "/providers/Microsoft.Network/publicIPAddresses/", ""
                        $script:AzureRmPublicIpAddress | foreach{
                            if($_.Name -eq $PublicIpAddressName){
                                $PublicIpAddress = $_.IpAddress
                            }
                        }
                    }
                    if($_.NetworkSecurityGroup.Id -match "/providers/Microsoft.Network/networkSecurityGroups/[a-zA-Z0-9_.-]{1,80}$"){
                        $NetworkSecurityGroup = $Matches[0] -replace "/providers/Microsoft.Network/networkSecurityGroups/", ""
                    }
                    if($_.IpConfigurations.Subnet.Id -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
                        $TempSubnetId = $Subnet = $Matches[0] -split "/"
                        $VirtualNetwork = $TempSubnetId[4]
                        $Subnet = $TempSubnetId[6]
                    }
                }
            }
        }
        $script:AzureRmVmLinuxTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "computerName"              = $_.OSProfile.ComputerName;
            "ResourceGroupName"         = $ResourceGroupName;
            "ProvisioningState"         = $_.ProvisioningState;
            "vmSize"                    = $_.HardwareProfile.VmSize;
            "AvailabilitySetName"       = $AvailabilitySet;
            "VirtualNetworkName"        = $VirtualNetwork;
            "SubnetNames"               = $Subnet;
            "PrivateIpAddress"          = $PrivateIpAddress;
            "PublicIPAddress"           = $PublicIpAddress;
            "NetworkSecurityGroup"      = $NetworkSecurityGroup
        }
    }
    
    # Create Tables
    $script:Report += "<h3>ARM Windows VM</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmVmWindowsTable
    $script:Report += "<h3>ARM Linux VM</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmVmLinuxTable
}

# Save information for classic Storage
function Save-AzureReportAsmStr{
    $script:AzureStorageAccountTable = @()
    $script:AzureDiskTable = @()
    $script:AzureVMImageTable = @()
    
    $script:AzureStorageAccount | foreach{
        $script:AzureStorageAccountTable += [PSCustomObject]@{
            "StorageAccountName"        = $_.StorageAccountName;
            "AccountType"               = $_.AccountType;
            "StatusOfPrimary"           = $_.StatusOfPrimary;
            "Location"                  = $_.Location;
            "GeoReplicationEnabled"     = $_.GeoReplicationEnabled;
            "GeoPrimaryLocation"        = $_.GeoPrimaryLocation;
            "GeoSecondaryLocation"      = $_.GeoSecondaryLocation;
            "Endpoints"                 = $_.Endpoints[0]
        }
    }

    $script:AzureDisk | foreach{
        $script:AzureDiskTable += [PSCustomObject]@{
            "DiskName"                  = $_.DiskName;
            "AttachedTo.RoleName"       = $_.AttachedTo.RoleName;
            "OS"                        = $_.OS;
            "DiskSizeInGB"              = $_.DiskSizeInGB;
            "SourceImageName"           = $_.SourceImageName;
            "MediaLink"                 = $_.MediaLink
        }
    }

    $script:AzureVMImage | where {$_.category -eq “User”} | foreach{
        $script:AzureVMImageTable += [PSCustomObject]@{
            "ImageName"                 = $_.ImageName;
            "Label"                     = $_.Label;
            "RoleName"                  = $_.RoleName;
            "OS"                        = $_.OS;
            "LogicalDiskSizeInGB"       = $_.OSDiskConfiguration.LogicalDiskSizeInGB;
            "MediaLink"                 = $_.OSDiskConfiguration.MediaLink;
            "CreatedTime"               = $_.CreatedTime;
            "ModifiedTime"              = $_.ModifiedTime
        }
    }
    
    # Create Tables
    $script:Report += "<a name=`"SRP`"><h2>Storage</h2></a>"
    $script:Report += "<h3>ASM StorageAccount</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureStorageAccountTable
    $script:Report += "<h3>ASM VM Disk</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureDiskTable
    $script:Report += "<h3>ASM OS Image</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureVMImageTable
}

function Save-AzureReportArmStr{
    # Save information for ARM Storage
    $script:AzureRmStorageAccountTable = @()
    $script:AzureRmStorageAccount | foreach{
        $script:AzureRmStorageAccountTable += [PSCustomObject]@{
            "StorageAccountName"        = $_.StorageAccountName;
            "AccountType"               = $_.AccountType;
            "StatusOfPrimary"           = $_.StatusOfPrimary;
            "Location"                  = $_.Location;
            "GeoReplicationEnabled"     = $_.GeoReplicationEnabled;
            "GeoPrimaryLocation"        = $_.GeoPrimaryLocation;
            "GeoSecondaryLocation"      = $_.GeoSecondaryLocation;
            "Endpoints"                 = $_.PrimaryEndpoints.Blob.AbsoluteUri
        }
    }

    $script:AzureRmVmDiskTable = @()
    $Script:AzureRmVm | foreach{
        $_.StorageProfile.OsDisk.Vhd.Uri -match "[a-z0-9]{3,24}.blob.core.windows.net/vhds/"
        [string]$StorageAccountName = $Matches[0] -replace ".blob.core.windows.net/vhds/", ""
        $script:AzureRmVmDiskTable += [PSCustomObject]@{
            "Disk Name"                 = $_.StorageProfile.osDisk.name;
            "Attached To"               = $_.Name;
            "StorageAccountName"        = $StorageAccountName;
            "OS"                        = $_.StorageProfile.osDisk.osType;
            "Publisher"                 = $_.StorageProfile.ImageReference.Publisher;
            "Offer"                     = $_.StorageProfile.ImageReference.Offer;
            "Sku"                       = $_.StorageProfile.ImageReference.Sku;
            "DiskSizeInGB"              = $_.StorageProfile.osDisk.diskSizeGB;
            "Create Option"             = $_.StorageProfile.osDisk.createOption;
            "MediaLink"                 = $_.StorageProfile.osDisk.vhd.uri
        }
    }
    
    # Create Tables
    $script:Report += "<h3>ARM StorageAccount</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmStorageAccountTable
    $script:Report += "<h3>ARM VM Disk</h3>"
    $script:Report += New-HTMLTable -InputObject $Script:AzureRmVmDiskTable
}

# Save information for ASM Network
function Save-AzureReportAsmNw{
    $script:AzureDnsServerTable = @()
    $script:AzureLocalNetworkSiteTable = @()
    $script:AzureVirtualNetworkSiteTable = @()
    $script:AzureVirtualNetworkGatewayTable = @()

    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.dns.DnsServers.DnsServer | foreach{
        $script:AzureDnsServerTable += [PSCustomObject]@{
            "name"                      = $_.name;
            "IPAddress"                 = $_.IPAddress
        }
    }
    
    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite | foreach{
        $script:AzureLocalNetworkSiteTable += [PSCustomObject]@{
            "name"                      = $_.name;
            "AddressSpace"              = $_.AddressSpace.AddressPrefix;
            "VPNGatewayAddress"         = $_.VPNGatewayAddress
        }
    }
    
    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.VirtualNetworkSites.VirtualNetworkSite | foreach{
        $script:AzureVirtualNetworkSiteTable += [PSCustomObject]@{
            "name"                      = $_.name;
            "Location"                  = $_.Location;
            "AddressSpace"              = $_.AddressSpace.AddressPrefix -join ", ";
            "Subnets"                   = $_.Subnets.Subnet.AddressPrefix -join ", ";
            "DnsServersRef"             = $_.DnsServersRef.DnsServerRef.name
        }
    }

    $script:AzureVirtualNetworkGateway | foreach{
        $script:AzureVirtualNetworkGatewayTable += [PSCustomObject]@{
            "GatewayName"               = $_.GatewayName;
            "State"                     = $_.State;
            "GatewayType"               = $_.GatewayType;
            "GatewayId"                 = $_.GatewayId;
            "VnetId"                    = $_.VnetId;
            "VIPAddress"                = $_.VIPAddress
        }
    }
    
    # Create Tables
    $script:Report += "<a name=`"NRP`"><h2>Network</h2></a>"
    $script:Report += "<h3>ASM DNS Server</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureDnsServerTable
    $script:Report += "<h3>ASM Local Network Sites</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureLocalNetworkSiteTable
    $script:Report += "<h3>ASM Virtual Network Sites</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureVirtualNetworkSiteTable
    $script:Report += "<h3>ASM Virtual Network Gateway</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureVirtualNetworkGatewayTable
}

# Save information for ARM Network
function Save-AzureReportArmNw{
    $script:AzureRmVirtualNetworkTable = @()
    $script:AzureRmVirtualNetworkGatewayTable = @()
    $script:NetworkInterfaceTable = @()
    $script:AzureRmPublicIpAddressTable = @()
    $script:AzureRmLocalNetworkGatewayTable = @()
    $script:AzureLocalNetworkSiteTable = @()

    $script:AzureRmVirtualNetwork | foreach{
        $script:AzureRmVirtualNetworkTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "ResourceGroupName"         = $_.ResourceGroupName;
            "Location"                  = $_.Location;
            "Address Space"             = $_.AddressSpace.AddressPrefixes -join ", ";
            "Subnets"                   = $_.Subnets.AddressPrefix -join ", ";
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
        }
    }

    $script:AzureRmVirtualNetworkGateway | foreach{
        $script:AzureRmVirtualNetworkGatewayTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "ResourceGroupName"         = $_.ResourceGroupName;
            "Location"                  = $_.Location;
            "ProvisioningState"         = $_.ProvisioningState;
            "GatewayType"               = $_.GatewayType;
            "VpnType"                   = $_.VpnType
        }
    }

    $Script:AzureRmNetworkInterface | foreach{
        $VirtualMachine = $null
        $NetworkSecurityGroup = $null
        if($_.VirtualMachine.Id -match "/providers/Microsoft.Compute/virtualMachines/.{1,15}$"){
            $VirtualMachine = $Matches[0] -replace "/providers/Microsoft.Compute/virtualMachines/", ""
        }
        if($_.NetworkSecurityGroup.Id -match "/providers/Microsoft.Network/networkSecurityGroups/[a-zA-Z0-9_.-]{1,80}$"){
            $NetworkSecurityGroup = $Matches[0] -replace "/providers/Microsoft.Network/networkSecurityGroups/", ""
        }
        if($_.IpConfigurations.Subnet.Id -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
            $TempSubnetId = $Subnet = $Matches[0] -split "/"
            $VirtualNetwork = $TempSubnetId[4]
            $Subnet = $TempSubnetId[6]
        }
        $script:NetworkInterfaceTable += [PSCustomObject]@{
            "Name" = $_.Name;
            "Location" = $_.Location;
            "Virtual Machine"           = $VirtualMachine;
            "VirtualNetwork"            = $VirtualNetwork;
            "Subnet"                    = $Subnet;
            "PrivateIpAddress"          = $_.IpConfigurations.PrivateIpAddress;
            "PrivateIpAllocationMethod" = $_.IpConfigurations.PrivateIpAllocationMethod;
            "CustomeDnsSettings"        = $_.DnsSettings.DnsServers -join ", ";
            "NetworkSecurityGroup"      = $NetworkSecurityGroup
        }
    }

    $script:AzureRmPublicIpAddress | foreach{
        $script:AzureRmPublicIpAddressTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "ResourceGroupName"         = $_.ResourceGroupName;
            "Location"                  = $_.Location;
            "PublicIpAllocationMethod"  = $_.PublicIpAllocationMethod;
            "IpAddress"                 = $_.IpAddress;
            "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
        }
    }

    $script:AzureRmLocalNetworkGateway | foreach{
        $script:AzureRmLocalNetworkGatewayTable += [PSCustomObject]@{
            "Name"                      = $_.Name;
            "ResourceGroupName"         = $_.ResourceGroupName;
            "Location"                  = $_.Location;
            "ProvisioningState"         = $_.ProvisioningState;
            "GatewayIpAddress"          = $_.GatewayIpAddress;
            "LocalNetworkAddressSpace"  = $_.LocalNetworkAddressSpace.AddressPrefixes -join ", "
        }
    }

    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite | foreach{
        $script:AzureLocalNetworkSiteTable += [PSCustomObject]@{
            "name"                      = $_.name;
            "AddressSpace"              = $_.AddressSpace.AddressPrefix;
            "VPNGatewayAddress"         = $_.VPNGatewayAddress
        }
    }

    # Create Tables
    $script:Report += "<h3>ARM Virtual Network</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmVirtualNetworkTable
    $script:Report += "<h3>ARM Virtual Network Gateway</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmVirtualNetworkGatewayTable
    $script:Report += "<h3>ARM Network Interface</h3>"
    $script:Report += New-HTMLTable -InputObject $script:NetworkInterfaceTable
    $script:Report += "<h3>ARM Public IP Address</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmPublicIpAddressTable
    $script:Report += "<h3>ARM Local Network Gateway</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmLocalNetworkGatewayTable
    $script:Report += "<h3>ARM Local Network Sites</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureLocalNetworkSiteTable
}

function Save-AzureReportArmOps{
    $script:AzureLogTable = @()

    $script:AzureRmLogCorrelationId = ($script:AzureRmLog.CorrelationId | Get-Unique)
    
    $script:AzureRmLogCorrelationId | foreach{
        $script:CorrelationId = $_
        $script:Action = $null
        $script:Status = $null
        $script:StartTime = $null
        $script:EndTime = $null
        $script:ResourceGroupName = $null
        $script:Scope = $null
        $script:Caller = $null

        $script:AzureRmLog | where{$_.CorrelationId -eq $script:CorrelationId} | foreach{
            if($_.Status -eq "Started"){
                $script:Action            = $_.Authorization.Action
                $script:StartTime         = Get-Date $_.EventTimestamp -Format "yyyy-MM-ddTHH:mm:ss"
                $script:ResourceGroupName = $_.ResourceGroupName
                $script:Scope             = $_.Authorization.Scope -replace "/subscriptions/$SubscriptionID", ""
                $script:Caller            = $_.Caller
                $script:CorrelationId     = $_.CorrelationId
            }else{
                $script:Action            = $_.Authorization.Action
                $script:Status            = $_.Status
                $script:EndTime           = Get-Date $_.EventTimestamp -Format "yyyy-MM-ddTHH:mm:ss"
                $script:ResourceGroupName = $_.ResourceGroupName
                $script:Scope             = $_.Authorization.Scope -replace "/subscriptions/$SubscriptionID", ""
                $script:Caller            = $_.Caller
                $script:CorrelationId     = $_.CorrelationId
            }
        }

        if($script:Status -eq $null){
            $script:Status                = "Started"
        }

        $script:Duration                  = New-TimeSpan $script:StartTime $script:EndTime

        $script:AzureLogTable += [PSCustomObject]@{
            "Action"                      = $script:Action;
            "Status"                      = $script:Status;
            "StartTime"                   = $script:StartTime;
            "EndTime"                     = $script:EndTime;
            "Duration"                    = $script:Duration;
            "Scope"                       = $script:Scope;
            "ResourceGroupName"           = $script:ResourceGroupName;
            "Caller"                      = $script:Caller;
            "CorrelationId"               = $script:CorrelationId
        }
    }
    
    $script:AzureComputeLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.ClassicCompute"})
    $script:AzureStorageLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.ClassicStorage"})
    $script:AzureNetworkLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.ClassicNetwork"})
    $script:AzureRmResourcesLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.Resources"})
    $script:AzureRmComputeLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.Compute"})
    $script:AzureRmStorageLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.Storage"})
    $script:AzureRmNetworkLogTable = ($script:AzureLogTable | where {$_.Action -match "Microsoft.Network"})
    $script:AzureRmAnotherLogTable = ($script:AzureLogTable | where {($_.Action -notmatch "Microsoft.ClassicCompute") -and ($_.Action -notmatch "Microsoft.ClassicStorage") -and ($_.Action -notmatch "Microsoft.ClassicNetwork") -and ($_.Action -notmatch "Microsoft.Resources") -and ($_.Action -notmatch "Microsoft.Compute") -and ($_.Action -notmatch "Microsoft.Storage") -and ($_.Action -notmatch "Microsoft.Network")})

    # Create Tables
    $script:LogStartTime = $script:ExecutedDate.AddDays(-14).ToString("yyyy-MM-ddTHH:mm:ss")
    $script:Report += "<a name=`"Ops`"><h2>Operation</h2></a> between $script:LogStartTime and $script:ExecutedDateString"
    $script:Report += "<h3>ASM Compute Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureComputeLogTable
    $script:Report += "<h3>ARM Storage Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureStorageLogTable
    $script:Report += "<h3>ARM Network Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureNetworkLogTable
    $script:Report += "<h3>ARM Resource Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmResourceLogTable
    $script:Report += "<h3>ARM Compute Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmComputeLogTable
    $script:Report += "<h3>ARM Storage Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmStorageLogTable
    $script:Report += "<h3>ARM Network Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmNetworkLogTable
    $script:Report += "<h3>ASM / ARM Another Operation</h3>"
    $script:Report += New-HTMLTable -InputObject $script:AzureRmAnotherLogTable
}

# Close html
function Save-AzureReportFooter{
    Close-HTML -HTML $script:Report -Verbose
    
    $OutputFolder = "$env:USERPROFILE\Desktop\Get-SubscriptionDetails\"
    if((Test-Path $OutputFolder) -eq $false){
        New-Item -Path $OutputFolder -ItemType Directory
    }
    $Date = (Get-Date -Format yyyyMMdd_HHmmss)
    $ReportPath = "$env:USERPROFILE\Desktop\Get-SubscriptionDetails\$SubscriptionID-$Date.htm"
    Set-Content $ReportPath $script:Report
    . $ReportPath
}

# Call save function
function Save-AzureReport{
    Save-AzureReportHeader
    Save-AzureReportAsmVm
    Save-AzureReportArmVm
    Save-AzureReportAsmStr
    Save-AzureReportArmStr
    Save-AzureReportAsmNw
    Save-AzureReportArmNw
    Save-AzureReportArmOps
    Save-AzureReportFooter
}

# Main method
Initialize
New-AzureSession
Get-AsmInformation
Get-ArmInformation
Save-AzureReport