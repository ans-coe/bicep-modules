targetScope = 'subscription'

@description('The location to deploy resources to.')
param location string = deployment().location

param tags object
param resourcePrefix string

resource rResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourcePrefix}'
  location: location
}

module mNetworkSecurityGroup '../../main.bicep' = {
  scope: rResourceGroup
  name: 'nsg-${resourcePrefix}'
  params: {
    name: 'nsg-${resourcePrefix}'
    location: location
    tags: tags
    rules: {
      exampleRule: {
        access: 'Allow'
        direction: 'Inbound'
        protocol: 'TCP'
        priority: 100
        sourcePortRange: '22'
        destinationPortRange: '22'
        sourceAddressPrefix: '0.0.0.0/0'
        destinationAddressPrefix: '0.0.0.0/0'
      }
    }
  }
}
