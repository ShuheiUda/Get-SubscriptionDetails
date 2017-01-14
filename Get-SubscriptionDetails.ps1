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
    Version : 0.9.0
    Author  : Syuhei Uda
    
    HTML table functions by Cookie.Monster (MIT License) http://gallery.technet.microsoft.com/scriptcenter/PowerShell-HTML-Notificatio-e1c5759d
#>

Param(
    [string]$SubscriptionID,
    [string]$OutputFolder = "$env:USERPROFILE\Desktop\Get-SubscriptionDetails",
    [switch]$SkipAuth
)

# Header
$script:Version = "0.9.0"
$script:LatestVersionUrl = "https://raw.githubusercontent.com/ShuheiUda/Get-SubscriptionDetails/master/LatestVersion.txt"

Function Write-Log
{
    param(
    [string]$Message,
    [string]$Color = 'White'
    )

    $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Date] $Message"-ForegroundColor $Color
}

Function New-ResourceHTMLTable
{
    param(
    $InputObject
    )

    if($InputObject -ne $null){
        New-HTMLTable -InputObject $InputObject
    }
}

Function ConvertTo-DetailView{
    param(
        $InputObject
    )
    
    if($InputObject -ne $null){
        $InputObject = $InputObject.Replace("  <tr class=`"odd`">`r`n    <td>","  <tr class=`"odd detail`">`r`n    <td><span class=`"expandable`"></span>")
        $InputObject = $InputObject.Replace("  <tr class=`"even`">`r`n    <td>","  <tr class=`"even detail`">`r`n    <td><span class=`"expandable`"></span>")
        $InputObject = $InputObject.Replace('&amp;','&')
        $InputObject = $InputObject.Replace('&lt;','<')
        $InputObject = $InputObject.Replace('&gt;','>')
        $InputObject = $InputObject.Replace('<td><table>','<td>  <table>')
    }

    return $InputObject
}

Function ConvertTo-SummaryView{
    param(
        $InputObject
    )

    if($InputObject -ne $null){
        $InputObject = $InputObject.Replace("  <tr class=`"odd`">`r`n    <td>","  <tr class=`"odd summary`">`r`n    <td><span class=`"expandable`"></span>")
        $InputObject = $InputObject.Replace("  <tr class=`"even`">`r`n    <td>","  <tr class=`"even summary`">`r`n    <td><span class=`"expandable`"></span>")
        $InputObject = $InputObject.Replace('&amp;','&')
        $InputObject = $InputObject.Replace('&lt;','<')
        $InputObject = $InputObject.Replace('&gt;','>')
        $InputObject = $InputObject.Replace('<th>Detail</th>','')
        $InputObject = $InputObject.Replace('<td><table>','</tr><tr style=display:none><td colspan="99"><table>')
    }

    return $InputObject
}

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
            $temp.$rightHeader = try { $allObjects | select -ExpandProperty $temp.$leftHeader } catch { $null }
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
                    tr.summary {
                        cursor:pointer;
                    }
                    .summary .expandable:after{
                        content: '+  ';
                    }
                    .summary.expand .expandable:after{
                        content: '- ';
                    }
                    table {
                        border-collapse:collapse;
                    }
                    th {
                        text-align:left;
                        font-weight:bold;
                        color:White;
                        background-color:#71b1d1;
                        border:1px solid black;
                        padding:5px;
                    }
                    td {
                        padding:5px;
                        border:1px solid black;
                    }
                    .odd {
                        background-color:#ffffff;
                    }
                    .even {
                        background-color:#e1f3fb;
                    }
                </style>",

        [string]$script =  '<script src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.1.1.min.js"></script>
                <script>
                $(document).ready(function(){
                    $(".summary").click(function() {
                    $(this).toggleClass("expand").nextUntil("tr.summary").slideToggle(100);
                    });
                });
                </script>',
        
        [string]$title = $null
    )

    #add css from file if specified
    if($cssPath){$style = "<style>$(get-content $cssPath | out-string)</style>"}

    #Return HTML
    @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
            <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
            $(if($title){"<title>$title</title>"})
                $style
                $script
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
        
    if($SkipAuth -ne $true){
        Write-Log "Waiting: Add-AzureAccount"
        $null = Add-AzureAccount
        Write-Log "Success: Add-AzureAccount" -Color Green

        Write-Log "Waiting: Login-AzureRmAccount"
        $null = Login-AzureRmAccount
        Write-Log "Success: Login-AzureRmAccount" -Color Green

        Write-Log "Waiting: Select-AzureSubscription"
        $null = Select-AzureSubscription -SubscriptionId $SubscriptionID
        Write-Log "Success: Select-AzureSubscription" -Color Green
    
        Write-Log "Waiting: Select-AzureRmSubscription"
        $null = Select-AzureRmSubscription -SubscriptionId $SubscriptionID
        Write-Log "Success: Select-AzureRmSubscription" -Color Green
    }
}

function Initialize{
    Write-Log "Waiting: Initialize"
    $InformationPreference = "SilentlyContinue"
    $VerbosePreference = "SilentlyContinue"
    $DebugPreference = "SilentlyContinue"
    $WarningPreference = "SilentlyContinue"
    $script:ExecutedDate = Get-Date
    $script:ExecutedDateString = $script:ExecutedDate.ToString("yyyy-MM-ddTHH:mm:ss")
    Write-Log "Success: Initialize" -Color Green

    # Version Check
    Write-Log "Waiting: Version Check"
    $script:LatestVersion = (Invoke-WebRequest $script:LatestVersionUrl).Content
    if($script:Version -ne $script:LatestVersion){
        Write-Warning "New version is available. ($script:LatestVersion)`nhttps://github.com/ShuheiUda/Get-SubscriptionDetails"
    }
    Write-Log "Success: Version Check" -Color Green

    # Module Check
    if(Test-Path "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"){
        Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"
    }
    if(Test-Path "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\ExpressRoute\ExpressRoute.psd1"){
        Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\ExpressRoute\ExpressRoute.psd1"
    }
}

# Get ASM Information
function Get-AsmInformation{
    Write-Log "Waiting: Get-AzureSubscription"
    $script:AzureSubscription = Get-AzureSubscription -Current
    Write-Log "Success: Get-AzureSubscription" -Color Green

    Write-Log "Waiting: Get-AzureService"
    $script:AzureService = Get-AzureService
    Write-Log "Success: Get-AzureService" -Color Green
    
    Write-Log "Waiting: Get-AzureVM"
    $script:AzureVM = Get-AzureVM
    Write-Log "Success: Get-AzureVM" -Color Green
    
    Write-Log "Waiting: Get-AzureVNetConfig"
    $script:AzureVNetConfig = [xml](Get-AzureVNetConfig).XMLConfiguration
    Write-Log "Success: Get-AzureVNetConfig" -Color Green
    
    Write-Log "Waiting: Get-AzureVirtualNetworkGateway"
    $script:AzureVirtualNetworkGateway = Get-AzureVirtualNetworkGateway
    Write-Log "Success: Get-AzureVirtualNetworkGateway" -Color Green
    
    Write-Log "Waiting: Get-AzureDedicatedCircuit"
    $script:AzureDedicatedCircuit = Get-AzureDedicatedCircuit
    Write-Log "Success: Get-AzureDedicatedCircuit" -Color Green

    Write-Log "Waiting: Get-AzureStorageAccount"
    $script:AzureStorageAccount = Get-AzureStorageAccount
    Write-Log "Success: Get-AzureStorageAccount" -Color Green
    
    Write-Log "Waiting: Get-AzureDisk"
    $script:AzureDisk = Get-AzureDisk
    Write-Log "Success: Get-AzureDisk" -Color Green
    
    Write-Log "Waiting: Get-AzureVMImage"
    $script:AzureVMImage = Get-AzureVMImage
    Write-Log "Success: Get-AzureVMImage" -Color Green
    
    Write-Log "Waiting: Get-AzureLocation"
    $script:AzureLocation = Get-AzureLocation
    Write-Log "Success: Get-AzureLocation" -Color Green
}

# Get ARM Information
function Get-ArmInformation{
    Write-Log "Waiting: Get-AzureRmContext"
    $script:AzureRmContext = Get-AzureRmContext
    Write-Log "Success: Get-AzureRmContext" -Color Green

    Write-Log "Waiting: Get-AzureRmResourceGroup"
    $script:AzureRmResourceGroup = Get-AzureRmResourceGroup
    Write-Log "Success: Get-AzureRmResourceGroup" -Color Green
    
    Write-Log "Waiting: Get-AzureRmVM"
    $script:AzureRmVM = Get-AzureRmVM
    Write-Log "Success: Get-AzureRmVM" -Color Green
    
    Write-Log "Waiting: Get-AzureRmAvailabilitySet"
    $script:AzureRmAvailabilitySet = Get-AzureRmResourceGroup | Get-AzureRmAvailabilitySet
    Write-Log "Success: Get-AzureRmAvailabilitySet" -Color Green
    
    Write-Log "Waiting: Get-AzureRmVirtualNetwork"
    $script:AzureRmVirtualNetwork = Get-AzureRmVirtualNetwork
    Write-Log "Success: Get-AzureRmVirtualNetwork" -Color Green
    
    Write-Log "Waiting: Get-AzureRmNetworkInterface"
    $script:AzureRmNetworkInterface = Get-AzureRmNetworkInterface
    Write-Log "Success: Get-AzureRmNetworkInterface" -Color Green

    Write-Log "Waiting: Get-AzureRmNetworkSecurityGroup"
    $script:AzureRmNetworkSecurityGroup = Get-AzureRmNetworkSecurityGroup
    Write-Log "Success: Get-AzureRmNetworkSecurityGroup" -Color Green

    Write-Log "Waiting: Get-AzureRmRouteTable"
    $script:AzureRmRouteTable = Get-AzureRmRouteTable
    Write-Log "Success: Get-AzureRmRouteTable" -Color Green

    Write-Log "Waiting: Get-AzureRmLoadBalancer"
    $script:AzureRmLoadBalancer = Get-AzureRmLoadBalancer
    Write-Log "Success: Get-AzureRmLoadBalancer" -Color Green
    
    Write-Log "Waiting: Get-AzureRmLocalNetworkGateway"
    $script:AzureRmLocalNetworkGateway = ($script:AzureRmResourceGroup | Get-AzureRmLocalNetworkGateway)
    Write-Log "Success: Get-AzureRmLocalNetworkGateway" -Color Green
    
    Write-Log "Waiting: Get-AzureRmVirtualNetworkGateway"
    $script:AzureRmVirtualNetworkGateway = ($script:AzureRmResourceGroup | Get-AzureRmVirtualNetworkGateway)
    Write-Log "Success: Get-AzureRmVirtualNetworkGateway" -Color Green
    
    #Write-Log "Waiting: Get-AzureRmVirtualNetworkGatewayConnection"
    #$script:AzureRmVirtualNetworkGatewayConnection = ($script:AzureRmResourceGroup | Get-AzureRmVirtualNetworkGatewayConnection)
    #Write-Log "Success: Get-AzureRmVirtualNetworkGatewayConnection" -Color Green
    
    Write-Log "Waiting: Get-AzureRmExpressRouteCircuit"
    $script:AzureRmExpressRouteCircuit = Get-AzureRmExpressRouteCircuit
    Write-Log "Success: Get-AzureRmExpressRouteCircuit" -Color Green

    Write-Log "Waiting: Get-AzureRmExpressRouteCircuitAuthorization"
    $script:AzureRmExpressRouteCircuitAuthorization = $script:AzureRmExpressRouteCircuit | Get-AzureRmExpressRouteCircuitAuthorization
    Write-Log "Success: Get-AzureRmExpressRouteCircuitAuthorization" -Color Green
    
    Write-Log "Waiting: Get-AzureRmApplicationGateway"
    $script:AzureRmApplicationGateway = Get-AzureRmApplicationGateway
    Write-Log "Success: Get-AzureRmApplicationGateway" -Color Green
    
    Write-Log "Waiting: Get-AzureRmPublicIpAddress"
    $script:AzureRmPublicIpAddress = Get-AzureRmPublicIpAddress
    Write-Log "Success: Get-AzureRmPublicIpAddress" -Color Green
    
    Write-Log "Waiting: Get-AzureRmDnsZone"
    $script:AzureRmDnsZone = Get-AzureRmDnsZone
    Write-Log "Success: Get-AzureRmDnsZone" -Color Green
    
    Write-Log "Waiting: Get-AzureRmStorageAccount"
    $script:AzureRmStorageAccount = Get-AzureRmStorageAccount
    Write-Log "Success: Get-AzureRmStorageAccount" -Color Green
    
    Write-Log "Waiting: Get-AzureRmRoleAssignment"
    $script:AzureRmRoleAssignment = Get-AzureRmRoleAssignment
    Write-Log "Success: Get-AzureRmRoleAssignment" -Color Green

    Write-Log "Waiting: Get-AzureRmRoleDefinition"
    $script:AzureRmRoleDefinition = Get-AzureRmRoleDefinition
    Write-Log "Success: Get-AzureRmRoleDefinition" -Color Green

    Write-Log "Waiting: Get-AzureRmResourceProvider"
    $script:AzureRmResourceProvider = Get-AzureRmResourceProvider -ListAvailable
    Write-Log "Success: Get-AzureRmResourceProvider" -Color Green

    Write-Log "Waiting: Get-AzureRmProviderFeature"
    $script:AzureRmProviderFeature = Get-AzureRmProviderFeature -ListAvailable
    Write-Log "Success: Get-AzureRmProviderFeature" -Color Green
    
    Write-Log "Waiting: Get-AzureRmLog"
    $script:AzureRmLog = Get-AzureRmLog -StartTime $script:ExecutedDate.AddDays(-14) -DetailedOutput
    Write-Log "Success: Get-AzureRmLog" -Color Green
    
    Write-Log "Waiting: Get-AzureRmLocation"
    $script:AzureRmLocation = Get-AzureRmLocation
    Write-Log "Success: Get-AzureRmLocation" -Color Green
}

