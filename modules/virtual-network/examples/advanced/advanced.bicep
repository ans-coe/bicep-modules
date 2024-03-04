targetScope = 'resourceGroup'

param location string
param tags object
param resourcePrefix string

resource rNetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-${resourcePrefix}'
  location: location
  tags: tags
}

resource rRouteTable 'Microsoft.Network/routeTables@2023-09-01' = {
  name: 'rt-${resourcePrefix}'
  location: location
  tags: tags
}

resource rNatGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: 'ip-ngw-${resourcePrefix}'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ddosSettings: { protectionMode: 'VirtualNetworkInherited' }
    publicIPAllocationMethod: 'Static'
  }
}

resource rNatGateway 'Microsoft.Network/natGateways@2023-09-01' = {
  name: 'ngw-${resourcePrefix}'
  location: location
  tags: tags

  sku: {
    name: 'Standard'
    #disable-next-line BCP037 // False positive. Omitting this causes a change every time.
    tier: 'Regional'
  }
  properties: {
    publicIpAddresses: [
      { id: rNatGatewayPublicIp.id }
    ]
  }
}

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
        networkSecurityGroupId: rNetworkSecurityGroup.id
        routeTableId: rRouteTable.id
        natGatewayId: rNatGateway.id
      }
      {
        name: 'snet-pe'
        prefix: '10.0.123.64/27'
        serviceEndpoints: [
          { service: 'Microsoft.Storage' }
        ]
      }
      {
        name: 'snet-asp'
        prefix: '10.0.123.96/27'
        delegation: 'Microsoft.Web/serverFarms'
      }
    ]
    privateDnsZones: [
      { name: 'dev.local' }
      { name: 'dev2.local', registrationEnabled: true }
    ]
  }
}
