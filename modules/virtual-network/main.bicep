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

@description('Networks to peer to this virtual network')
param peerNetworks {
  id: string
  allowVirtualNetworkAccess: bool?
  allowForwardedTraffic: bool?
  allowGatewayTransit: bool?
  useRemoteGateways: bool?
}[] = []

@description('Private DNS Zones to link to this virtual network')
param privateDnsZones {
  name: string
  registrationEnabled: bool?
}[] = []

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

  resource rPeerNetwork 'virtualNetworkPeerings@2023-09-01' = [for peer in peerNetworks: {
    name: split(peer.id, '/')[10]
    properties: {
      remoteVirtualNetwork: {
        #disable-next-line use-resource-id-functions
        id: peer.id
      }
      allowVirtualNetworkAccess: contains(peer, 'allowVirtualNetworkAccess') ? peer.allowVirtualNetworkAccess : true
      allowForwardedTraffic: contains(peer, 'allowForwardedTraffic') ? peer.allowForwardedTraffic : true
      allowGatewayTransit: contains(peer, 'allowGatewayTransit') ? peer.allowGatewayTransit : false
      useRemoteGateways: contains(peer, 'useRemoteGateways') ? peer.useRemoteGateways : false
    }
  }]
}

resource rPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in privateDnsZones: {
  name: zone.name
  location: 'global'
}]

resource rPrivateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (zone, i) in privateDnsZones: {
  name: rNetwork.name
  location: 'global'
  parent: rPrivateDnsZone[i]

  properties: {
    virtualNetwork: { id: rNetwork.id }
    registrationEnabled: contains(zone, 'registrationEnabled') ? zone.registrationEnabled : false
  }
}]

output oNetwork object = rNetwork
