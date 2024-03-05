targetScope = 'resourceGroup'

@description('The location of created resources.')
param location string = resourceGroup().location

@description('Tags applied to created resources.')
param tags object = {}

@description('The name of the route table.')
param name string

type routesType = {
  *: {
    addressPrefix: string
    nextHopType: string? 
    nextHopIpAddress: string?
  }
}

@description('Routes to add to the route table')
param routes routesType = {}

resource rRouteTable 'Microsoft.Network/routeTables@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    routes: [for route in items(routes) : {
      name: route.key
      properties: {
        addressPrefix: route.value.addressPrefix
        nextHopIpAddress: contains(route.value, 'nextHopIpAddress') ? route.value.nextHopIpAddress : null
        #disable-next-line BCP321
        nextHopType: contains(route.value, 'nextHopType') ? route.value.nextHopType : 'VirtualAppliance'
      }
    }]
  }
}

@description('The resource group the route table was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the route table.')
output name string = rRouteTable.name

@description('The resource ID of the route table.')
output resourceId string = rRouteTable.id

@description('The location the resource was deployed into.')
output location string = rRouteTable.location
