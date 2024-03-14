targetScope = 'subscription'

@description('The location to deploy resources to.')
param location string = deployment().location

param tags object
param resourcePrefix string

@secure()
param adminPassword string

resource rResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourcePrefix}'
  location: location
}

module mVirtualMachine '../../main.bicep' = {
  scope: rResourceGroup
  name: 'vm-${resourcePrefix}'
  params: {
    name: 'vm-${resourcePrefix}'
    computerName: 'vmexample'
    adminUsername: 'vmadmin'
    adminPassword: adminPassword
    location: location
    tags: tags
    subnetID: mExtraResources.outputs.oNetwork.properties.subnets[0].id
    vmSize: 'Standard_B2ms'
  }
}

/*
Extra Resources
*/

module mExtraResources 'extra_resources.bicep' = {
  scope: rResourceGroup
  name: 'vnet-${resourcePrefix}'
  params: {
    name: 'vnet-${resourcePrefix}'
    location: location
    tags: tags

    addressSpaces: [ '10.0.123.0/24' ]
    subnets: [
      {
        name: 'snet-default'
        prefix: '10.0.123.0/26'
      }
    ]
  }
}