# Create new html data
function Save-AzureReportHeader{
    $script:Report = New-HTMLHead -title "Get-SubscriptionDetails Report"
    $script:Report += "<h2>Get-SubscriptionDetails Report (Version: $script:Version)</h2>"
    $script:Report += "<h3>Subscription ID: $SubscriptionID ( Executed on : $script:ExecutedDateString )<br><a href=`"#CRP`">Virtual Machine</a> | <a href=`"#SRP`">Storage</a> | <a href=`"#NRP`">Network</a> | <a href=`"#Sub`">Subscription Information</a> | <a href=`"#Ops`">Operation</a></h3>"
}

function Save-AzureServiceTable{
    $script:AzureServiceTable = @()
    $script:AzureService | foreach{
         $script:AzureServiceDetail = [PSCustomObject]@{
            "ServiceName"                       = $_.ServiceName
            "Status"                            = $_.Status
            "Location"                          = $_.Location
            "Label"                             = $_.Label
            "Description"                       = $_.Description
            "AffinityGroup"                     = $_.AffinityGroup
            "DateCreated"                       = $_.DateCreated
            "DateModified"                      = $_.DateModified
            "ReverseDnsFqdn"                    = $_.ReverseDnsFqdn
            "WebWorkerRoleSizes"                = $_.WebWorkerRoleSizes -join "<br>"
            "VirtualMachineRoleSizes"           = $_.VirtualMachineRoleSizes -join "<br>"
        }
        $script:AzureServiceDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureServiceDetail) 

        $script:AzureServiceTable += [PSCustomObject]@{
            "ServiceName"                       = $_.ServiceName
            "Status"                            = $_.Status
            "Location"                          = $_.Location
            "AffinityGroup"                     = $_.AffinityGroup
            "Detail"                            = ConvertTo-DetailView -InputObject $script:AzureServiceDetailTable
        }
    }
    $script:Report += "<h3>ASM Cloud Service</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $AzureServiceTable)

}

function Save-AzureVmWindowsTable{
    $script:AzureVmWindows = $Script:AzureVM | where{$_.VM.OSVirtualHardDisk.OS -eq "Windows"}
    $script:AzureVmWindowsTable = @()
    $script:AzureVmWindows | foreach{
         $script:AzureVmWindowsDetail = [PSCustomObject]@{
            "Name"                              = $_.Name
            "HostName"                          = $_.HostName
            "Status"                            = $_.Status
            "InstanceStatus"                    = $_.InstanceStatus
            "PowerState"                        = $_.PowerState
            "GuestAgentStatus"                  = $_.GuestAgentStatus.Status
            "InstanceStateDetails"              = $_.InstanceStateDetails
            "InstanceUpgradeDomain"             = $_.InstanceUpgradeDomain
            "InstanceErrorCode"                 = $_.InstanceErrorCode
            "InstanceFaultDomain"               = $_.InstanceFaultDomain
            "InstanceSize"                      = $_.InstanceSize
            "ServiceName"                       = $_.ServiceName
            "DNSName"                           = $_.DNSName
            "DeploymentName"                    = $_.DeploymentName
            "AvailabilitySetName"               = $_.AvailabilitySetName
            "VirtualNetworkName"                = $_.VirtualNetworkName
            "SubnetNames"                       = $_.VM.ConfigurationSets.SubnetNames
            "IpAddress"                         = $_.IpAddress
            "PublicIPAddress"                   = $_.PublicIPAddress
            "PublicIPName"                      = $_.PublicIPName
            "PublicIPDomainNameLabel"           = $_.PublicIPDomainNameLabel
            "PublicIPFqdns"                     = $_.PublicIPFqdns
            "NetworkInterfaces"                 = $_.NetworkInterfaces.Name -join "<br>"
            "RemoteAccessCertificateThumbprint" = $_.RemoteAccessCertificateThumbprint
            "RDP EndPoint"                      = (($_.VM.ConfigurationSets.InputEndPoints | where{(($_.LocalPort -eq "3389") -and ($_.Protocol -eq "tcp")) -or (($_.Name -contains "Remote Desktop") -and ($_.Protocol -eq "tcp")) -or (($_.Name -contains "RDP") -and ($_.Protocol -eq "tcp"))})).Port
            "PowerShell EndPoint"               = (($_.VM.ConfigurationSets.InputEndPoints) | where{($_.LocalPort -eq "5986") -or ($_.Name -eq "PowerShell")}).Port
        }
        $script:AzureVmWindowsDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureVmWindowsDetail) 

        $script:AzureVmWindowsTable += [PSCustomObject]@{
            "Name"                              = $_.Name
            "HostName"                          = $_.HostName
            "Status"                            = $_.Status
            "InstanceStatus"                    = $_.InstanceStatus
            "PowerState"                        = $_.PowerState
            "InstanceSize"                      = $_.InstanceSize
            "ServiceName"                       = $_.ServiceName
            "DNSName"                           = $_.DNSName
            "AvailabilitySetName"               = $_.AvailabilitySetName
            "VirtualNetworkName"                = $_.VirtualNetworkName
            "SubnetNames"                       = $_.VM.ConfigurationSets.SubnetNames
            "IpAddress"                         = $_.IpAddress
            "PublicIPAddress"                   = $_.PublicIPAddress
            "RDP EndPoint"                      = (($_.VM.ConfigurationSets.InputEndPoints | where{(($_.LocalPort -eq "3389") -and ($_.Protocol -eq "tcp")) -or (($_.Name -contains "Remote Desktop") -and ($_.Protocol -eq "tcp")) -or (($_.Name -contains "RDP") -and ($_.Protocol -eq "tcp"))})).Port
            "PowerShell EndPoint"               = (($_.VM.ConfigurationSets.InputEndPoints) | where{($_.LocalPort -eq "5986") -or ($_.Name -eq "PowerShell")}).Port
            "Detail"                            = ConvertTo-DetailView -InputObject $script:AzureVmWindowsDetailTable
        }
    }
    $script:Report += "<h3>ASM Windows VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $AzureVmWindowsTable)
}

function Save-AzureVmLinuxTable{
    $script:AzureVmLinux = $Script:AzureVM | where{$_.VM.OSVirtualHardDisk.OS -eq "Linux"}
    $script:AzureVmLinuxTable = @()
    $AzureVmLinux | foreach{
         $script:AzureVmLinuxDetail = [PSCustomObject]@{
            "Name"                              = $_.Name
            "HostName"                          = $_.HostName
            "Status"                            = $_.Status
            "InstanceStatus"                    = $_.InstanceStatus
            "PowerState"                        = $_.PowerState
            "GuestAgentStatus"                  = $_.GuestAgentStatus.Status
            "InstanceStateDetails"              = $_.InstanceStateDetails
            "InstanceUpgradeDomain"             = $_.InstanceUpgradeDomain
            "InstanceErrorCode"                 = $_.InstanceErrorCode
            "InstanceFaultDomain"               = $_.InstanceFaultDomain
            "InstanceSize"                      = $_.InstanceSize
            "ServiceName"                       = $_.ServiceName
            "DNSName"                           = $_.DNSName
            "DeploymentName"                    = $_.DeploymentName
            "AvailabilitySetName"               = $_.AvailabilitySetName
            "VirtualNetworkName"                = $_.VirtualNetworkName
            "SubnetNames"                       = $_.VM.ConfigurationSets.SubnetNames
            "IpAddress"                         = $_.IpAddress
            "PublicIPAddress"                   = $_.PublicIPAddress
            "PublicIPName"                      = $_.PublicIPName
            "PublicIPDomainNameLabel"           = $_.PublicIPDomainNameLabel
            "PublicIPFqdns"                     = $_.PublicIPFqdns
            "NetworkInterfaces"                 = $_.NetworkInterfaces.Name -join "<br>"
            "RemoteAccessCertificateThumbprint" = $_.RemoteAccessCertificateThumbprint
            "SSH EndPoint"                      = (($_.VM.ConfigurationSets.InputEndPoints) | where{($_.LocalPort -eq "22") -or ($_.Name -eq "SSH")}).Port
        }
        $script:AzureVmLinuxDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureVmLinuxDetail) 

        $script:AzureVmLinuxTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "HostName"                  = $_.HostName
            "Status"                    = $_.Status
            "InstanceStatus"            = $_.InstanceStatus
            "PowerState"                = $_.PowerState
            "InstanceSize"              = $_.InstanceSize
            "ServiceName"               = $_.ServiceName
            "DNSName"                   = $_.DNSName
            "AvailabilitySetName"       = $_.AvailabilitySetName
            "VirtualNetworkName"        = $_.VirtualNetworkName
            "SubnetNames"               = $_.VM.ConfigurationSets.SubnetNames
            "IpAddress"                 = $_.IpAddress
            "PublicIPAddress"           = $_.PublicIPAddress
            "SSH EndPoint"              = (($_.VM.ConfigurationSets.InputEndPoints) | where{($_.LocalPort -eq "22") -or ($_.Name -eq "SSH")}).Port
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureVmLinuxDetailTable
         }
    }
    $script:Report += "<h3>ASM Linux VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $AzureVmLinuxTable)
}

function Save-AzureRmAvailabilitySetTable{
    $script:AzureRmAvailabilitySetTable = @()
    $script:AzureRmAvailabilitySet | foreach{
        $script:AzureRmAvailabilitySetDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Statuses"                  = $_.Statuses
            "Id"                        = $_.Id
            "Type"                      = $_.Type
            "FaultDomainCount"          = $_.PlatformFaultDomainCount
            "UpdateDomainCount"         = $_.PlatformUpdateDomainCount
            "VirtualMachineReferences"  = $_.VirtualMachinesReferences.id -join "<br>"
        }
        $script:AzureRmAvailabilitySetDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmAvailabilitySetDetail)
        $VirtualMachines = @()
        $_.VirtualMachinesReferences.Id | foreach{
            if($_ -match "/providers/Microsoft.Compute/virtualMachines/.{1,15}$"){
                $VirtualMachines += $Matches[0] -replace "/providers/Microsoft.Compute/virtualMachines/", ""
            }
        }
        $script:AzureRmAvailabilitySetTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "FaultDomainCount"          = $_.PlatformFaultDomainCount
            "UpdateDomainCount"         = $_.PlatformUpdateDomainCount
            "VirtualMachineReferences"  = $VirtualMachines -join ", "
            "Detail"                    = $script:AzureRmAvailabilitySetDetailTable
        }
    }
    $script:Report += "<h3>ARM Availability Sets</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmAvailabilitySetTable)
}

