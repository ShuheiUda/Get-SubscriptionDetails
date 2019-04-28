

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
    $script:Report += "<h3>DNS Zones</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzureRmDnsZoneTable)
}