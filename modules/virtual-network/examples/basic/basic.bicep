targetScope = 'resourceGroup'

param location string
param tags object
param resourcePrefix string

module mNetwork '../../main.bicep' = {
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
