function Save-AzDnsZoneTable{
    $script:AzDnsZoneTable = @()
    $script:AzDnsZone | foreach{
        $script:AzDnsRecordSet = $null
        $script:AzDnsRecordSet = Get-AzDnsRecordSet -ZoneName $_.Name -ResourceGroupName $_.ResourceGroupName
        $script:AzDnsRecordSetDetail = @()
        $script:AzDnsRecordSet | foreach{
            $script:AzDnsRecordSetDetail += [PSCustomObject]@{
                "Name"                      = $_.Name
                "ZoneName"                  = $_.ZoneName
                "RecordType"                = $_.RecordType
                "Ttl"                       = $_.Ttl
                "Records"                   = $_.Records -join ("<br>")
            }
        }
        $script:AzDnsRecordSetDetailTable = New-HTMLTable -InputObject $script:AzDnsRecordSetDetail

        $script:AzDnsZoneDetail = [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "NameServers"               = $_.NameServers -join "<br>"
            "NumberOfRecordSets"        = "$($_.NumberOfRecordSets) / $($_.MaxNumberOfRecordSets)"
            "RecordSet"                 = ConvertTo-DetailView -InputObject $script:AzDnsRecordSetDetailTable
        }
        $script:AzDnsZoneDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzDnsZoneDetail)

        $script:AzDnsZoneTable += [PSCustomObject]@{
            "Name"                      = $_.Name
            "ResourceGroupName"         = $_.ResourceGroupName
            "NameServers"               = $_.NameServers -join ", "
            "NumberOfRecordSets"        = "$($_.NumberOfRecordSets) / $($_.MaxNumberOfRecordSets)"
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzDnsZoneDetailTable
        }
    }
    $script:Report += "<h3>DNS Zones</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzDnsZoneTable)
}