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
    [string]$OutputFolder = "$HOME\output\Get-SubscriptionDetails",
    [switch]$SkipAuth,
    [switch]$Compute,
    [switch]$Network,
    [switch]$Storage,
    [switch]$Management
)

# Load Compute
.".\Compute\AvailabilitySet.ps1"
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

# Management 
.".\Management\LogAnalyticsWorkspace.ps1"

# Subscription
.".\Subscription\ResourceProvider.ps1"
.".\Subscription\Role.ps1"

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
        Write-Log "Waiting: Login-AzAccount"
        $null = Login-AzAccount
        Write-Log "Success: Login-AzAccount" -Color Green
    }
 
    Write-Log "Waiting: Select-AzSubscription"
    $null = Select-AzSubscription -SubscriptionId $SubscriptionID
    Write-Log "Success: Select-AzSubscription" -Color Green

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

}

# Get Information
function Get-ArmInformation{

    Write-Log "Waiting: Get-AzContext"
    $script:AzContext = Get-AzContext
    Write-Log "Success: Get-AzContext" -Color Green

    Write-Log "Waiting: Get-AzResourceGroup"
    $script:AzResourceGroup = Get-AzResourceGroup
    Write-Log "Success: Get-AzResourceGroup" -Color Green

    Write-Log "Waiting: Get-AzVM"
    $script:AzVM = Get-AzVM
    Write-Log "Success: Get-AzVM" -Color Green

    Write-Log "Waiting: Get-AzDisk"
    $script:AzDisk = Get-AzDisk
    Write-Log "Success: Get-AzDisk" -Color Green

    Write-Log "Waiting: Get-AzSnapshot"
    $script:AzSnapshot = Get-AzSnapshot
    Write-Log "Success: Get-AzSnapshot" -Color Green

    Write-Log "Waiting: Get-AzImage"
    $script:AzImage = Get-AzImage
    Write-Log "Success: Get-AzImage" -Color Green

    Write-Log "Waiting: Get-AzAvailabilitySet"
    $script:AzAvailabilitySet = Get-AzResourceGroup | Get-AzAvailabilitySet
    Write-Log "Success: Get-AzAvailabilitySet" -Color Green

    Write-Log "Waiting: Get-AzVirtualNetwork"
    $script:AzVirtualNetwork = Get-AzVirtualNetwork
    Write-Log "Success: Get-AzVirtualNetwork" -Color Green

    Write-Log "Waiting: Get-AzNetworkInterface"
    $script:AzNetworkInterface = Get-AzNetworkInterface
    Write-Log "Success: Get-AzNetworkInterface" -Color Green

    Write-Log "Waiting: Get-AzNetworkSecurityGroup"
    $script:AzNetworkSecurityGroup = Get-AzNetworkSecurityGroup
    Write-Log "Success: Get-AzNetworkSecurityGroup" -Color Green

    Write-Log "Waiting: Get-AzRouteTable"
    $script:AzRouteTable = Get-AzRouteTable
    Write-Log "Success: Get-AzRouteTable" -Color Green

    Write-Log "Waiting: Get-AzLoadBalancer"
    $script:AzLoadBalancer = Get-AzLoadBalancer
    Write-Log "Success: Get-AzLoadBalancer" -Color Green

    Write-Log "Waiting: Get-AzLocalNetworkGateway"
    $script:AzLocalNetworkGateway = ($script:AzResourceGroup | Get-AzLocalNetworkGateway)
    Write-Log "Success: Get-AzLocalNetworkGateway" -Color Green

    Write-Log "Waiting: Get-AzVirtualNetworkGateway"
    $script:AzVirtualNetworkGateway = ($script:AzResourceGroup | Get-AzVirtualNetworkGateway)
    Write-Log "Success: Get-AzVirtualNetworkGateway" -Color Green

    Write-Log "Waiting: Get-AzVirtualNetworkGatewayConnection"
    $script:AzVirtualNetworkGatewayConnection = ($script:AzResourceGroup | Get-AzVirtualNetworkGatewayConnection)
    Write-Log "Success: Get-AzVirtualNetworkGatewayConnection" -Color Green

    Write-Log "Waiting: Get-AzExpressRouteCircuit"
    $script:AzExpressRouteCircuit = Get-AzExpressRouteCircuit
    Write-Log "Success: Get-AzExpressRouteCircuit" -Color Green

    Write-Log "Waiting: Get-AzRouteFilter"
    $script:AzRouteFilter = Get-AzRouteFilter
    Write-Log "Success: Get-AzRouteFilter" -Color Green

    Write-Log "Waiting: Get-AzApplicationGateway"
    $script:AzApplicationGateway = Get-AzApplicationGateway
    Write-Log "Success: Get-AzApplicationGateway" -Color Green

    Write-Log "Waiting: Get-AzPublicIpAddress"
    $script:AzPublicIpAddress = Get-AzPublicIpAddress
    Write-Log "Success: Get-AzPublicIpAddress" -Color Green

    Write-Log "Waiting: Get-AzDnsZone"
    $script:AzDnsZone = Get-AzDnsZone
    Write-Log "Success: Get-AzDnsZone" -Color Green

    Write-Log "Waiting: Get-AzStorageAccount"
    $script:AzStorageAccount = Get-AzStorageAccount
    Write-Log "Success: Get-AzStorageAccount" -Color Green

    Write-Log "Waiting: Get-AzRoleAssignment"
    $script:AzRoleAssignment = Get-AzRoleAssignment
    Write-Log "Success: Get-AzRoleAssignment" -Color Green

    Write-Log "Waiting: Get-AzRoleDefinition(custom only)"
    $script:AzRoleDefinition = Get-AzRoleDefinition -Custom
    Write-Log "Success: Get-AzRoleDefinition(custom only)" -Color Green

    Write-Log "Waiting: Get-AzRecoveryServicesVault"
    $script:AzRecoveryServicesVault = Get-AzRecoveryServicesVault
    Write-Log "Success: Get-AzRecoveryServicesVault" -Color Green

    Write-Log "Waiting: Get-AzOperationalInsightsWorkspace"
    $script:AzLogAnalyticsWorkspace = Get-AzOperationalInsightsWorkspace
    Write-Log "Success: Get-AzOperationalInsightsWorkspace" -Color Green
}

