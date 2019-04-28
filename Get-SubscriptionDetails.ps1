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
    Version : 0.9.3
    Author  : Syuhei Uda
    
    HTML table functions by Cookie.Monster (MIT License) http://gallery.technet.microsoft.com/scriptcenter/PowerShell-HTML-Notificatio-e1c5759d
#>

[CmdletBinding(  
    DefaultParameterSetName = "Full"
)]

Param(
    [Parameter(Mandatory=$true)][string]$SubscriptionID,
    [string]$OutputFolder = "$env:USERPROFILE\Desktop\Get-SubscriptionDetails",
    [switch]$SkipAuth
)

# Load Compute
."Compute\AvailabilitySet.ps1"
.".\Compute\VmLinux.ps1"
.".\Compute\VmWindows.ps1"

# Load Network
.".\Network\ApplicationGateway.ps1"
.".\Network\DnsZone.ps1"
.".\Network\ExpressRouteCircuit.ps1"
.".\Network\LoadBalancer.ps1"
.".\Network\LocalNetworkGateway.ps1"
.".\Network\NetworkInterface.ps1"
.".\Network\NetworkSecurityGroup.ps1"
.".\Network\PublicIpAddress.ps1"
.".\Network\RouteFilter.ps1"
.".\Network\RouteTable.ps1"
.".\Network\VirtualNetwork.ps1"
.".\Network\VirtualNetworkGateway.ps1"
.".\Network\VirtualNetworkGatewayConnection.ps1"

# Load Storage
.".\Storage\Disk.ps1"
.".\Storage\Image.ps1"
.".\Storage\Snapshot.ps1"
.".\Storage\StorageAccount.ps1"
.".\Storage\RecoveryServiceVault.ps1"

# Header
$script:Version = "0.9.3"
$script:LatestVersionUrl = "https://raw.githubusercontent.com/ShuheiUda/Get-SubscriptionDetails/master/LatestVersion.txt"
$script:errorImagePath = "https://raw.githubusercontent.com/ShuheiUda/Get-SubscriptionDetails/master/img/error.png"
$script:warnImagePath = "https://raw.githubusercontent.com/ShuheiUda/Get-SubscriptionDetails/master/img/warn.png"
$script:infoImagePath = "https://raw.githubusercontent.com/ShuheiUda/Get-SubscriptionDetails/master/img/Info.png"


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

