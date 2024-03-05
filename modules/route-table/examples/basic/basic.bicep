targetScope = 'subscription'

@description('The location to deploy resources to.')
param location string = deployment().location

param tags object
param resourcePrefix string

resource rResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourcePrefix}'
  location: location
}

module mRouteTable '../../main.bicep' = {
  scope: rResourceGroup
  name: 'rt-${resourcePrefix}'
  params: {
    name: 'rt-${resourcePrefix}'
    location: location
    tags: tags
    routes: {
      route1: {
        addressPrefix: '10.1.0.0/16'
        nextHopType: 'VnetLocal'
      }
    }
  }
}