function Save-AzureRmVmWindowsTable{
    $script:AzureRmVmWindowsTable = @()
    $AzureRmVmWindows = $Script:AzureRmVm | where{$_.StorageProfile.OsDisk.OsType -eq "Windows"}
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
        
        $script:AzureRmVmWindowsDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "Id"                        = $_.Id
            "VmId"                      = $_.VmId
            "ProvisioningState"         = $_.ProvisioningState
            "StatusCode"                = $_.StatusCode
            "ComputerName"              = $_.OSProfile.ComputerName
            "AdminUsername"             = $_.OSProfile.AdminUsername
            "ProvisionVMAgent"          = $_.OSProfile.WindowsConfiguration.ProvisionVMAgent
            "OsType"                    = $_.StorageProfile.OsDisk.OsType
            "LicenseType"               = $_.LicenseType
            "VmSize"                    = $_.HardwareProfile.VmSize
            "AvailabilitySetReference"  = $_.AvailabilitySetReference.Id
            "NetworkInterfaceIDs"       = $_.NetworkInterfaceIDs
            "VirtualNetworkName"        = $VirtualNetwork
            "SubnetNames"               = $Subnet
            "PrivateIpAddress"          = $PrivateIpAddress
            "PublicIPAddress"           = $PublicIpAddress
            "NetworkSecurityGroup"      = $NetworkSecurityGroup
        }
        $script:AzureRmVmWindowsDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVmWindowsDetail) 

        $script:AzureRmVmWindowsTable += [PSCustomObject]@{
            "Name"                          = $_.Name
            "ComputerName"                  = $_.OSProfile.ComputerName
            "ResourceGroupName"             = $ResourceGroupName
            "ProvisioningState"             = $_.ProvisioningState
            "VmSize    "                    = $_.HardwareProfile.VmSize
            "AvailabilitySetName"           = $AvailabilitySet
            "VirtualNetworkName"            = $VirtualNetwork
            "SubnetNames"                   = $Subnet
            "PrivateIpAddress"              = $PrivateIpAddress
            "PublicIPAddress"               = $PublicIpAddress
            "NetworkSecurityGroup"          = $NetworkSecurityGroup
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmVmWindowsDetailTable
        }
    }
    $script:Report += "<h3>ARM Windows VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmVmWindowsTable)
}

function Save-AzureRmVmLinuxTable{
    $script:AzureRmVmLinuxTable = @()
    $AzureRmVmLinux = $Script:AzureRmVm | where{$_.StorageProfile.OsDisk.OsType -eq "Linux"}
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

        $script:AzureRmVmLinuxDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "VmId"                          = $_.VmId
            "ProvisioningState"             = $_.ProvisioningState
            "StatusCode"                    = $_.StatusCode
            "ComputerName"                  = $_.OSProfile.ComputerName
            "AdminUsername"                 = $_.OSProfile.AdminUsername
            "DisablePasswordAuthentication" = $_.OSProfile.LinuxConfiguration.DisablePasswordAuthentication
            "OsType"                        = $_.StorageProfile.OsDisk.OsType
            "LicenseType"                   = $_.LicenseType
            "VmSize"                        = $_.HardwareProfile.VmSize
            "AvailabilitySetReference"      = $_.AvailabilitySetReference.Id
            "NetworkInterfaceIDs"           = $_.NetworkInterfaceIDs
            "VirtualNetworkName"            = $VirtualNetwork
            "SubnetNames"                   = $Subnet
            "PrivateIpAddress"              = $PrivateIpAddress
            "PublicIPAddress"               = $PublicIpAddress
            "NetworkSecurityGroup"          = $NetworkSecurityGroup
        }
        $script:AzureRmVmLinuxDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVmLinuxDetail) 

        $script:AzureRmVmLinuxTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "computerName"              = $_.OSProfile.ComputerName
            "ResourceGroupName"         = $ResourceGroupName
            "ProvisioningState"         = $_.ProvisioningState
            "vmSize"                    = $_.HardwareProfile.VmSize
            "AvailabilitySetName"       = $AvailabilitySet
            "VirtualNetworkName"        = $VirtualNetwork
            "SubnetNames"               = $Subnet
            "PrivateIpAddress"          = $PrivateIpAddress
            "PublicIPAddress"           = $PublicIpAddress
            "NetworkSecurityGroup"      = $NetworkSecurityGroup
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVmLinuxDetailTable
        }
    }
    $script:Report += "<h3>ARM Linux VM</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmVmLinuxTable)
}

function Save-AzureStorageAccountTable{
    $script:AzureStorageAccountTable = @()
    $script:AzureStorageAccount | foreach{
        $script:AzureStorageAccountDetail = [PSCustomObject]@{
            "StorageAccountName"        = $_.StorageAccountName
            "Location"                  = $_.Location
            "StorageAccountStatus"      = $_.StorageAccountStatus
            "Label"                     = $_.Label
            "StorageAccountDescription" = $_.StorageAccountDescription
            "AccountType"               = $_.AccountType
            "LastGeoFailoverTime"       = $_.LastGeoFailoverTime
            "MigrationState"            = $_.MigrationState
            "GeoPrimaryLocation"        = $_.GeoPrimaryLocation
            "StatusOfPrimary"           = $_.StatusOfPrimary
            "GeoSecondaryLocation"      = $_.GeoSecondaryLocation
            "StatusOfSecondary"         = $_.StatusOfSecondary
            "Endpoints"                 = $_.Endpoints[0]
        }
        $script:AzureStorageAccountDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureStorageAccountDetail)

        $script:AzureStorageAccountTable += [PSCustomObject]@{
            "StorageAccountName"        = $_.StorageAccountName
            "Location"                  = $_.Location
            "AccountType"               = $_.AccountType
            "StatusOfPrimary"           = $_.StatusOfPrimary
            "GeoPrimaryLocation"        = $_.GeoPrimaryLocation
            "GeoSecondaryLocation"      = $_.GeoSecondaryLocation
            "Endpoints"                 = $_.Endpoints[0]
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureStorageAccountDetailTable
        }
    }
    $script:Report += "<h3>ASM StorageAccount</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureStorageAccountTable)
}

function Save-AzureDiskTable{
    $script:AzureDiskTable = @()
    $script:AzureDisk | foreach{
        $script:AzureDiskDetail = [PSCustomObject]@{
            "DiskName"                  = $_.DiskName
            "AttachedTo.RoleName"       = $_.AttachedTo.RoleName
            "Location"                  = $_.Location
            "OS"                        = $_.OS
            "Label"                     = $_.Label
            "IOType"                    = $_.IOType
            "DiskSizeInGB"              = $_.DiskSizeInGB
            "SourceImageName"           = $_.SourceImageName
            "MediaLink"                 = $_.MediaLink
            "IsCorrupted"               = $_.IsCorrupted
        }
        $script:AzureDiskDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureDiskDetail)

        $script:AzureDiskTable += [PSCustomObject]@{
            "DiskName"                  = $_.DiskName
            "AttachedTo.RoleName"       = $_.AttachedTo.RoleName
            "OS"                        = $_.OS
            "DiskSizeInGB"              = $_.DiskSizeInGB
            "SourceImageName"           = $_.SourceImageName
            "MediaLink"                 = $_.MediaLink
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureDiskDetailTable
        }
    }
    $script:Report += "<h3>ASM VM Disk</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureDiskTable)
}

function Save-AzureVMImageTable{
    $script:AzureVMImageTable = @()
    $script:AzureVMImage | where {$_.category -eq “User”} | foreach{
        $script:AzureVMImageDetail = [PSCustomObject]@{
            "ImageName"                 = $_.ImageName
            "Label"                     = $_.Label
            "Category"                  = $_.Category
            "ServiceName"               = $_.ServiceName
            "DeploymentName"            = $_.DeploymentName
            "RoleName"                  = $_.RoleName
            "OS"                        = $_.OS
            "LogicalDiskSizeInGB"       = $_.OSDiskConfiguration.LogicalDiskSizeInGB
            "MediaLink"                 = $_.OSDiskConfiguration.MediaLink
            "CreatedTime"               = $_.CreatedTime
            "ModifiedTime"              = $_.ModifiedTime
        }
        $script:AzureVMImageDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureVMImageDetail)

        $script:AzureVMImageTable += [PSCustomObject]@{
            "ImageName"                 = $_.ImageName
            "Label"                     = $_.Label
            "RoleName"                  = $_.RoleName
            "OS"                        = $_.OS
            "LogicalDiskSizeInGB"       = $_.OSDiskConfiguration.LogicalDiskSizeInGB
            "MediaLink"                 = $_.OSDiskConfiguration.MediaLink
            "CreatedTime"               = $_.CreatedTime
            "ModifiedTime"              = $_.ModifiedTime
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureVMImageDetailTable
        }
    }
    $script:Report += "<h3>ASM OS Image</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureVMImageTable)
}

function Save-AzureRmStorageAccountTable{
    $script:AzureRmStorageAccountTable = @()
    $script:AzureRmStorageAccount | foreach{
        $script:AzureRmStorageAccountDetail = [PSCustomObject]@{
            "StorageAccountName"            = $_.StorageAccountName
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Id"                            = $_.Id
            "ProvisioningState"             = $_.ProvisioningState
            "CreationTime"                  = $_.CreationTime
            "LastGeoFailoverTime"           = $_.LastGeoFailoverTime
            "CustomDomain"                  = $_.CustomDomain.Name
            "Sku"                           = $_.Sku.Name
            "Kind"                          = $_.Kind
            "AccessTier"                    = $_.AccessTier
            "Encryption"                    = $_.Encryption
            "PrimaryLocation"               = $_.PrimaryLocation
            "PrimaryEndpoints"              = $_.PrimaryEndpoints.Blob
            "StatusOfPrimary"               = $_.StatusOfPrimary
            "SecondaryLocation"             = $_.SecondaryLocation
            "SecondaryEndpoints"            = $_.SecondaryEndpoints.Blob
            "StatusOfSecondary"             = $_.StatusOfSecondary;            
        }
        $script:AzureRmStorageAccountDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmStorageAccountDetail) 

        $script:AzureRmStorageAccountTable += [PSCustomObject]@{
            "StorageAccountName"        = $_.StorageAccountName
            "ResourceGroupName"         = $_.ResourceGroupName
            "Sku"                       = $_.Sku.Name
            "StatusOfPrimary"           = $_.StatusOfPrimary
            "Location"                  = $_.Location
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmStorageAccountDetailTable
        }
    }
    $script:Report += "<h3>ARM StorageAccount</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmStorageAccountTable)
}

function Save-AzureRmVmDiskTable{
    $script:AzureRmVmDiskTable = @()
    $script:AzureRmVm | foreach{
        $VmName = $_.Name
        if($_.StorageProfile.OsDisk.Vhd.Uri -match "[a-z0-9]{3,24}.blob.core.windows.net/vhds/"){
            [string]$StorageAccountName = $Matches[0] -replace ".blob.core.windows.net/vhds/", ""
        }
        $script:AzureRmVmDiskDetail = [PSCustomObject]@{
            "Disk Name"                 = $_.StorageProfile.osDisk.name
            "Attached To"               = $VmName
            "Type"                      = "OS Disk"
            "StorageAccountName"        = $StorageAccountName
            "OS"                        = $_.StorageProfile.osDisk.osType
            "Publisher"                 = $_.StorageProfile.ImageReference.Publisher
            "Offer"                     = $_.StorageProfile.ImageReference.Offer
            "Sku"                       = $_.StorageProfile.ImageReference.Sku
            "DiskSizeInGB"              = $_.StorageProfile.osDisk.DiskSizeGB
            "Create Option"             = $_.StorageProfile.osDisk.CreateOption
            "MediaLink"                 = $_.StorageProfile.osDisk.vhd.uri
        }
        $script:AzureRmVmDiskDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVmDiskDetail)

        $script:AzureRmVmDiskTable += [PSCustomObject]@{
            "Disk Name"                 = $_.StorageProfile.osDisk.name
            "Attached To"               = $VmName
            "Type"                      = "OS Disk"
            "StorageAccountName"        = $StorageAccountName
            "OS"                        = $_.StorageProfile.osDisk.osType
            "Publisher"                 = $_.StorageProfile.ImageReference.Publisher
            "Offer"                     = $_.StorageProfile.ImageReference.Offer
            "Sku"                       = $_.StorageProfile.ImageReference.Sku
            "Create Option"             = $_.StorageProfile.osDisk.CreateOption
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVmDiskDetailTable
        }

        $_.StorageProfile.DataDisks | foreach{
            if($_ -ne $null){
                $null = $_.Vhd.Uri -match "[a-z0-9]{3,24}.blob.core.windows.net/vhds/"
                [string]$StorageAccountName = $Matches[0] -replace ".blob.core.windows.net/vhds/", ""
                $script:AzureRmVmDiskDetail = [PSCustomObject]@{
                    "Disk Name"                 = $_.Name
                    "Attached To"               = $VmName
                    "Type"                      = "Data Disk"
                    "StorageAccountName"        = $StorageAccountName
                    "OS"                        = "n/a"
                    "Publisher"                 = "n/a"
                    "Offer"                     = "n/a"
                    "Sku"                       = "n/a"
                    "DiskSizeInGB"              = $_.DiskSizeGB
                    "Create Option"             = $_.CreateOption
                    "MediaLink"                 = $_.vhd.Uri
                }
                $script:AzureRmVmDiskDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVmDiskDetail)

                $script:AzureRmVmDiskTable += [PSCustomObject]@{
                    "Disk Name"                 = $_.Name
                    "Attached To"               = $VmName
                    "Type"                      = "Data Disk"
                    "StorageAccountName"        = $StorageAccountName
                    "OS"                        = "n/a"
                    "Publisher"                 = "n/a"
                    "Offer"                     = "n/a"
                    "Sku"                       = "n/a"
                    "Create Option"             = $_.CreateOption
                    "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVmDiskDetailTable
                }
            }
        }
    }
    $script:Report += "<h3>ARM VM Disk</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $Script:AzureRmVmDiskTable)
}