Function ConvertTo-FindingsTable{
    param(
        $InputObject
    )

    if($InputObject -ne $null){
        $InputObject = $InputObject.Replace("<td>Error</td>","<td><img src=$script:errorImagePath> Error</td>")
        $InputObject = $InputObject.Replace("<td>Warning</td>","<td><img src=$script:warnImagePath> Warning</td>")
        $InputObject = $InputObject.Replace("<td>Information</td>","<td><img src=$script:infoImagePath> Information</td>")
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
                    tr {
                        vertical-align:top;
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
        Write-Log "Waiting: Login-AzureRmAccount"
        $null = Login-AzureRmAccount
        Write-Log "Success: Login-AzureRmAccount" -Color Green
    }
 
    Write-Log "Waiting: Select-AzureRmSubscription"
    $null = Select-AzureRmSubscription -SubscriptionId $SubscriptionID
    Write-Log "Success: Select-AzureRmSubscription" -Color Green

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

# Get Information
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

    Write-Log "Waiting: Get-AzureRmDisk"
    $script:AzureRmDisk = Get-AzureRmDisk
    Write-Log "Success: Get-AzureRmDisk" -Color Green

    Write-Log "Waiting: Get-AzureRmSnapshot"
    $script:AzureRmSnapshot = Get-AzureRmSnapshot
    Write-Log "Success: Get-AzureRmSnapshot" -Color Green

    Write-Log "Waiting: Get-AzureRmImage"
    $script:AzureRmImage = Get-AzureRmImage
    Write-Log "Success: Get-AzureRmImage" -Color Green

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

    Write-Log "Waiting: Get-AzureRmVirtualNetworkGatewayConnection"
    $script:AzureRmVirtualNetworkGatewayConnection = ($script:AzureRmResourceGroup | Get-AzureRmVirtualNetworkGatewayConnection)
    Write-Log "Success: Get-AzureRmVirtualNetworkGatewayConnection" -Color Green

    Write-Log "Waiting: Get-AzureRmExpressRouteCircuit"
    $script:AzureRmExpressRouteCircuit = Get-AzureRmExpressRouteCircuit
    Write-Log "Success: Get-AzureRmExpressRouteCircuit" -Color Green

    Write-Log "Waiting: Get-AzureRmRouteFilter"
    $script:AzureRmRouteFilter = Get-AzureRmRouteFilter
    Write-Log "Success: Get-AzureRmRouteFilter" -Color Green

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
    $script:AzureRmLog = Get-AzureRmLog -StartTime $script:ExecutedDate.AddDays(-14)
    Write-Log "Success: Get-AzureRmLog" -Color Green

    Write-Log "Waiting: Get-AzureRmLocation"
    $script:AzureRmLocation = Get-AzureRmLocation
    Write-Log "Success: Get-AzureRmLocation" -Color Green

    Write-Log "Waiting: Get-AzureRmRecoveryServicesVault"
    $script:AzureRmRecoveryServicesVault = Get-AzureRmRecoveryServicesVault
    Write-Log "Success: Get-AzureRmRecoveryServicesVault" -Color Green

}

# Create new html data
function Save-AzureReportHeader{
    $script:Report = New-HTMLHead -title "Get-SubscriptionDetails Report"
    $script:Report += "<h2>Get-SubscriptionDetails Report (Version: $script:Version)</h2>"
    $script:Report += "<h3>Subscription ID: $SubscriptionID ( Executed on : $script:ExecutedDateString )<br><a href=`"#CRP`">Virtual Machine</a> | <a href=`"#SRP`">Storage</a> | <a href=`"#NRP`">Network</a> | <a href=`"#Sub`">Subscription Information</a> | <a href=`"#Ops`">Operation</a></h3>"
    
    <#
    $script:Report += "<h2>Findings</h2>"
    $script:Report += ConvertTo-FindingsTable -InputObject (New-ResourceHTMLTable -InputObject $AzureFindingTable)
    #>
}

# Add Provisioning State Color
function Add-ProvisioningStateColor{
    param(
    $TempTable
    )

    if($TempTable -ne $null){
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "ProvisioningState" -Argument 'Succeeded' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "ProvisioningState" -Argument 'Failed' -attrValue "background-color:salmon;"
    }

    return $TempTable
}

# Add Operation Status Color
function Add-OperationStatusColor{
    param(
    $TempTable
    )

    if($TempTable -ne $null){
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'Started' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'Accepted' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'Succeeded' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'Failed' -attrValue "background-color:salmon;"
    }

    return $TempTable
}


# Add Registration State Color
function Add-RegistrationStateColor{
    param(
    $TempTable
    )

    if($TempTable -ne $null){
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "RegistrationState" -Argument 'Registered' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "RegistrationState" -Argument 'Registering' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "RegistrationState" -Argument 'Unregistering' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "RegistrationState" -Argument 'NotRegistered' -attrValue "background-color:salmon;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "RegistrationState" -Argument 'Unregistered' -attrValue "background-color:salmon;"
    }

    return $TempTable
}

# Add AzureVM Status Color
function Add-AzureVMStatusColor{
    param(
    $TempTable
    )

    if($TempTable -ne $null){
        # Status
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'ReadyRole' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'CreatingVM' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'Provisioning' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'StoppedVM' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'RoleStateUnknown' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'StoppedDeallocated' -attrValue "background-color:lightgray;"

        # PowerState
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "PowerState" -Argument 'Started' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "PowerState" -Argument 'Stopped' -attrValue "background-color:lightgray;"
    }

    return $TempTable
}

# Add AzureRmVM Status Color
function Add-AzureRmVMStatusColor{
    param(
    $TempTable
    )

    if($TempTable -ne $null){
        # Status
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'ReadyRole' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'CreatingVM' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'Provisioning' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'StoppedVM' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'RoleStateUnknown' -attrValue "background-color:Yellow;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "Status" -Argument 'StoppedDeallocated' -attrValue "background-color:lightgray;"

        # PowerState
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "PowerState" -Argument 'Started' -attrValue "background-color:PaleGreen;"
        $TempTable = Add-HTMLTableColor -HTML $TempTable -Column "PowerState" -Argument 'Stopped' -attrValue "background-color:lightgray;"
    }

    return $TempTable
}

# Check Known Issue
function Check-AzureKnownIssue{
    # backlog
    $script:AzureFindingTable = @()
    $script:AzureFindingTable += [PSCustomObject]@{
            "Category"                              = "Error"
            "Description"                           = "This is sample error message"
    }
    $script:AzureFindingTable += [PSCustomObject]@{
            "Category"                              = "Warning"
            "Description"                           = "This is sample warning message"
    }
    $script:AzureFindingTable += [PSCustomObject]@{
            "Category"                              = "Information"
            "Description"                           = "This is sample information message"
    }

    # Operation error check
    if($script:AzureRmLog.Status -contains "failed"){
        $script:AzureFindingTable += [PSCustomObject]@{
                "Category"                              = "Error"
                "Description"                           = "Error operation is found."
        }
    }

    # GatewaySubnet NSG check
    if($script:AzureRmNetworkSecurityGroup.Subnets.Id.Contains("GatewaySubnet")){
        $script:AzureFindingTable += [PSCustomObject]@{
                "Category"                              = "Warning"
                "Description"                           = "GatewaySubnet's NSG is not supported"
        }
    }
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
    $script:Report += "<h3>Subscription</h3>"
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
    $script:Report += "<h3>Resource Provider</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-RegistrationStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmResourceProviderTable))
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
    $script:Report += "<h3>Provider Feature</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-RegistrationStateColor(New-ResourceHTMLTable -InputObject $script:AzureRmProviderFeatureTable))
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
    $script:Report += "<h3>Role Assignment</h3>"
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
    $script:Report += "<h3>Role Definition</h3>"
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
    $script:Report += "<h3>Location / VM Size</h3>"
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
            "EventName"                   = $_.EventName.Value
            "Level"                       = $_.Level
            "Category"                    = $_.Category.Value
            "OperationName"               = $_.OperationName.Value
            "ResourceProviderName"        = $_.ResourceProviderName.Value
            "Scope"                       = $_.Authorization.Scope
            "ResourceId"                  = $_.ResourceId
            "SubscriptionId"              = $_.SubscriptionId
            "Status"                      = $_.Status.Value
            "SubStatus"                   = $_.SubStatus.Value
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
            "OperationName"               = $_.OperationName.Value
            "Status"                      = $_.Status.Value
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
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor (New-ResourceHTMLTable -InputObject $script:AzureComputeLogTable))
    $script:Report += "<h3>Storage Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureStorageLogTable))
    $script:Report += "<h3>Network Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureNetworkLogTable))
    $script:Report += "<h3>Resource Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureRmResourceLogTable))
    $script:Report += "<h3>Compute Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureRmComputeLogTable))
    $script:Report += "<h3>Storage Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureRmStorageLogTable))
    $script:Report += "<h3>Network Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureRmNetworkLogTable))
    $script:Report += "<h3>ASM / Another Operation</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-OperationStatusColor(New-ResourceHTMLTable -InputObject $script:AzureRmAnotherLogTable))
}

