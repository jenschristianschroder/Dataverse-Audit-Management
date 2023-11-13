param (
    [string] $tenantId = "", # Tenant Id
    [string] $clientId = "", # App Registration Client Id
    [string] $clientSecret = "", # App Registration Client Secret
    [string] $audit_configuration_path = "" # Path to audit configuration json file
)

# Get-AuthToken
function Get-AuthToken ($tenantId, $clientId, $clientSecret, $environmentUrl) {
    # Access Token Request
    $authBody = @{
        client_id = $clientId
        client_secret = $clientSecret
        scope = "$($environmentUrl)/.default"
        grant_type = 'client_credentials'
    }

    $authParams = @{
        URI = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
        Method = 'POST'
        ContentType = 'application/x-www-form-urlencoded'
        Body = $authBody
    }

    Invoke-RestMethod @authParams -ErrorAction Stop
}


# helper to turn PSCustomObject into a list of key/value pairs
function Get-ObjectMember {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key"}
    }
}

$environmentsConfiguration = Get-Content -Raw "$audit_configuration_path" | Out-String | ConvertFrom-Json

$environmentsConfiguration | Get-ObjectMember | ForEach-Object {
    $environments = $_.Value
    # loop environments in configuration file
    $environments | ForEach-Object {
        $environment = $_
        $environmentName = $environment.environmentName
        $environmentUrl = $environment.environmentUrl   
        Write-Host "Environment $environmentName ($environmentUrl)"
        Write-Host "- Updating environment settings"

        # authenticate to the environment
        $auth = Get-AuthToken $tenantId $clientId $clientSecret $environmentUrl

         # api endpoint for updating the environment settings
         $apiEndpoint = "$environmentUrl/api/data/v9.2/organizations($($_.organizationId))"

        # define the updated properties
        $updatedProperties = @{
            isauditenabled = $_.IsAuditEnabled
            auditretentionperiodv2 =  $_.AuditRetentionPeriodV2
            isuseraccessauditenabled =  $_.IsUserAccessAuditEnabled
            useraccessauditinginterval = $_.UserAccessAuditingInterval
        }

        Write-Host "- isauditenabled $($_.IsAuditEnabled)"
        Write-Host "- auditretentionperiodv2 $($_.AuditRetentionPeriodV2)"
        Write-Host "- isuseraccessauditenabled $($_.IsUserAccessAuditEnabled)"
        Write-Host "- useraccessauditinginterval $($_.UserAccessAuditingInterval)"

        # convert the properties to JSON
        $updatedPropertiesJson = $updatedProperties | ConvertTo-Json

        # update the environment audit settings
        Invoke-RestMethod -Uri $apiEndpoint -Method PATCH -Headers @{
            "Authorization" = "$($auth.token_type) $($auth.access_token)"
            "Content-Type" = "application/json; charset=utf-8"
        } -Body $updatedPropertiesJson


        # loop tables for environment
        $environment.tables | ForEach-Object {
            $table = $_
            $tableName = $table.logicalName

            # api endpoint for updating the table definition
            $apiEndpoint = "$environmentUrl/api/data/v9.2/EntityDefinitions(LogicalName='$tableName')"

            # define the updated properties
            $updatedProperties = @{
                IsAuditEnabled = @{
                    Value = $_.IsAuditEnabled
                    CanBeChanged = $true
                    ManagedPropertyLogicalName = "canmodifyauditsettings"
                }
                IsRetrieveAuditEnabled =  $_.IsRetrieveAuditEnabled
                IsRetrieveMultipleAuditEnabled =  $_.IsRetrieveMultipleAuditEnabled

            }

            # convert the properties to JSON
            $updatedPropertiesJson = $updatedProperties | ConvertTo-Json

            Write-Host "-- Table $tableName"
            Write-Host "-- Setting IsAuditEnabled to $($_.IsAuditEnabled)"
            Write-Host "-- Setting IsRetrieveAuditEnabled to $($_.IsRetrieveAuditEnabled)"
            Write-Host "-- Setting IsRetrieveMultipleAuditEnabled to $($_.IsRetrieveMultipleAuditEnabled)"

            # update the table definition
            Invoke-RestMethod -Uri $apiEndpoint -Method PUT -Headers @{
                "Authorization" = "$($auth.token_type) $($auth.access_token)"
                "Content-Type" = "application/json; charset=utf-8"
            } -Body $updatedPropertiesJson

            # loop columns for table 
            $table.columns | ForEach-Object {
                $fieldName = $_.logicalName
                $IsAuditEnabled = $_.IsAuditEnabled
                Write-Host "--- Column $($fieldName)"

                # get the column definition
                $apiEndpoint = "$environmentUrl/api/data/v9.2/EntityDefinitions(LogicalName='$tableName')/Attributes(LogicalName='$fieldName')"
                $fieldConfiguration = Invoke-RestMethod -Uri $apiEndpoint -Method GET -Headers @{
                    "Authorization" = "$($auth.token_type) $($auth.access_token)"
                    "Content-Type" = "application/json; charset=utf-8"
                }

                $fieldConfiguration.IsAuditEnabled.Value = $IsAuditEnabled
                $fieldConfigurationJson = $fieldConfiguration | ConvertTo-Json

                Write-Host "--- Setting IsAuditEnabled to $($fieldConfiguration.IsAuditEnabled.Value)"

                # update the column definition
                $apiEndpoint = "$environmentUrl/api/data/v9.2/EntityDefinitions(LogicalName='$tableName')/Attributes(LogicalName='$fieldName')"
                $fieldConfiguration = Invoke-RestMethod -Uri $apiEndpoint -Method PUT -Headers @{
                    "Authorization" = "$($auth.token_type) $($auth.access_token)"
                    "Content-Type" = "application/json; charset=utf-8"
                } -Body $fieldConfigurationJson


            }
            Write-Host "`n"

        }

    }
}