function Save-AzureDnsServerTable{
    $script:AzureDnsServerTable = @()    
    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.dns.DnsServers.DnsServer | foreach{
        if($_.name -ne $null){
            $script:AzureDnsServerDetail = [PSCustomObject]@{
                "name"                      = $_.name
                "IPAddress"                 = $_.IPAddress
            }
            $script:AzureDnsServerDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureDnsServerDetail)

            $script:AzureDnsServerTable += [PSCustomObject]@{
                "name"                      = $_.name
                "IPAddress"                 = $_.IPAddress
                "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureDnsServerDetailTable
            }
        }
    }
    $script:Report += "<h3>ASM DNS Server</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureDnsServerTable)
}

function Save-AzureVirtualNetworkSiteTable{
    $script:AzureVirtualNetworkSiteTable = @()
    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.VirtualNetworkSites.VirtualNetworkSite | foreach{
        if($_.name -ne $null){
            $script:AzureVirtualNetworkSiteDetail = [PSCustomObject]@{
                "name"                      = $_.name
                "Location"                  = $_.Location
                "AddressSpace"              = $_.AddressSpace.AddressPrefix -join "<br>"
                "Subnets"                   = $_.Subnets.Subnet.AddressPrefix -join "<br>"
            }
            $script:AzureVirtualNetworkSiteDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureVirtualNetworkSiteDetail)

            $script:AzureVirtualNetworkSiteTable += [PSCustomObject]@{
                "name"                      = $_.name
                "Location"                  = $_.Location
                "AddressSpace"              = $_.AddressSpace.AddressPrefix -join ", "
                "Subnets"                   = $_.Subnets.Subnet.AddressPrefix -join ", "
                "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureVirtualNetworkSiteDetailTable
            }
        }
    }
    $script:Report += "<h3>ASM Virtual Network Sites</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureVirtualNetworkSiteTable)
}

function Save-AzureLocalNetworkSiteTable{
    $script:AzureLocalNetworkSiteTable = @()
    $script:AzureVNetConfig.NetworkConfiguration.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite | foreach{
        if($_.name -ne $null){
            $script:AzureLocalNetworkSiteDetail = [PSCustomObject]@{
                "name"                      = $_.name
                "AddressSpace"              = $_.AddressSpace.AddressPrefix
                "VPNGatewayAddress"         = $_.VPNGatewayAddress
            }
            $script:AzureLocalNetworkSiteDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureLocalNetworkSiteDetail)

            $script:AzureLocalNetworkSiteTable += [PSCustomObject]@{
                "name"                      = $_.name
                "AddressSpace"              = $_.AddressSpace.AddressPrefix
                "VPNGatewayAddress"         = $_.VPNGatewayAddress
                "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureLocalNetworkSiteDetailTable
            }
        }
    }
    $script:Report += "<h3>ASM Local Network Sites</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureLocalNetworkSiteTable)
}

function Save-AzureVirtualNetworkGatewayTable{
    $script:AzureVirtualNetworkGatewayTable = @()
    $script:AzureVirtualNetworkGateway | foreach{
        if($_.GatewayName -ne $null){
            $script:AzureVirtualNetworkGatewayDetail = [PSCustomObject]@{
                "GatewayName"               = $_.GatewayName
                "State"                     = $_.State
                "Location"                  = $_.Location
                "GatewayType"               = $_.GatewayType
                "GatewaySKU"                = $_.GatewaySKU
                "GatewayId"                 = $_.GatewayId
                "VnetId"                    = $_.VnetId
                "SubnetId"                  = $_.SubnetId
                "VIPAddress"                = $_.VIPAddress
                "LastEventTimeStamp"        = $_.LastEventTimeStamp
                "LastEventID"               = $_.LastEventID
                "LastEventMessage"          = $_.LastEventMessage
                "LastEventData"             = $_.LastEventData
                "DefaultSite"               = $_.DefaultSite
                "EnableBgp"                 = $_.EnableBgp
                "Asn"                       = $_.Asn
                "BgpPeeringAddress"         = $_.BgpPeeringAddress
                "PeerWeight"                = $_.PeerWeight
                "OperationId"               = $_.OperationId
                "OperationDescription"      = $_.OperationDescription
                "OperationStatus"           = $_.OperationStatus
            }
            $script:AzureVirtualNetworkGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureVirtualNetworkGatewayDetail)

            $script:AzureVirtualNetworkGatewayTable += [PSCustomObject]@{
                "GatewayName"               = $_.GatewayName
                "State"                     = $_.State
                "GatewayType"               = $_.GatewayType
                "GatewayId"                 = $_.GatewayId
                "VnetId"                    = $_.VnetId
                "VIPAddress"                = $_.VIPAddress
                "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureVirtualNetworkGatewayDetailTable
            }
        }
    }
    $script:Report += "<h3>ASM (+ ARM) Virtual Network Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureVirtualNetworkGatewayTable)
}

function Save-AzureDedicatedCircuitTable{
    $script:AzureDedicatedCircuitTable = @()
    $script:AzureDedicatedCircuit | foreach{
            if($_.CircuitName -ne $null){
                $script:AzureDedicatedCircuitDetail = [PSCustomObject]@{
                    "CircuitName"                       = $_.CircuitName
                    "ServiceKey"                        = $_.ServiceKey
                    "Location"                          = $_.Location
                    "Bandwidth"                         = $_.Bandwidth
                    "ServiceProviderName"               = $_.ServiceProviderName
                    "ServiceProviderProvisioningState"  = $_.ServiceProviderProvisioningState
                    "BillingType"                       = $_.BillingType
                    "Sku"                               = $_.Sku
                    "Status"                            = $_.Status
                }
                $script:AzureDedicatedCircuitDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureDedicatedCircuitDetail)
            }

        $script:AzureDedicatedCircuitTable += [PSCustomObject]@{
            "CircuitName"                       = $_.CircuitName
            "ServiceKey"                        = $_.ServiceKey
            "Location"                          = $_.Location
            "Bandwidth"                         = $_.Bandwidth
            "ServiceProviderName"               = $_.ServiceProviderName
            "ServiceProviderProvisioningState"  = $_.ServiceProviderProvisioningState
            "BillingType"                       = $_.BillingType
            "Sku"                               = $_.Sku
            "Status"                            = $_.Status
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureDedicatedCircuitDetailTable
        }
    }
    $script:Report += "<h3>ASM ExpressRoute Circuit</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureDedicatedCircuitTable)
}

function Save-AzureRmVirtualNetworkTable{
    $script:AzureRmVirtualNetworkTable = @()
    $script:AzureRmVirtualNetwork | foreach{
        $script:AzureRmVirtualNetworkSubnetsDetail = @()
        $_.Subnets | foreach{
            $script:AzureRmVirtualNetworkSubnetsDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "AddressPrefix"             = $_.AddressPrefix
                "ProvisioningState"         = $_.ProvisioningState
            }
            $script:AzureRmVirtualNetworkSubnetsDetailTable = New-HTMLTable -InputObject $script:AzureRmVirtualNetworkSubnetsDetail
        }
        
        $script:AzureRmVirtualNetworkPeering = Get-AzureRmVirtualNetworkPeering -VirtualNetworkName $_.Name -ResourceGroupName $_.ResourceGroupName

        $script:AzureRmVirtualNetworkPeeringsDetail = @()
        if($script:AzureRmVirtualNetworkPeering -ne $null){
            $script:AzureRmVirtualNetworkPeering | foreach{
                $script:AzureRmVirtualNetworkPeeringsDetail += [PSCustomObject]@{
                    "Name"                              = $_.Name
                    "ResourceGroupName"                 = $_.ResourceGroupName
                    "ProvisioningState"                 = $_.ProvisioningState
                    "PeeringState"                      = $_.PeeringState
                    "VirtualNetworkName"                = $_.VirtualNetworkName
                    "RemoteVirtualNetwork"              = $_.RemoteVirtualNetwork.Id -join "<br>"
                    "AllowVirtualNetworkAccess"         = $_.AllowVirtualNetworkAccess
                    "AllowForwardedTraffic"             = $_.AllowForwardedTraffic
                    "AllowGatewayTransit"               = $_.AllowGatewayTransit
                    "UseRemoteGateways"                 = $_.UseRemoteGateways
                    "RemoteGateways"                    = $_.RemoteGateways
                    "RemoteVirtualNetworkAddressSpace"  = $_.RemoteVirtualNetworkAddressSpace
                }
                $script:AzureRmVirtualNetworkPeeringsDetailTable = New-HTMLTable -InputObject $script:AzureRmVirtualNetworkPeeringsDetail
            }
        }

        $script:AzureRmVirtualNetworkDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "AddressSpace"              = $_.AddressSpace.AddressPrefixes -join "<br>"
            "Subnets"                   = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkSubnetsDetailTable
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
            "VirtualNetworkPeerings"    = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkPeeringsDetailTable
        }
        $script:AzureRmVirtualNetworkDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVirtualNetworkDetail)

        $script:AzureRmVirtualNetworkTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Address Space"             = $_.AddressSpace.AddressPrefixes -join ", "
            "Subnets"                   = $_.Subnets.AddressPrefix -join ", "
            "DnsServers"                = $_.DhcpOptions.DnsServers -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkDetailTable
        }
    }
    $script:Report += "<h3>ARM Virtual Network</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmVirtualNetworkTable)
}

function Save-AzureRmVirtualNetworkGatewayTable{
    $script:AzureRmVirtualNetworkGatewayTable = @()
    $script:AzureRmVirtualNetworkGateway | foreach{
        $script:AzureRmVirtualNetworkGatewayDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "Id"                            = $_.Id
            "ResourceGuid"                  = $_.ResourceGuid
            "GatewayType"                   = $_.GatewayType
            "VpnType"                       = $_.VpnType
            "ActiveActive"                  = $_.ActiveActive
            "GatewayDefaultSite"            = $_.GatewayDefaultSite.Id
            "Sku"                           = $_.Sku.Name
            "VpnClientAddressPool"          = $_.VpnClientConfiguration.VpnClientAddressPool.AddressPrefixes
            "VpnClientRevokedCertificates"  = $_.VpnClientConfiguration.VpnClientRevokedCertificates.Name -join "<br>"
            "VpnClientRootCertificates"     = $_.VpnClientConfiguration.VpnClientRootCertificates.Name -join "<br>"
            "EnableBgp"                     = $_.EnableBgp
            "Asn"                           = $_.BgpSettings.Asn
            "BgpPeeringAddress"             = $_.BgpSettings.BgpPeeringAddress
            "PeerWeight"                    = $_.BgpSettings.PeerWeight
        }
        $script:AzureRmVirtualNetworkGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVirtualNetworkGatewayDetail)

        $script:AzureRmVirtualNetworkGatewayTable += [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "GatewayType"                   = $_.GatewayType
            "VpnType"                       = $_.VpnType
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmVirtualNetworkGatewayDetailTable
        }
    }
    $script:Report += "<h3>ARM Virtual Network Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmVirtualNetworkGatewayTable)
}