# Create new html data
function Save-AzureReportHeader{
    $script:Report = New-HTMLHead -title "Get-SubscriptionDetails Report"
    $script:Report += "<h2>Get-SubscriptionDetails Report (Version: $script:Version)</h2>"
    $script:Report += "<h3>Subscription ID: $SubscriptionID ( Executed on : $script:ExecutedDateString )<br><a href=`"#CRP`">Virtual Machine</a> | <a href=`"#SRP`">Storage</a> | <a href=`"#NRP`">Network</a> | <a href=`"#Management`">Management</a>| <a href=`"#Sub`">Subscription Information</a> </h3>"
    
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

# Add AzVM Status Color
function Add-AzVMStatusColor{
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

function Save-AzContextTable{
    $script:AzContextDetail = [PSCustomObject]@{
        "SubscriptionId"              = $script:AzContext.Subscription.SubscriptionId
        "SubscriptionName"            = $script:AzContext.Subscription.SubscriptionId
        "State"                       = $script:AzContext.Subscription.State
        "Environment"                 = $script:AzContext.Environment
        "TenantId"                    = $script:AzContext.Subscription.TenantId
        "Account"                     = $script:AzContext.Account
    }
    $script:AzContextDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzContextDetail)

    $script:AzContextTable = [PSCustomObject]@{
        "SubscriptionId"              = $script:AzContext.Subscription.SubscriptionId
        "SubscriptionName"            = $script:AzContext.Subscription.SubscriptionId
        "State"                       = $script:AzContext.Subscription.State
        "Environment"                 = $script:AzContext.Environment
        "TenantId"                    = $script:AzContext.Subscription.TenantId
        "Account"                     = $script:AzContext.Account
        "Detail"                      = ConvertTo-DetailView -InputObject $script:AzContextDetailTable
    }
    $script:Report += "<h3>Subscription</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzContextTable)
}

function Save-AzProviderFeatureTable{
    $script:AzProviderFeatureTable = @()
    $script:AzProviderFeature | foreach{
        $script:AzProviderFeatureDetail = [PSCustomObject]@{
            "FeatureName"                 = $_.FeatureName
            "ProviderName"                = $_.ProviderName
            "RegistrationState"           = $_.RegistrationState
        }
        $script:AzProviderFeatureDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzProviderFeatureDetail)

        $script:AzProviderFeatureTable += [PSCustomObject]@{
            "FeatureName"                 = $_.FeatureName
            "ProviderName"                = $_.ProviderName
            "RegistrationState"           = $_.RegistrationState
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzProviderFeatureDetailTable
        }
    }
    $script:Report += "<h3>Provider Feature</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (Add-RegistrationStateColor(New-ResourceHTMLTable -InputObject $script:AzProviderFeatureTable))
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

function Save-AzureManagementHeader{
    $script:Report += "<a name=`"Management`"><h2>Management</h2></a>"
}

function Save-AzureSubscriptionHeader{
    $script:Report += "<a name=`"Sub`"><h2>Subscription Information</h2></a>"
}

function Save-AzureOperationHeader{
    $script:Report += "<a name=`"Ops`"><h2>Operation</h2></a> between $script:LogStartTime and $script:ExecutedDateString"
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

    Write-Log "Waiting: Save-AzureReportHeader"
    Save-AzureReportHeader
    Write-Log "Success: Save-AzureReportHeader" -Color Green
    
    Write-Log "Waiting: Save-AzureComputeHeader"
    Save-AzureComputeHeader
    Write-Log "Success: Save-AzureComputeHeader" -Color Green
        
    Write-Log "Waiting: Save-AzAvailabilitySetTable"
    Save-AzAvailabilitySetTable
    Write-Log "Success: Save-AzAvailabilitySetTable" -Color Green

    Write-Log "Waiting: Save-AzVmWindowsTable"
    Save-AzVmWindowsTable
    Write-Log "Success: Save-AzVmWindowsTable" -Color Green

    Write-Log "Waiting: Save-AzVmLinuxTable"
    Save-AzVmLinuxTable
    Write-Log "Success: Save-AzVmLinuxTable" -Color Green
    
    Write-Log "Waiting: Save-AzureStorageHeader"
    Save-AzureStorageHeader
    Write-Log "Success: Save-AzureStorageHeader" -Color Green
    
    Write-Log "Waiting: Save-AzStorageAccountTable"
    Save-AzStorageAccountTable
    Write-Log "Success: Save-AzStorageAccountTable" -Color Green
    
    Write-Log "Waiting: Save-AzDiskTable"
    Save-AzDiskTable
    Write-Log "Success: Save-AzDiskTable" -Color Green
  
    Write-Log "Waiting: Save-AzSnapshotTable"
    Save-AzSnapshotTable
    Write-Log "Success: Save-AzSnapshotTable" -Color Green
  
    Write-Log "Waiting: Save-AzImageTable"
    Save-AzImageTable
    Write-Log "Success: Save-AzImageTable" -Color Green

    Write-Log "Waiting: Save-AzRecoveryServiceVault"
    Save-AzRecoveryServicesVault
    Write-Log "Success: Save-AzRecoveryServiceVault" -Color Green
    
    Write-Log "Waiting: Save-AzureNetworkHeader"
    Save-AzureNetworkHeader
    Write-Log "Success: Save-AzureNetworkHeader" -Color Green
    
    Write-Log "Waiting: Save-AzVirtualNetworkTable"
    Save-AzVirtualNetworkTable
    Write-Log "Success: Save-AzVirtualNetworkTable" -Color Green
    
    Write-Log "Waiting: Save-AzVirtualNetworkGatewayTable"
    Save-AzVirtualNetworkGatewayTable
    Write-Log "Success: Save-AzVirtualNetworkGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzVirtualNetworkGatewayConnection"
    Save-AzVirtualNetworkGatewayConnection
    Write-Log "Success: Save-AzVirtualNetworkGatewayConnection" -Color Green
    
    Write-Log "Waiting: Save-AzLocalNetworkGatewayTable"
    Save-AzLocalNetworkGatewayTable
    Write-Log "Success: Save-AzLocalNetworkGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzApplicationGatewayTable"
    Save-AzApplicationGatewayTable
    Write-Log "Success: Save-AzApplicationGatewayTable" -Color Green

    Write-Log "Waiting: Save-AzExpressRouteCircuitTable"
    Save-AzExpressRouteCircuitTable
    Write-Log "Success: Save-AzExpressRouteCircuitTable" -Color Green
    
    Write-Log "Waiting: Save-AzRouteFilter"
    Save-AzRouteFilter
    Write-Log "Success: Save-AzRouteFilter" -Color Green
    
    Write-Log "Waiting: Save-AzLoadBalancerTable"
    Save-AzLoadBalancerTable
    Write-Log "Success: Save-AzLoadBalancerTable" -Color Green
    
    Write-Log "Waiting: Save-AzNetworkInterfaceTable"
    Save-AzNetworkInterfaceTable
    Write-Log "Success: Save-AzNetworkInterfaceTable" -Color Green
    
    Write-Log "Waiting: Save-AzPublicIpAddressTable"
    Save-AzPublicIpAddressTable
    Write-Log "Success: Save-AzPublicIpAddressTable" -Color Green

    Write-Log "Waiting: Save-AzNetworkSecurityGroupTable"
    Save-AzNetworkSecurityGroupTable
    Write-Log "Success: Save-AzNetworkSecurityGroupTable" -Color Green

    Write-Log "Waiting: Save-AzRouteTableTable"
    Save-AzRouteTableTable
    Write-Log "Success: Save-AzRouteTableTable" -Color Green

    Write-Log "Waiting: Save-AzDnsZoneTable"
    Save-AzDnsZoneTable
    Write-Log "Success: Save-AzDnsZoneTable" -Color Green

    Write-Log "Waiting: Save-AzureManagementHeader"
    Save-AzureManagementHeader
    Write-Log "Success: Save-AzureManagementHeader" -Color Green

    Write-Log "Waiting: Save-AzLogAnalytics"
    Save-AzLogAnalytics
    Write-Log "Success: Save-AzLogAnalytics" -Color Green

    Write-Log "Waiting: Save-AzureSubscriptionHeader"
    Save-AzureSubscriptionHeader
    Write-Log "Success: Save-AzureSubscriptionHeader" -Color Green
    
    Write-Log "Waiting: Save-AzContextTable"
    Save-AzContextTable
    Write-Log "Success: Save-AzContextTable" -Color Green
 
    Write-Log "Waiting: Save-AzRoleAssignmentTable"
    Save-AzRoleAssignmentTable
    Write-Log "Success: Save-AzRoleAssignmentTable" -Color Green
 
    Write-Log "Waiting: Save-AzRoleDefinitionTable"
    Save-AzRoleDefinitionTable
    Write-Log "Success: Save-AzRoleDefinitionTable" -Color Green

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