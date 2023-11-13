# PowerShell script to manage Dataverse Audit configuration

A PowerShell script to help manage Dataverse Audit configuration at scale

## Supported configuration

The script supports the following configurations:
- **Environments** (https://learn.microsoft.com/en-us/power-apps/developer/data-platform/auditing/configure?tabs=webapi#configure-organization-settings)
    - **IsAuditEnabled** - Whether auditing is enabled for the environment
    - **AuditRetentionPeriodV2** - The number of days to retain audit log records
    - **IsUserAccessAuditEnabled** - Whether user access logging is enabled
    - **UserAccessAuditingInterval** - How often user access is logged, in hours
    - **Tables** (https://learn.microsoft.com/en-us/power-apps/developer/data-platform/auditing/configure?tabs=webapi#configure-tables-and-columns)
        - **IsAuditEnabled** - Whether auditing is enabled for the table
        - **IsRetrieveAuditEnabled** - Whether auditing is enabled for retrieving a record
        - **IsRetrieveMultipleAuditEnabled** - Whether auditing is enabled for retrieving multiple records 
        - **Columns** (https://learn.microsoft.com/en-us/power-apps/developer/data-platform/auditing/configure?tabs=webapi#configure-tables-and-columns)
            - **IsAuditEnabled** - Whether auditing is enabled for the column


## Audit Configuration file

The script reads the audit configuration from a json file with the following format:
``` json
{
    "environments" : [
        {
            "environmentName" : "[name of environment]",
            "environmentId" : "[Id of environment]",
            "organizationId" : "[Id of the organization]",
            "environmentUrl" : "[Url of the environment]",
            "IsAuditEnabled" : true,
            "AuditRetentionPeriodV2" : 30,
            "IsUserAccessAuditEnabled" : true,
            "UserAccessAuditingInterval" : 5,
            "tables" : [
                {
                    "logicalName" : "[Table logical name]",
                    "IsAuditEnabled" : false,
                    "IsRetrieveAuditEnabled" : false,
                    "IsRetrieveMultipleAuditEnabled": false,
                    "columns" : [
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        },
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        }
                    ]
                },
                {
                    "logicalName" : "[Table logical name]",
                    "IsAuditEnabled" : false,
                    "IsRetrieveAuditEnabled" : false,
                    "IsRetrieveMultipleAuditEnabled": false,
                    "columns" : [
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        },
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        }
                    ]
                }
            ]
        },
        {
            "environmentName" : "[name of environment]",
            "environmentId" : "[Id of environment]",
            "organizationId" : "[Id of the organization]",
            "environmentUrl" : "[Url of the environment]",
            "IsAuditEnabled" : true,
            "AuditRetentionPeriodV2" : 30,
            "IsUserAccessAuditEnabled" : true,
            "UserAccessAuditingInterval" : 5,
            "tables" : [
                {
                    "logicalName" : "[Table logical name]",
                    "IsAuditEnabled" : false,
                    "IsRetrieveAuditEnabled" : false,
                    "IsRetrieveMultipleAuditEnabled": false,
                    "columns" : [
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        },
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        }
                    ]
                },
                {
                    "logicalName" : "[Table logical name]",
                    "IsAuditEnabled" : false,
                    "IsRetrieveAuditEnabled" : false,
                    "IsRetrieveMultipleAuditEnabled": false,
                    "columns" : [
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        },
                        {
                            "logicalName" : "[Column logical name]",
                            "IsAuditEnabled" : false
                        }
                    ]
                }
            ]
        }
    ]
}
```

## Running the script

To run the script you must supply the following parameters

- **TenantId** - The id of your tenant or the fully qualified domain name of your tenant
- **Client Id** - The client id of the application registration used to authenticate to the environment
- **Client Secret** - The client secret of the application registration used to authenticate to the environment
- **Audit Configuration Path** - The path to the json file with the audit configuration 

``` ps1
PS C:\> .\audit_configuration.ps1 domain.onmicrosoft.com 73cxxxxx-xxxx-xxxx-xxxx-xxxxxxxxc31b Q~HhJxxxxxxxxxxxxxxxxxxxxxxxxxuoN5_GLcVX audit_configuration.json
```