function Save-AzureRmExpressRouteCircuitTable{
    $script:AzureRmExpressRouteCircuitTable = @()
    $script:AzureRmExpressRouteCircuit | foreach{
        $script:AzureRmExpressRouteCircuitPeeringsDetail = @()
        $_.Peerings | foreach{
            $script:AzureRmExpressRouteCircuitPeeringsDetail += [PSCustomObject]@{
                "Name"                              = $_.Name
                "ProvisioningState"                 = $_.ProvisioningState
                "PeeringType"                       = $_.PeeringType
                "AzureASN"                          = $_.AzureASN
                "PeerASN"                           = $_.PeerASN
                "PrimaryPeerAddressPrefix"          = $_.PrimaryPeerAddressPrefix
                "SecondaryPeerAddressPrefix"        = $_.SecondaryPeerAddressPrefix
                "PrimaryAzurePort"                  = $_.PrimaryAzurePort
                "SecondaryAzurePort"                = $_.SecondaryAzurePort
                "SharedKey"                         = $_.SharedKey
                "VlanId"                            = $_.VlanId
                "MicrosoftPeeringConfig"            = $_.MicrosoftPeeringConfig
                "LastModifiedBy"                    = $_.LastModifiedBy
            }
        }
        $script:AzureRmExpressRouteCircuitPeeringsDetailTable = New-HTMLTable -InputObject $script:AzureRmExpressRouteCircuitPeeringsDetail

        $script:AzureRmExpressRouteCircuitDetail = [PSCustomObject]@{
            "Name"                              = $_.Name
            "ResourceGroupName"                 = $_.ResourceGroupName
            "ServiceKey"                        = $_.ServiceKey
            "Location"                          = $_.Location
            "ProvisioningState"                 = $_.ProvisioningState
            "CircuitProvisioningState"          = $_.CircuitProvisioningState
            "Id"                                = $_.Id
            "Sku"                               = $_.Sku.Name
            "ServiceProviderName"               = $_.ServiceProviderProperties.ServiceProviderName
            "ServiceProviderProvisioningState"  = $_.ServiceProviderProvisioningState
            "PeeringLocation"                   = $_.ServiceProviderProperties.PeeringLocation
            "BandwidthInMbps"                   = $_.ServiceProviderProperties.BandwidthInMbps
            "AllowClassicOperations"            = $_.AllowClassicOperations
            "Peerings"                          = ConvertTo-DetailView -InputObject $script:AzureRmExpressRouteCircuitPeeringsDetailTable
        }
        $script:AzureRmExpressRouteCircuitDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmExpressRouteCircuitDetail)

        $script:AzureRmExpressRouteCircuitTable += [PSCustomObject]@{
            "Name"                              = $_.Name
            "ResourceGroupName"                 = $_.ResourceGroupName
            "ServiceKey"                        = $_.ServiceKey
            "Location"                          = $_.Location
            "ProvisioningState"                 = $_.ProvisioningState
            "CircuitProvisioningState"          = $_.CircuitProvisioningState
            "Sku"                               = $_.Sku.Name
            "ServiceProviderName"               = $_.ServiceProviderProperties.ServiceProviderName
            "PeeringLocation"                   = $_.ServiceProviderProperties.PeeringLocation
            "BandwidthInMbps"                   = $_.ServiceProviderProperties.BandwidthInMbps
            "AllowClassicOperations"            = $_.AllowClassicOperations
            "Detail"                            = ConvertTo-DetailView -InputObject $script:AzureRmExpressRouteCircuitDetailTable
        }
    }
    $script:Report += "<h3>ARM ExpressRoute Circuit</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmExpressRouteCircuitTable)
}

function Save-AzureRmExpressRouteCircuitAuthorizationTable{
    $script:AzureRmExpressRouteCircuitAuthorizationTable = @()
    $script:AzureRmExpressRouteCircuitAuthorization | foreach{
        if($_.Id -match "/providers/Microsoft.Network/expressRouteCircuits/.{1,80}/authorizations/"){
            $Circuit = $Matches[0] -replace "/providers/Microsoft.Network/expressRouteCircuits/", "" -replace "/authorizations/", ""
        }
        $script:AzureRmExpressRouteCircuitAuthorizationDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "Circuit"                   = $_.Id
            "AuthorizationKey"          = $_.AuthorizationKey
            "AuthorizationUseStatus"    = $_.AuthorizationUseStatus
            "ProvisioningState"         = $_.ProvisioningState
        }
        $script:AzureRmExpressRouteCircuitAuthorizationDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmExpressRouteCircuitAuthorizationDetail)

        $script:AzureRmExpressRouteCircuitAuthorizationTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "Circuit"                   = $Circuit
            "AuthorizationKey"          = $_.AuthorizationKey
            "AuthorizationUseStatus"    = $_.AuthorizationUseStatus
            "ProvisioningState"         = $_.ProvisioningState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmExpressRouteCircuitAuthorizationDetailTable
        }
    }
    $script:Report += "<h3>ARM ExpressRoute Circuit Authorization</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmExpressRouteCircuitAuthorizationTable)
}

function Save-AzureRmNetworkInterfaceTable{
    $script:AzureRmNetworkInterfaceTable = @()
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

        $script:AzureRmNetworkInterfaceDetail = [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "ProvisioningState"             = $_.ProvisioningState
            "Id"                            = $_.Id
            "ResourceGuid"                  = $_.ResourceGuid
            "Virtual Machine"               = $_.VirtualMachine.Id
            "VirtualNetwork"                = $VirtualNetwork
            "Subnet"                        = $Subnet
            "PrivateIpAddress"              = $_.IpConfigurations.PrivateIpAddress
            "PrivateIpAllocationMethod"     = $_.IpConfigurations.PrivateIpAllocationMethod
            "CustomeDnsSettings"            = $_.DnsSettings.DnsServers -join "<br>"
            "NetworkSecurityGroup"          = $_.NetworkSecurityGroup.Id
            "EnableIPForwarding"            = $_.EnableIPForwarding
            "EnableAcceleratedNetworking"   = $_.EnableAcceleratedNetworking
            "Primary"                       = $_.Primary
        }
        $script:AzureRmNetworkInterfaceDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmNetworkInterfaceDetail)

        $script:AzureRmNetworkInterfaceTable += [PSCustomObject]@{
            "Name"                          = $_.Name
            "ResourceGroupName"             = $_.ResourceGroupName
            "Location"                      = $_.Location
            "Virtual Machine"               = $VirtualMachine
            "VirtualNetwork"                = $VirtualNetwork
            "Subnet"                        = $Subnet
            "PrivateIpAddress"              = $_.IpConfigurations.PrivateIpAddress
            "PrivateIpAllocationMethod"     = $_.IpConfigurations.PrivateIpAllocationMethod
            "CustomeDnsSettings"            = $_.DnsSettings.DnsServers -join ", "
            "NetworkSecurityGroup"          = $NetworkSecurityGroup
            "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureRmNetworkInterfaceDetailTable
        }
    }
    $script:Report += "<h3>ARM Network Interface</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmNetworkInterfaceTable)
}

function Save-AzureRmNetworkSecurityGroupTable{
    $script:AzureRmNetworkSecurityGroupTable = @()
    $script:AzureRmNetworkSecurityGroup | foreach{
        $script:AzureRmNetworkSecurityGroupSecurityRulesDetail = @()
        $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetail = @()
        $NetworkInterfaces = @()
        $Subnets = @()
        $VirtualNetwork = $null
        $_.NetworkInterfaces | foreach{
            if($_.Id -match "/providers/Microsoft.Network/networkInterfaces/.{1,80}$"){
                $NetworkInterfaces += $Matches[0] -replace "/providers/Microsoft.Network/networkInterfaces/", ""
            }
        }
        $_.Subnets | foreach{
            if($_.Id -match "/providers/Microsoft.Network/virtualNetworks/.{1,80}/subnets/.{1,80}$"){
                $TempSubnetId = $Subnet = $Matches[0] -split "/"
                $VirtualNetwork = $TempSubnetId[4]
                $Subnet = $TempSubnetId[6]
                $Subnets += "$Subnet ($VirtualNetwork)"
            }
        }
        if($_.SecurityRules -ne $null){
            $_.SecurityRules | foreach{
                $script:AzureRmNetworkSecurityGroupSecurityRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Access"                    = $_.Access
                    "Direction"                 = $_.Direction
                    "Priority"                  = $_.Priority
                    "Protocol"                  = $_.Protocol
                    "SourceAddressPrefix"       = $_.SourceAddressPrefix
                    "SourcePortRange"           = $_.SourcePortRange
                    "DestinationAddressPrefix"  = $_.DestinationAddressPrefix
                    "DestinationPortRange"      = $_.DestinationPortRange
                }
            }
        $script:AzureRmNetworkSecurityGroupSecurityRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmNetworkSecurityGroupSecurityRulesDetail
        }
        
        if($_.DefaultSecurityRules -ne $null){
            $_.DefaultSecurityRules | foreach{
                $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Access"                    = $_.Access
                    "Direction"                 = $_.Direction
                    "Priority"                  = $_.Priority
                    "Protocol"                  = $_.Protocol
                    "SourceAddressPrefix"       = $_.SourceAddressPrefix
                    "SourcePortRange"           = $_.SourcePortRange
                    "DestinationAddressPrefix"  = $_.DestinationAddressPrefix
                    "DestinationPortRange"      = $_.DestinationPortRange
                }
            }
        $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetail
        }

        $script:AzureRmNetworkSecurityGroupDetail = [PSCustomObject]@{
        "Name"                      = $_.Name
        "ResourceGroupName"         = $_.ResourceGroupName
        "Location"                  = $_.Location
        "Id"                        = $_.Id
        "ResourceGuid"              = $_.ResourceGuid
        "ProvisioningState"         = $_.ProvisioningState
        "NetworkInterfaces"         = $_.NetworkInterfaces -join "<br>"
        "Subnets"                   = $_.Subnets -join "<br>"
        "SecurityRules"             = ConvertTo-DetailView -InputObject $script:AzureRmNetworkSecurityGroupSecurityRulesDetailTable
        "DefaultSecurityRules"      = ConvertTo-DetailView -InputObject $script:AzureRmNetworkSecurityGroupDefaultSecurityRulesDetailTable
        }
        $script:AzureRmNetworkSecurityGroupDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmNetworkSecurityGroupDetail)

        $script:AzureRmNetworkSecurityGroupTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "NetworkInterfaces"         = $NetworkInterfaces -join ", "
            "Subnets"                   = $Subnets -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmNetworkSecurityGroupDetailTable
        }
    }
    $script:Report += "<h3>ARM Network Security Group</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmNetworkSecurityGroupTable)
}


function Save-AzureRmRouteTableTable{
    $script:AzureRmRouteTableTable= @()
    $script:AzureRmRouteTable | foreach{
        $script:AzureRmRouteTableRoutesDetail = @()
        if($_.Routes -ne $null){
            $_.Routes | foreach{
                $script:AzureRmRouteTableRoutesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "AddressPrefix"             = $_.AddressPrefix
                    "NextHopType"               = $_.NextHopType
                    "NextHopIpAddress"          = $_.NextHopIpAddress
                }
            }
        $script:AzureRmRouteTableRoutesDetailTable = New-HTMLTable -InputObject $script:AzureRmRouteTableRoutesDetail
        }

        $script:AzureRmRouteTableDetail = [PSCustomObject]@{
        "Name"                      = $_.Name
        "ResourceGroupName"         = $_.ResourceGroupName
        "Location"                  = $_.Location
        "Id"                        = $_.Id
        "ProvisioningState"         = $_.ProvisioningState
        "Routes"                    = ConvertTo-DetailView -InputObject $script:AzureRmRouteTableRoutesDetailTable
        "Subnets"                   = $_.Subnets.Id -join "<br>"
        }
        $script:AzureRmRouteTableDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRouteTableDetail)

        $script:AzureRmRouteTableTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Routes"                    = $_.Routes.Name -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmRouteTableDetailTable
        }
    }
    $script:Report += "<h3>ARM Route Table</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmRouteTableTable)
}

