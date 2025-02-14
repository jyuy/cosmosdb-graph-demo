targetScope = 'subscription'

// General parameters
@description('specify location')
param location string

@allowed([
  'dev'
  'tst'
  'prod'
])
@description('Specifies the environment of the deployment.')
param environment string = 'dev'

@minLength(2)
@maxLength(10)
@description('Specifies the prefix for all resources created in this deployment.')
param prefix string

@description('The primary replica region for the Cosmos DB account.')
param primaryRegion string

@description('The secondary replica region for the Cosmos DB account.')
param secondaryRegion string

@description('Cosmos database name')
param databaseName string = 'database01'

@description('Gremlin container name')
param graphName string = 'graph01'

@description('Maximum autoscale throughput for the graph')
@minValue(400)
@maxValue(20000)
param maxThroughput int

param partitionKey string

@description('Ip address of the client accessing Synapse resource')
param clientIp string

@description('SQL Admin password')
param sqlAdminPassword string

var name = toLower('${prefix}-${environment}')

resource demoResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${name}-rg'
  location: location
}

module cosmos 'modules/cosmos.bicep' = {
  scope: demoResourceGroup
  name: 'cosmosdb'
  params: {
    location: location
    primaryRegion: primaryRegion
    secondaryRegion: secondaryRegion
    maxThroughput: maxThroughput
    partitionKey: partitionKey
    databaseName: databaseName
    graphName: graphName
  }
}

module search 'modules/search.bicep' = {
  scope: demoResourceGroup
  name: 'search'
  params: {
    location: location
  }
}

module spark 'modules/synapse.bicep' = {
  scope: demoResourceGroup
  name: 'synapse'
  params: {
    location: location
    clientIp: clientIp
    sqlAdminPassword: sqlAdminPassword
  }
}

module registry 'modules/acr.bicep' = {
  scope: demoResourceGroup
  name: 'registry'
  params: {
    location: location
  }
}
