function Save-AzRoleAssignmentTable{
    $script:AzRoleAssignmentTable = @()
    $script:AzRoleAssignment | foreach{
        $script:AzRoleAssignmentDetail = [PSCustomObject]@{
            "DisplayName"                 = $_.DisplayName
            "SignInName"                  = $_.SignInName
            "RoleDefinitionName"          = $_.RoleDefinitionName
            "RoleDefinitionId"            = $_.RoleDefinitionId
            "ObjectId"                    = $_.ObjectId
            "ObjectType"                  = $_.ObjectType
            "Scope"                       = $_.Scope
            "RoleAssignmentId"            = $_.RoleAssignmentId
        }
        $script:AzRoleAssignmentDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzRoleAssignmentDetail)

        $script:AzRoleAssignmentTable += [PSCustomObject]@{
            "DisplayName"                 = $_.DisplayName
            "SignInName"                  = $_.SignInName
            "RoleDefinitionName"          = $_.RoleDefinitionName
            "ObjectType"                  = $_.ObjectType
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzRoleAssignmentDetailTable
        }
    }
    $script:Report += "<h3>Role Assignment</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzRoleAssignmentTable)
}

function Save-AzRoleDefinitionTable{
    $script:AzRoleDefinitionTable = @()
    $script:AzRoleDefinition | foreach{
        $script:AzRoleDefinitionDetail = [PSCustomObject]@{
            "Name"                        = $_.Name
            "IsCustom"                    = $_.IsCustom
            "Description"                 = $_.Description
            "Actions"                     = $_.Actions -join "<br>"
            "NotActions"                  = $_.NotActions -join "<br>"
            "AssignableScopes"            = $_.AssignableScopes -join "<br>"
        }
        $script:AzRoleDefinitionDetailTable = New-HTMLTable -InputObject (ConvertTo-PropertyValue -InputObject $script:AzRoleDefinitionDetail)

        $script:AzRoleDefinitionTable += [PSCustomObject]@{
            "Name"                        = $_.Name
            "IsCustom"                    = $_.IsCustom
            "Description"                 = $_.Description
            "Detail"                    = ConvertTo-DetailView -InputObject $script:AzRoleDefinitionDetailTable
        }
    }
    $script:Report += "<h3>Role Definition(custom only)</h3>"
    $script:Report += ConvertTo-SummaryView -InputObject (New-ResourceHTMLTable -InputObject $script:AzRoleDefinitionTable)
}