function Save-AzureRmLoadBalancerTable{
    $script:AzureRmLoadBalancerTable = @()
    $script:AzureRmLoadBalancer | foreach{
        $script:AzureRmLoadBalancerFrontendIpConfigurationsDetail = @()
        $script:AzureRmLoadBalancerBackendAddressPoolsDetail = @()
        $script:AzureRmLoadBalancerLoadBalancingRulesDetail = @()
        $script:AzureRmLoadBalancerProbesDetail = @()
        $script:AzureRmLoadBalancerInboundNatRulesDetail = @()
        $script:AzureRmLoadBalancerInboundNatPoolsDetail = @()

        if($_.FrontendIpConfigurations -ne $null){
            $_.FrontendIpConfigurations | foreach{
                $script:AzureRmLoadBalancerFrontendIpConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "PrivateIpAllocationMethod" = $_.PrivateIpAllocationMethod
                    "ProvisioningState"         = $_.ProvisioningState
                    "PublicIpAddress"           = $_.PublicIpAddress
                }
            }
            $script:AzureRmLoadBalancerFrontendIpConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerFrontendIpConfigurationsDetail
        }

        if($_.BackendAddressPools -ne $null){
            $_.BackendAddressPools | foreach{
                $script:AzureRmLoadBalancerBackendAddressPoolsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "BackendIpConfigurations"   = $_.BackendIpConfigurations.Id -join "<br>"
                }
            }
            $script:AzureRmLoadBalancerBackendAddressPoolsDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerBackendAddressPoolsDetail
        }
        
        if($_.InboundNatPools -ne $null){
            $_.InboundNatPools | foreach{
                $script:AzureRmLoadBalancerInboundNatPoolsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPortRangeStart"    = $_.FrontendPortRangeStart
                    "FrontendPortRangeEnd"      = $_.FrontendPortRangeEnd
                    "BackendPort"               = $_.BackendPort
                    "Capacity"                  = $_.Capacity
                }
            }
            $script:AzureRmLoadBalancerDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerInboundNatPoolsDetail
        }

        if($_.Probes -ne $null){
            $_.Probes | foreach{
                $script:AzureRmLoadBalancerProbesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "Port"                      = $_.Port
                    "IntervalInSeconds"         = $_.IntervalInSeconds
                    "NumberOfProbes"            = $_.NumberOfProbes
                    "RequestPath"               = $_.RequestPath
                }
            }
            $script:AzureRmLoadBalancerProbesDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerProbesDetail
        }

        if($_.LoadBalancingRules -ne $null){
            $_.LoadBalancingRules | foreach{
                $script:AzureRmLoadBalancerLoadBalancingRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPort"              = $_.FrontendPort
                    "BackendPort"               = $_.BackendPort
                    "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
                    "EnableFloatingIP"          = $_.EnableFloatingIP
                }
            }
            $script:AzureRmLoadBalancerLoadBalancingRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerLoadBalancingRulesDetail
        }
        
        if($_.InboundNatRules -ne $null){
            $_.InboundNatRules | foreach{
                $script:AzureRmLoadBalancerInboundNatRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Protocol"                  = $_.Protocol
                    "FrontendPort"              = $_.FrontendPort
                    "BackendPort"               = $_.BackendPort
                    "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
                    "EnableFloatingIP"          = $_.EnableFloatingIP
                }
            }
            $script:AzureRmLoadBalancerInboundNatRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmLoadBalancerInboundNatRulesDetail
        }

        $script:AzureRmLoadBalancerDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "FrontendIpConfigurations"  = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerFrontendIpConfigurationsDetailTable
            "BackendAddresspools"       = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerBackendAddressPoolsDetailTable
            "InboundNatPools"           = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerInboundNatPoolsDetailTable
            "Probes"                    = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerProbesDetailTable
            "LoadBalancingRules"        = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerLoadBalancingRulesDetailv
            "InboundNatRules"           = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerInboundNatRulesDetailTable
        }
        $script:AzureRmLoadBalancerDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmLoadBalancerDetail)

        $script:AzureRmLoadBalancerTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "FrontendIpConfigurations"  = $_.FrontendIpConfigurations.Name -join ", "
            "BackendAddresspools"       = $_.BackendAddressPools.Name -join ", "
            "InboundNatPools"           = $_.InboundNatPools.Name -join ", "
            "Probes"                    = $_.Probes.Name -join ", "
            "LoadBalancingRules"        = $_.LoadBalancingRules.Name -join ", "
            "InboundNatRules"           = $_.InboundNatRules.Name -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmLoadBalancerDetailTable

        }
    }
    $script:Report += "<h3>ARM Load Balancer</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmLoadBalancerTable)
}

function Save-AzureRmPublicIpAddressTable{
    $script:AzureRmPublicIpAddressTable = @()
    $script:AzureRmPublicIpAddress | foreach{
        $script:AzureRmPublicIpAddressDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "PublicIpAllocationMethod"  = $_.PublicIpAllocationMethod
            "IpAddress"                 = $_.IpAddress
            "PublicIpAddressVersion"    = $_.PublicIpAddressVersion
            "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
            "IpConfiguration"           = $_.IpConfiguration.Id
            "DomainNameLabel"           = $_.DnsSettings.DomainNameLabel -join "<br>"
            "Fqdn"                      = $_.DnsSettings.Fqdn -join "<br>"
            "ReverseFqdn"               = $_.DnsSettings.ReverseFqdn -join "<br>"
        }
        $script:AzureRmPublicIpAddressDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmPublicIpAddressDetail)

        $script:AzureRmPublicIpAddressTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "PublicIpAllocationMethod"  = $_.PublicIpAllocationMethod
            "IpAddress"                 = $_.IpAddress
            "IdleTimeoutInMinutes"      = $_.IdleTimeoutInMinutes
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmPublicIpAddressDetailTable
        }
    }
    $script:Report += "<h3>ARM Public IP Address</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmPublicIpAddressTable)
}

function Save-AzureRmLocalNetworkGatewayTable{
    $script:AzureRmLocalNetworkGatewayTable = @()
    $script:AzureRmLocalNetworkGateway | foreach{
        $script:AzureRmLocalNetworkGatewayDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "GatewayIpAddress"          = $_.GatewayIpAddress
            "LocalNetworkAddressSpace"  = $_.LocalNetworkAddressSpace.AddressPrefixes -join "<br>"
            "Asn"                       = $_.BgpSettings.Asn
            "BgpPeeringAddress"         = $_.BgpSettings.BgpPeeringAddress
            "PeerWeight"                = $_.BgpSettings.PeerWeight
        }
        $script:AzureRmLocalNetworkGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmLocalNetworkGatewayDetail)

        $script:AzureRmLocalNetworkGatewayTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "GatewayIpAddress"          = $_.GatewayIpAddress
            "LocalNetworkAddressSpace"  = $_.LocalNetworkAddressSpace.AddressPrefixes -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmLocalNetworkGatewayDetailTable
        }
    }
    $script:Report += "<h3>ARM Local Network Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmLocalNetworkGatewayTable)
}

function Save-AzureRmApplicationGatewayTable{
    $script:AzureRmApplicationGatewayTable = @()
    $script:AzureRmApplicationGateway | foreach{
        if($_.FrontendIPConfigurations.publicIPAddress.Id -match "/providers/Microsoft.Network/publicIPAddresses/[a-zA-Z0-9_.-]{1,80}$"){
            $FrontendPublicIPAddress = $Matches[0] -replace "/providers/Microsoft.Network/publicIPAddresses/", ""
        }
        
        $script:AzureRmApplicationGatewayAuthenticationCertificatesDetail = @()
        if($_.AuthenticationCertificates -ne $null){
            $_.AuthenticationCertificates | foreach{
                $script:AzureRmApplicationGatewayAuthenticationCertificatesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                }
            }
            $script:AzureRmApplicationGatewayAuthenticationCertificatesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayAuthenticationCertificatesDetail
        }
        
        $script:AzureRmApplicationGatewaySslCertificatesDetail = @()
        if($_.SslCertificates -ne $null){
            $_.SslCertificates | foreach{
                $script:AzureRmApplicationGatewaySslCertificatesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "PublicCertData"            = $_.PublicCertData
                }
            }
            $script:AzureRmApplicationGatewaySslCertificatesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewaySslCertificatesDetail
        }
        
        $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetail = @()
        if($_.GatewayIPConfigurations -ne $null){
            $_.GatewayIPConfigurations | foreach{
                $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Subnet"                    = $_.Subnet.Id
                }
            }
            $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetail
        }
        
        $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetail = @()
        if($_.FrontendIPConfigurations -ne $null){
            $_.FrontendIPConfigurations | foreach{
                $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "PrivateIPAddress"          = $_.PrivateIPAddress
                    "PublicIPAddress"           = $_.PublicIPAddress.Id
                    "PrivateIPAllocationMethod" = $_.PrivateIPAllocationMethod
                    "Subnet"                    = $_.Subnet
                }
            }
            $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetail
        }
        
        $script:AzureRmApplicationGatewayFrontendPortsDetail = @()
        if($_.FrontendPorts -ne $null){
            $_.FrontendPorts | foreach{
                $script:AzureRmApplicationGatewayFrontendPortsDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Port"                      = $_.Port
                }
            }
            $script:AzureRmApplicationGatewayFrontendPortsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayFrontendPortsDetail
        }
        
        $script:AzureRmApplicationGatewayProbesDetail = @()
        if($_.Probes -ne $null){
            $_.Probes | foreach{
                $script:AzureRmApplicationGatewayProbesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "Host"                      = $_.Host
                    "Interval"                  = $_.Interval
                    "Path"                      = $_.Path
                    "Protocol"                  = $_.Protocol
                    "Timeout"                   = $_.Timeout
                    "UnhealthyThreshold"        = $_.UnhealthyThreshold
                }
            }
            $script:AzureRmApplicationGatewayProbesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayProbesDetail
        }
        
        $script:AzureRmApplicationGatewayHttpListenersDetail = @()
        if($_.HttpListeners -ne $null){
            $_.HttpListeners | foreach{
                $script:AzureRmApplicationGatewayHttpListenersDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "HostName"                      = $_.HostName
                    "Protocol"                      = $_.Protocol
                    "RequireServerNameIndication"   = $_.RequireServerNameIndication
                }
            }
            $script:AzureRmApplicationGatewayHttpListenersDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayHttpListenersDetail
        }

        $script:AzureRmApplicationGatewayUrlPathMapsDetail = @()
        if($_.UrlPathMaps -ne $null){
            $_.UrlPathMaps | foreach{
                $script:AzureRmApplicationGatewayUrlPathMapsDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "PathRules"                     = $_.PathRules
                }
            }
            $script:AzureRmApplicationGatewayUrlPathMapsDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayUrlPathMapsDetail
        }

        $script:AzureRmApplicationGatewayRequestRoutingRulesDetail = @()
        if($_.RequestRoutingRules -ne $null){
            $_.RequestRoutingRules | foreach{
                $script:AzureRmApplicationGatewayRequestRoutingRulesDetail += [PSCustomObject]@{
                    "Name"                      = $_.Name
                    "ProvisioningState"         = $_.ProvisioningState
                    "RuleType"                  = $_.RuleType
                }
            }
            $script:AzureRmApplicationGatewayRequestRoutingRulesDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayRequestRoutingRulesDetail
        }
        
        $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetail = @()
        if($_.BackendHttpSettingsCollection -ne $null){
            $_.BackendHttpSettingsCollection | foreach{
                $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetail += [PSCustomObject]@{
                    "Name"                          = $_.Name
                    "ProvisioningState"             = $_.ProvisioningState
                    "CookieBasedAffinity"           = $_.CookieBasedAffinity
                    "Port"                          = $_.Port
                    "Probe"                         = $_.Probe
                    "Protocol"                      = $_.Protocol
                    "RequestTimeout"                = $_.RequestTimeout
                }
            }
            $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetail
        }

        $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetail = @()
        if($_.WebApplicationFirewallConfiguration -ne $null){
            $_.WebApplicationFirewallConfiguration | foreach{
                $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetail += [PSCustomObject]@{
                    "Enabled"                   = $_.Enabled
                    "FirewallMode"              = $_.FirewallMode
                }
            }
            $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetailTable = New-HTMLTable -InputObject $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetail
        }
        
        $script:AzureRmApplicationGatewayDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "OperationalState"          = $_.OperationalState
            "Id"                        = $_.Id
            "ResourceGuid"              = $_.ResourceGuid
            "Sku"                       = $_.Sku.Name
            "Capacity"                  = $_.Sku.Capacity
            "SslPolicy"                 = $_.SslPolicy
            "AuthenticationCertificates"= ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayAuthenticationCertificatesDetailTable
            "SslCertificates"           = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewaySslCertificatesDetailTable
            "GatewayIPConfigurations"   = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayGatewayIPConfigurationsDetailTable
            "FrontendIPConfigurations"  = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayFrontendIPConfigurationsDetailTable
            "FrontendPublicIPAddress"   = ($script:AzureRmPublicIpAddressTable | where {($_.Name -eq $FrontendPublicIPAddress)}).IpAddress
            "FrontendPorts"             = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayFrontendPortsDetailTable
            "Probes"                    = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayProbesDetailTable
            "HttpListeners"             = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayHttpListenersDetailTable
            "UrlPathMaps"               = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayUrlPathMapsDetailTable
            "RequestRoutingRules"       = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayRequestRoutingRulesDetailTable
            "BackendAddressPools"       = $_.BackendAddressPools.BackendAddresses.IpAddress -join "<br>"
            "BackendHttpSettingsCollection" = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayBackendHttpSettingsCollectionDetailTable
            "WebApplicationFirewallConfiguration" = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayWebApplicationFirewallConfigurationDetailTable
        }
        $script:AzureRmApplicationGatewayDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmApplicationGatewayDetail)

        $script:AzureRmApplicationGatewayTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "Location"                  = $_.Location
            "ProvisioningState"         = $_.ProvisioningState
            "Sku"                       = $_.Sku.Name
            "Capacity"                  = $_.Sku.Capacity
            "FrontendPrivateIPAddress"  = $_.FrontendIPConfigurations.PrivateIPAddress
            "FrontendPublicIPAddress"   = ($script:AzureRmPublicIpAddressTable | where {($_.Name -eq $FrontendPublicIPAddress)}).IpAddress
            "BackendAddressPools"       = $_.BackendAddressPools.BackendAddresses.IpAddress -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmApplicationGatewayDetailTable
        }
    }
    $script:Report += "<h3>ARM Application Gateway</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmApplicationGatewayTable)
}

