targetScope = 'resourceGroup'

@description('The location of created resources.')
param location string = resourceGroup().location

@description('Tags applied to created resources.')
param tags object = {}

@description('The name of the virtual network.')
param name string

@description('The address spaces of the virtual network.')
param addressSpaces array

@description('The DNS servers to use with this virtual network.')
param dnsServers array = []

@description('Subnets to create in this virtual network with the map name indicating the subnet name.')
param subnets {
  name: string
  prefix: string
  serviceEndpoints: {
    service: string
  }[]?
  networkSecurityGroupId: string?
  routeTableId: string?
  natGatewayId: string?
  delegation: string?
}[]

resource rNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: name
  location: location
  tags: tags

  properties: {
    addressSpace: { addressPrefixes: addressSpaces }
    dhcpOptions: { dnsServers: dnsServers }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.prefix
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : null
        #disable-next-line use-resource-id-functions
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') ? { id: subnet.networkSecurityGroupId } : null
        #disable-next-line use-resource-id-functions
        routeTable: contains(subnet, 'routeTableId') ? { id: subnet.routeTableId } : null
        #disable-next-line use-resource-id-functions
        natGateway: contains(subnet, 'natGatewayId') ? { id: subnet.natGatewayId } : null
        delegations: contains(subnet, 'delegation') ? [ {
            #disable-next-line BCP321
            name: replace(subnet.delegation, '/', '.')
            properties: { serviceName: subnet.delegation }
          } ] : null
      }
    }]
  }
}

output oNetwork object = rNetwork
