@description('Location for all resources')
param location string = 'centralus'

@description('SQL Server name (must be globally unique)')
param sqlServerName string

@description('SQL administrator username')
param sqlAdminUsername string = 'sqladminuser'

@description('SQL administrator password')
@secure()
param sqlAdminPassword string

@description('SQL Database name')
param sqlDatabaseName string = 'mydatabase'


//
// SQL Server
//
resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
  }
}

//
// SQL Database
//
resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: sqlDatabaseName
  parent: sqlServer
  location: location
  sku: {
    name: 'GP_S_Gen5_1'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648
  }
  }


//
// Firewall rule to allow Azure services
//
resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
  name: 'AllowAzureServices'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

//
// Firewall rule to allow client's public IP
//
resource allowClientIP 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
  name: 'AllowClientIP'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}



// adding information about the azure webapp service

@description('The name of the App Service plan')
param appServicePlanName string 

@description('The name of the Web App')
param webAppName string 

//
// App Service Plan (Linux)
//
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1' // Basic tier
    tier: 'Basic'
    size: 'B1'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    reserved: true // Required for Linux
  }
}


// Web App for Node.js with connection string
//
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location

  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'
      appSettings: [
        {
          name: 'DB_CONNECTION_STRING'
          value: 'Server=tcp:${sqlServer.name}.database.windows.net,1433;Initial Catalog=${sqlDatabase.name};User ID=${sqlAdminUsername};Password=${sqlAdminPassword};Encrypt=true;Connection Timeout=30;'
        }
      ]
    }
    httpsOnly: true
  }
}