function Save-AzureRmDnsZoneTable{
    $script:AzureRmDnsZoneTable = @()
    $script:AzureRmDnsZone | foreach{
        $script:AzureRmDnsRecordSet = $null
        $script:AzureRmDnsRecordSet = Get-AzureRmDnsRecordSet -ZoneName $_.Name -ResourceGroupName $_.ResourceGroupName
        $script:AzureRmDnsRecordSetDetail = @()
        $script:AzureRmDnsRecordSet | foreach{
            $script:AzureRmDnsRecordSetDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "ZoneName"                  = $_.ZoneName
                "RecordType"                = $_.RecordType
                "Ttl"                       = $_.Ttl
                "Records"                   = $_.Records -join ("<br>")
            }
        }
        $script:AzureRmDnsRecordSetDetailTable = New-HTMLTable -InputObject $script:AzureRmDnsRecordSetDetail

        $script:AzureRmDnsZoneDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "NameServers"               = $_.NameServers -join "<br>"
            "NumberOfRecordSets"        = "$($_.NumberOfRecordSets) / $($_.MaxNumberOfRecordSets)"
            "RecordSet"                 = ConvertTo-DetailView -InputObject $script:AzureRmDnsRecordSetDetailTable
        }
        $script:AzureRmDnsZoneDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmDnsZoneDetail)

        $script:AzureRmDnsZoneTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "NameServers"               = $_.NameServers -join ", "
            "NumberOfRecordSets"        = "$($_.NumberOfRecordSets) / $($_.MaxNumberOfRecordSets)"
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmDnsZoneDetailTable
        }
    }
    $script:Report += "<h3>ARM DNS Zones</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmDnsZoneTable)
}

function Save-AzureSubscriptionAccountsTable{
    $script:AzureSubscriptionAccountsDetail = @()
    $script:AzureSubscription.Accounts | foreach{
        $script:AzureSubscriptionAccountsDetail += [PSCustomObject]@{
            "Id"                            = $_.Id
            "Type"                          = $_.Type
        }
    }
    $script:AzureSubscriptionAccountsDetailTable = New-HTMLTable -InputObject $script:AzureSubscriptionAccountsDetail

    $script:AzureSubscriptionDetail = [PSCustomObject]@{
        "SubscriptionId"                = $script:AzureSubscription.SubscriptionId
        "SubscriptionName"              = $script:AzureSubscription.SubscriptionName
        "Environment"                   = $script:AzureSubscription.Environment
        "TenantId"                      = $script:AzureSubscription.TenantId
        "DefaultAccount"                = $script:AzureSubscription.DefaultAccount
        "Accounts"                      = $script:AzureSubscriptionAccountsDetailTable
    }
    $script:AzureSubscriptionDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureSubscriptionDetail)

    $script:AzureSubscriptionTable = [PSCustomObject]@{
        "SubscriptionId"                = $script:AzureSubscription.SubscriptionId
        "SubscriptionName"              = $script:AzureSubscription.SubscriptionName
        "Environment"                   = $script:AzureSubscription.Environment
        "TenantId"                      = $script:AzureSubscription.TenantId
        "DefaultAccount"                = $script:AzureSubscription.DefaultAccount
        "Detail"                        = ConvertTo-DetailView -InputObject $script:AzureSubscriptionDetailTable
    }
    $script:Report += "<h3>ASM Subscription</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureSubscriptionTable)
}

function Save-AzureLocationTable{
    $script:AzureLocationTable = @()
    $AzureLocation | foreach{
        $script:AzureLocationDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "DisplayName"               = $_.DisplayName
            "AvailableServices"         = $_.AvailableServices -join "<br>"
            "VirtualMachineRoleSizes"   = $_.VirtualMachineRoleSizes -join "<br>"
            "WebWorkerRoleSizes"        = $_.WebWorkerRoleSizes -join "<br>"
            "StorageAccountTypes"       = $_.StorageAccountTypes -join "<br>"
        }
        $script:AzureLocationDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureLocationDetail)

        $script:AzureLocationTable += [PSCustomObject]@{
            "Location"                  = $_.Name
            "AvailableServices"         = $_.AvailableServices -join ", "
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureLocationDetailTable
        }
    }
    $script:Report += "<h3>ASM Location / VM Size</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureLocationTable)
}

function Save-AzureRmContextTable{
    $script:AzureRmContextDetail = [PSCustomObject]@{
        "SubscriptionId"              = $script:AzureRmContext.Subscription.SubscriptionId
        "SubscriptionName"            = $script:AzureRmContext.Subscription.SubscriptionId
        "State"                       = $script:AzureRmContext.Subscription.State
        "Environment"                 = $script:AzureRmContext.Environment
        "TenantId"                    = $script:AzureRmContext.Subscription.TenantId
        "Account"                     = $script:AzureRmContext.Account
    }
    $script:AzureRmContextDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmContextDetail)

    $script:AzureRmContextTable = [PSCustomObject]@{
        "SubscriptionId"              = $script:AzureRmContext.Subscription.SubscriptionId
        "SubscriptionName"            = $script:AzureRmContext.Subscription.SubscriptionId
        "State"                       = $script:AzureRmContext.Subscription.State
        "Environment"                 = $script:AzureRmContext.Environment
        "TenantId"                    = $script:AzureRmContext.Subscription.TenantId
        "Account"                     = $script:AzureRmContext.Account
        "Detail"                      = ConvertTo-DetailView -InputObject $script:AzureRmContextDetailTable
    }
    $script:Report += "<h3>ARM Subscription</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmContextTable)
}

function Save-AzureRmResourceProviderTable{
    $script:AzureRmResourceProviderTable = @()
    $script:AzureRmResourceProvider | foreach{
        $script:AzureRmResourceProviderDetail = [PSCustomObject]@{
            "ProviderNamespace"           = $_.ProviderNamespace
            "RegistrationState"           = $_.RegistrationState
            "ResourceTypes"               = $_.ResourceTypes.ResourceTypeName -join "<br>"
            "Locations"                   = $_.Locations -join "<br>"
        }
        $script:AzureRmResourceProviderDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmResourceProviderDetail)

        $script:AzureRmResourceProviderTable += [PSCustomObject]@{
            "ProviderNamespace"           = $_.ProviderNamespace
            "RegistrationState"           = $_.RegistrationState
            "Detail"                      = ConvertTo-DetailView -InputObject $script:AzureRmResourceProviderDetailTable
        }
    }
    $script:Report += "<h3>ARM Resource Provider</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmResourceProviderTable)
}

function Save-AzureRmProviderFeatureTable{
    $script:AzureRmProviderFeatureTable = @()
    $script:AzureRmProviderFeature | foreach{
        $script:AzureRmProviderFeatureDetail = [PSCustomObject]@{
            "FeatureName"                 = $_.FeatureName
            "ProviderName"                = $_.ProviderName
            "RegistrationState"           = $_.RegistrationState
        }
        $script:AzureRmProviderFeatureDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmProviderFeatureDetail)

        $script:AzureRmProviderFeatureTable += [PSCustomObject]@{
            "FeatureName"                 = $_.FeatureName
            "ProviderName"                = $_.ProviderName
            "RegistrationState"           = $_.RegistrationState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmProviderFeatureDetailTable
        }
    }
    $script:Report += "<h3>ARM Provider Feature</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmProviderFeatureTable)
}

function Save-AzureRmRoleAssignmentTable{
    $script:AzureRmRoleAssignmentTable = @()
    $script:AzureRmRoleAssignment | foreach{
        $script:AzureRmRoleAssignmentDetail = [PSCustomObject]@{
            "DisplayName"                 = $_.DisplayName
            "SignInName"                  = $_.SignInName
            "RoleDefinitionName"          = $_.RoleDefinitionName
            "RoleDefinitionId"            = $_.RoleDefinitionId
            "ObjectId"                    = $_.ObjectId
            "ObjectType"                  = $_.ObjectType
            "Scope"                       = $_.Scope
            "RoleAssignmentId"            = $_.RoleAssignmentId
        }
        $script:AzureRmRoleAssignmentDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRoleAssignmentDetail)

        $script:AzureRmRoleAssignmentTable += [PSCustomObject]@{
            "DisplayName"                 = $_.DisplayName
            "SignInName"                  = $_.SignInName
            "RoleDefinitionName"          = $_.RoleDefinitionName
            "ObjectType"                  = $_.ObjectType
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmRoleAssignmentDetailTable
        }
    }
    $script:Report += "<h3>ARM Role Assignment</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmRoleAssignmentTable)
}

function Save-AzureRmRoleDefinitionTable{
    $script:AzureRmRoleDefinitionTable = @()
    $script:AzureRmRoleDefinition | foreach{
        $script:AzureRmRoleDefinitionDetail = [PSCustomObject]@{
            "Name"                        = $_.Name
            "IsCustom"                    = $_.IsCustom
            "Description"                 = $_.Description
            "Actions"                     = $_.Actions -join "<br>"
            "NotActions"                  = $_.NotActions -join "<br>"
            "AssignableScopes"            = $_.AssignableScopes -join "<br>"
        }
        $script:AzureRmRoleDefinitionDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmRoleDefinitionDetail)

        $script:AzureRmRoleDefinitionTable += [PSCustomObject]@{
            "Name"                        = $_.Name
            "IsCustom"                    = $_.IsCustom
            "Description"                 = $_.Description
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmRoleDefinitionDetailTable
        }
    }
    $script:Report += "<h3>ARM Role Definition</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmRoleDefinitionTable)
}

function Save-AzureRmVMSizeTable{
    $script:AzureRmVMSizeTable = @()
    $script:AzureRmLocation | foreach {
        $script:AzureRmVMSizeTemp = Get-AzureRmVMSize -Location $_.Location
        
        $script:AzureRmVMSizeDetail = [PSCustomObject]@{
            "Location"                  = $_.Location
            "VMSize"                    = $script:AzureRmVMSizeTemp.Name -join "<br>"
        }
        $script:AzureRmVMSizeDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureRmVMSizeDetail)

        $script:AzureRmVMSizeTable += [PSCustomObject]@{
            "Location"                  = $_.Location
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzureRmVMSizeDetailTable
        }
    }
    $script:Report += "<h3>ARM Location / VM Size</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmVMSizeTable)
}

function Save-AzureComputeHeader{
    $script:Report += "<a name=`"CRP`"><h2>Virtual Machine</h2></a>"
}

function Save-AzureStorageHeader{
    $script:Report += "<a name=`"SRP`"><h2>Storage</h2></a>"
}

function Save-AzureNetworkHeader{
    $script:Report += "<a name=`"NRP`"><h2>Network</h2></a>"
}

function Save-AzureSubscriptionHeader{
    $script:Report += "<a name=`"Sub`"><h2>Subscription Information</h2></a>"
}

