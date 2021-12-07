{
    "transportLibrary": {
        "platformClientId": "${platform_client_id}",
        "platformClientSecret": "${platform_client_secret}"
    },
    "database": {
        "connectionString": "${mongodb_uri}",
        "dbName": "enmeshed-db"
    },
    "infrastructure": {
        "httpServer": {
            "enabled": true,
            "cors": {
                "origin": false
            },
            "apiKey": "${api_key}"
        }
    },
    "modules": {
        "sync": {
            "enabled": true,
            "interval": 60
        },
        "autoAcceptRelationshipCreationChanges": {
            "enabled": false,
            "responseContent": {}
        },
        "coreHttpApi": {
            "enabled": true,
            "docs": {
                "enabled": true
            }
        },
        "webhooks": {
            "enabled": true,
            "url": "https://${api_url}/enmeshed/webhook",
            "headers": {
                "X-API-KEY": "${api_key}"
            },
            "publishInterval": 30
        }
    }
}
