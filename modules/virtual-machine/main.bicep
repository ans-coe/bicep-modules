targetScope = 'resourceGroup'

@description('The location of created resources.')
param location string

@description('Name of the virtual machine')
param name string

@description('Tags applied to created resources.')
param tags object = {}

@description('Computer name of the virtual machine')
param computerName string

@description('Virtual Machine Size')
param vmSize string

@description('Admin username to use')
param adminUsername string

@description('Admin password to use')
@secure()
param adminPassword string

@description('Subnet ID')
param subnetID string

@description('Image Publisher')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('Image Offer')
param imageOffer string = 'WindowsServer'

@description('Image Sku')
param imageSku string = '2019-datacenter'

@description('Image Version')
param imageVersion string = 'latest'

@description('OS Disk Storage Account Type')
param osDiskStorageAccountType string = 'Standard_LRS'

resource rNetworkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${name}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetID
          }
        }
      }
    ]
  }
}

resource rVirtualMachine 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: osDiskStorageAccountType
        }
      }
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: rNetworkInterface.id
        }
      ]
    }
  }
}

output virtualMachineName string = rVirtualMachine.name