function Save-AzureOperationHeader{
    $script:Report += "<a name=`"Ops`"><h2>Operation</h2></a> between $script:LogStartTime and $script:ExecutedDateString"
}

function Save-AzureLogTable{
    $script:AzureLogTable = @()
    $script:AzureRmLog | foreach{
        $script:AzureLogHttpRequestDetail = [PSCustomObject]@{
            "ClientId"                    = $_.HttpRequest.ClientId
            "Method"                      = $_.HttpRequest.Method
            "Url"                         = $_.HttpRequest.Url
            "ClientIpAddress"             = $_.HttpRequest.ClientIpAddress
        }
        $script:AzureLogHttpRequestDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureLogHttpRequestDetail)

        if($_.Claims.Content -ne $null){
            $script:AzureLogClaimsDetail = ConvertTo-PropertyValue -InputObject  (ConvertFrom-Json  -InputObject (ConvertTo-Json -InputObject $_.Claims.Content))
            if($script:AzureLogClaimsDetail -ne $null){
                $script:AzureLogClaimsDetailTable = New-HTMLTable -InputObject $script:AzureLogClaimsDetail
            }
        }

        $script:AzureLogDetail = [PSCustomObject]@{
            "EventTimestamp"              = $_.EventTimestamp
            "SubmissionTimestamp"         = $_.SubmissionTimestamp
            "ResourceGroupName"           = $_.ResourceGroupName
            "EventName"                   = $_.EventName
            "Level"                       = $_.Level
            "Category"                    = $_.Category
            "OperationName"               = $_.OperationName
            "ResourceProviderName"        = $_.ResourceProviderName
            "Scope"                       = $_.Authorization.Scope
            "ResourceId"                  = $_.ResourceId
            "SubscriptionId"              = $_.SubscriptionId
            "Status"                      = $_.Status
            "SubStatus"                   = $_.SubStatus
            "Caller"                      = $_.Caller
            "CorrelationId"               = $_.CorrelationId
            "OperationId"                 = $_.OperationId
            "Description"                 = $_.Description
            "EventChannels"               = $_.EventChannels
            "EventDataId"                 = $_.EventDataId
            "HttpRequest"                 = ConvertTo-DetailView -InputObject $script:AzureLogHttpRequestDetailTable
            "Claims"                      = ConvertTo-DetailView -InputObject $script:AzureLogClaimsDetailTable
        }
        $script:AzureLogDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzureLogDetail)

        $script:AzureLogTable += [PSCustomObject]@{
            "EventTimestamp"              = $_.EventTimestamp
            "ResourceGroupName"           = $_.ResourceGroupName
            "OperationName"               = $_.OperationName
            "Status"                      = $_.Status
            "Detail"                      = ConvertTo-DetailView -InputObject $script:AzureLogDetailTable
        }
    }
    
    $script:AzureComputeLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.ClassicCompute"})
    $script:AzureStorageLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.ClassicStorage"})
    $script:AzureNetworkLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.ClassicNetwork"})
    $script:AzureRmResourcesLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.Resources"})
    $script:AzureRmComputeLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.Compute"})
    $script:AzureRmStorageLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.Storage"})
    $script:AzureRmNetworkLogTable = ($script:AzureLogTable | where {$_.OperationName -match "Microsoft.Network"})
    $script:AzureRmAnotherLogTable = ($script:AzureLogTable | where {($_.OperationName -notmatch "Microsoft.ClassicCompute") -and ($_.OperationName -notmatch "Microsoft.ClassicStorage") -and ($_.OperationName -notmatch "Microsoft.ClassicNetwork") -and ($_.OperationName -notmatch "Microsoft.Resources") -and ($_.OperationName -notmatch "Microsoft.Compute") -and ($_.OperationName -notmatch "Microsoft.Storage") -and ($_.OperationName -notmatch "Microsoft.Network")})
    
    $script:LogStartTime = $script:ExecutedDate.AddDays(-14).ToString("yyyy-MM-ddTHH:mm:ss")
    $script:Report += "<h3>ASM Compute Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureComputeLogTable)
    $script:Report += "<h3>ARM Storage Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureStorageLogTable)
    $script:Report += "<h3>ARM Network Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureNetworkLogTable)
    $script:Report += "<h3>ARM Resource Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmResourceLogTable)
    $script:Report += "<h3>ARM Compute Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmComputeLogTable)
    $script:Report += "<h3>ARM Storage Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmStorageLogTable)
    $script:Report += "<h3>ARM Network Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmNetworkLogTable)
    $script:Report += "<h3>ASM / ARM Another Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmAnotherLogTable)
}

# Close html
function Save-AzureReportFooter{
    $null = Close-HTML -HTML $script:Report -Verbose
    
    if((Test-Path $OutputFolder) -eq $false){
        $null = New-Item -Path $OutputFolder -ItemType Directory
    }
    $Date = (Get-Date -Format yyyyMMdd_HHmmss)
    $global:ReportPath = "$OutputFolder\$SubscriptionID-$Date.htm"
    Set-Content $ReportPath $script:Report
    . $global:ReportPath 
}

# Call save function
function Save-AzureReport{
    Write-Log "Waiting: HTML report"
    Write-Log "Waiting: Save-AzureReportHeader"
    Save-AzureReportHeader
    Write-Log "Success: Save-AzureReportHeader" -Color Green

    Write-Log "Waiting: Save-AzureComputeHeader"
    Save-AzureComputeHeader
    Write-Log "Success: Save-AzureComputeHeader" -Color Green

    Write-Log "Waiting: Save-AzureServiceTable"
    Save-AzureServiceTable
    Write-Log "Success: Save-AzureServiceTable" -Color Green
    
    Write-Log "Waiting: Save-AzureVmWindowsTable"
    Save-AzureVmWindowsTable
    Write-Log "Success: Save-AzureVmWindowsTable" -Color Green
    
    Write-Log "Waiting: Save-AzureVmLinuxTable"
    Save-AzureVmLinuxTable
    Write-Log "Success: Save-AzureVmLinuxTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmAvailabilitySetTable"
    Save-AzureRmAvailabilitySetTable
    Write-Log "Success: Save-AzureRmAvailabilitySetTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmVmWindowsTable"
    Save-AzureRmVmWindowsTable
    Write-Log "Success: Save-AzureRmVmWindowsTable" -Color Green

    Write-Log "Waiting: Save-AzureRmVmLinuxTable"
    Save-AzureRmVmLinuxTable
    Write-Log "Success: Save-AzureRmVmLinuxTable" -Color Green

    Write-Log "Waiting: Save-AzureStorageHeader"
    Save-AzureStorageHeader
    Write-Log "Success: Save-AzureStorageHeader" -Color Green

    Write-Log "Waiting: Save-AzureStorageAccountTable"
    Save-AzureStorageAccountTable
    Write-Log "Success: Save-AzureStorageAccountTable" -Color Green

    Write-Log "Waiting: Save-AzureRmStorageAccountTable"
    Save-AzureRmStorageAccountTable
    Write-Log "Success: Save-AzureRmStorageAccountTable" -Color Green
    
    Write-Log "Waiting: Save-AzureDiskTable"
    Save-AzureDiskTable
    Write-Log "Success: Save-AzureDiskTable" -Color Green

    Write-Log "Waiting: Save-AzureVMImageTable"
    Save-AzureVMImageTable
    Write-Log "Success: Save-AzureVMImageTable" -Color Green

    Write-Log "Waiting: Save-AzureRmVmDiskTable"
    Save-AzureRmVmDiskTable
    Write-Log "Success: Save-AzureRmVmDiskTable" -Color Green

    Write-Log "Waiting: Save-AzureNetworkHeader"
    Save-AzureNetworkHeader
    Write-Log "Success: Save-AzureNetworkHeader" -Color Green
    
    Write-Log "Waiting: Save-AzureVirtualNetworkSiteTable"
    Save-AzureVirtualNetworkSiteTable
    Write-Log "Success: Save-AzureVirtualNetworkSiteTable" -Color Green

    Write-Log "Waiting: Save-AzureRmVirtualNetworkTable"
    Save-AzureRmVirtualNetworkTable
    Write-Log "Success: Save-AzureRmVirtualNetworkTable" -Color Green
    
    Write-Log "Waiting: Save-AzureVirtualNetworkGatewayTable"
    Save-AzureVirtualNetworkGatewayTable
    Write-Log "Success: Save-AzureVirtualNetworkGatewayTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmVirtualNetworkGatewayTable"
    Save-AzureRmVirtualNetworkGatewayTable
    Write-Log "Success: Save-AzureRmVirtualNetworkGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzureLocalNetworkSiteTable"
    Save-AzureLocalNetworkSiteTable
    Write-Log "Success: Save-AzureLocalNetworkSiteTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmLocalNetworkGatewayTable"
    Save-AzureRmLocalNetworkGatewayTable
    Write-Log "Success: Save-AzureRmLocalNetworkGatewayTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmApplicationGatewayTable"
    Save-AzureRmApplicationGatewayTable
    Write-Log "Success: Save-AzureRmApplicationGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzureDedicatedCircuitTable"
    Save-AzureDedicatedCircuitTable
    Write-Log "Success: Save-AzureDedicatedCircuitTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmExpressRouteCircuitTable"
    Save-AzureRmExpressRouteCircuitTable
    Write-Log "Success: Save-AzureRmExpressRouteCircuitTable" -Color Green

    Write-Log "Waiting: Save-AzureRmExpressRouteCircuitAuthorizationTable"
    Save-AzureRmExpressRouteCircuitAuthorizationTable
    Write-Log "Success: Save-AzureRmExpressRouteCircuitAuthorizationTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmLoadBalancerTable"
    Save-AzureRmLoadBalancerTable
    Write-Log "Success: Save-AzureRmLoadBalancerTable" -Color Green

    Write-Log "Waiting: Save-AzureRmNetworkInterfaceTable"
    Save-AzureRmNetworkInterfaceTable
    Write-Log "Success: Save-AzureRmNetworkInterfaceTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmPublicIpAddressTable"
    Save-AzureRmPublicIpAddressTable
    Write-Log "Success: Save-AzureRmPublicIpAddressTable" -Color Gree

    Write-Log "Waiting: Save-AzureRmNetworkSecurityGroupTable"
    Save-AzureRmNetworkSecurityGroupTable
    Write-Log "Success: Save-AzureRmNetworkSecurityGroupTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmRouteTableTable"
    Save-AzureRmRouteTableTable
    Write-Log "Success: Save-AzureRmRouteTableTable" -Color Green

    Write-Log "Waiting: Save-AzureDnsServerTable"
    Save-AzureDnsServerTable
    Write-Log "Success: Save-AzureDnsServerTable" -Color Green

    Write-Log "Waiting: Save-AzureRmDnsZoneTable"
    Save-AzureRmDnsZoneTable
    Write-Log "Success: Save-AzureRmDnsZoneTable" -Color Green

    Write-Log "Waiting: Save-AzureSubscriptionHeader"
    Save-AzureSubscriptionHeader
    Write-Log "Success: Save-AzureSubscriptionHeader" -Color Green

    Write-Log "Waiting: Save-AzureSubscriptionAccountsTable"
    Save-AzureSubscriptionAccountsTable
    Write-Log "Success: Save-AzureSubscriptionAccountsTable" -Color Green

    Write-Log "Waiting: Save-AzureRmContextTable"
    Save-AzureRmContextTable
    Write-Log "Success: Save-AzureRmContextTable" -Color Green

    Write-Log "Waiting: Save-AzureRmRoleAssignmentTable"
    Save-AzureRmRoleAssignmentTable
    Write-Log "Success: Save-AzureRmRoleAssignmentTable" -Color Green

    Write-Log "Waiting: Save-AzureRmRoleDefinitionTable"
    Save-AzureRmRoleDefinitionTable
    Write-Log "Success: Save-AzureRmRoleDefinitionTable" -Color Green

    Write-Log "Waiting: Save-AzureRmResourceProviderTable"
    Save-AzureRmResourceProviderTable
    Write-Log "Success: Save-AzureRmResourceProviderTable" -Color Green

    Write-Log "Waiting: Save-AzureRmProviderFeatureTable"
    Save-AzureRmProviderFeatureTable
    Write-Log "Success: Save-AzureRmProviderFeatureTable" -Color Green
    
    Write-Log "Waiting: Save-AzureLocationTable"
    Save-AzureLocationTable
    Write-Log "Success: Save-AzureLocationTable" -Color Green

    Write-Log "Waiting: Save-AzureRmVMSizeTable"
    Save-AzureRmVMSizeTable
    Write-Log "Success: Save-AzureRmVMSizeTable" -Color Green

    Write-Log "Waiting: Save-AzureOperationHeader"
    Save-AzureOperationHeader
    Write-Log "Success: Save-AzureOperationHeader" -Color Green

    Write-Log "Waiting: Save-AzureLogTable"
    Save-AzureLogTable
    Write-Log "Success: Save-AzureLogTable" -Color Green

    Write-Log "Waiting: Save-AzureReportFooter"
    Save-AzureReportFooter
    Write-Log "Success: Save-AzureReportFooter" -Color Green

    Write-Log "Success: HTML report" -Color Green
    Write-Log "HTML report: $global:ReportPath"
}

# Main method
Initialize
New-AzureSession
Get-AsmInformation
Get-ArmInformation
Save-AzureReport