# Close html
function Save-AzureReportFooter{
    $null = Close-HTML -HTML $script:Report -Verbose
    
    if((Test-Path $OutputFolder) -eq $false){
        $null = New-Item -Path $OutputFolder -ItemType Directory
    }
    $Date = (Get-Date -Format yyyyMMdd_HHmmss)
    $global:ReportPath = "$OutputFolder\$SubscriptionID-$Date.htm"
    Set-Content $global:ReportPath $script:Report
    . $global:ReportPath 
}

# Call save function
function Save-AzureReport{
    Write-Log "Waiting: HTML report"

    <#
    Write-Log "Waiting: Check-AzureKnownIssue"
    Check-AzureKnownIssue
    Write-Log "Success: Check-AzureKnownIssue" -Color Green
    #>

    Write-Log "Waiting: Save-AzureReportHeader"
    Save-AzureReportHeader
    Write-Log "Success: Save-AzureReportHeader" -Color Green
    
    Write-Log "Waiting: Save-AzureComputeHeader"
    Save-AzureComputeHeader
    Write-Log "Success: Save-AzureComputeHeader" -Color Green
        
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
    
    Write-Log "Waiting: Save-AzureRmStorageAccountTable"
    Save-AzureRmStorageAccountTable
    Write-Log "Success: Save-AzureRmStorageAccountTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmDiskTable"
    Save-AzureRmDiskTable
    Write-Log "Success: Save-AzureRmDiskTable" -Color Green
  
    Write-Log "Waiting: Save-AzureRmSnapshotTable"
    Save-AzureRmSnapshotTable
    Write-Log "Success: Save-AzureRmSnapshotTable" -Color Green
  
    Write-Log "Waiting: Save-AzureRmImageTable"
    Save-AzureRmImageTable
    Write-Log "Success: Save-AzureRmImageTable" -Color Green

    Write-Log "Waiting: Save-AzureRmRecoveryServiceVault"
    Save-AzureRmRecoveryServicesVault
    Write-Log "Success: Save-AzureRmRecoveryServiceVault" -Color Green
    
    Write-Log "Waiting: Save-AzureNetworkHeader"
    Save-AzureNetworkHeader
    Write-Log "Success: Save-AzureNetworkHeader" -Color Green
    
    Write-Log "Waiting: Save-AzureRmVirtualNetworkTable"
    Save-AzureRmVirtualNetworkTable
    Write-Log "Success: Save-AzureRmVirtualNetworkTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmVirtualNetworkGatewayTable"
    Save-AzureRmVirtualNetworkGatewayTable
    Write-Log "Success: Save-AzureRmVirtualNetworkGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzureRmVirtualNetworkGatewayConnection"
    Save-AzureRmVirtualNetworkGatewayConnection
    Write-Log "Success: Save-AzureRmVirtualNetworkGatewayConnection" -Color Green
    
    Write-Log "Waiting: Save-AzureRmLocalNetworkGatewayTable"
    Save-AzureRmLocalNetworkGatewayTable
    Write-Log "Success: Save-AzureRmLocalNetworkGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzureRmApplicationGatewayTable"
    Save-AzureRmApplicationGatewayTable
    Write-Log "Success: Save-AzureRmApplicationGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzureRmExpressRouteCircuitTable"
    Save-AzureRmExpressRouteCircuitTable
    Write-Log "Success: Save-AzureRmExpressRouteCircuitTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmRouteFilter"
    Save-AzureRmRouteFilter
    Write-Log "Success: Save-AzureRmRouteFilter" -Color Green
    
    Write-Log "Waiting: Save-AzureRmLoadBalancerTable"
    Save-AzureRmLoadBalancerTable
    Write-Log "Success: Save-AzureRmLoadBalancerTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmNetworkInterfaceTable"
    Save-AzureRmNetworkInterfaceTable
    Write-Log "Success: Save-AzureRmNetworkInterfaceTable" -Color Green
    
    Write-Log "Waiting: Save-AzureRmPublicIpAddressTable"
    Save-AzureRmPublicIpAddressTable
    Write-Log "Success: Save-AzureRmPublicIpAddressTable" -Color Green

    Write-Log "Waiting: Save-AzureRmNetworkSecurityGroupTable"
    Save-AzureRmNetworkSecurityGroupTable
    Write-Log "Success: Save-AzureRmNetworkSecurityGroupTable" -Color Green

    Write-Log "Waiting: Save-AzureRmRouteTableTable"
    Save-AzureRmRouteTableTable
    Write-Log "Success: Save-AzureRmRouteTableTable" -Color Green

    Write-Log "Waiting: Save-AzureRmDnsZoneTable"
    Save-AzureRmDnsZoneTable
    Write-Log "Success: Save-AzureRmDnsZoneTable" -Color Green

    Write-Log "Waiting: Save-AzureSubscriptionHeader"
    Save-AzureSubscriptionHeader
    Write-Log "Success: Save-AzureSubscriptionHeader" -Color Green
    
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
    #Save-AzureRmProviderFeatureTable
    Write-Log "Success: Save-AzureRmProviderFeatureTable" -Color Green
 
    Write-Log "Waiting: Save-AzureRmVMSizeTable"
    #Save-AzureRmVMSizeTable
    Write-Log "Success: Save-AzureRmVMSizeTable" -Color Green

    Write-Log "Waiting: Save-AzureOperationHeader"
    Save-AzureOperationHeader
    Write-Log "Success: Save-AzureOperationHeader" -Color Green

    Write-Log "Waiting: Save-AzureLogTable"
    #Save-AzureLogTable
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
Get-ArmInformation
Save-AzureReport