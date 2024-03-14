using 'basic.bicep'

param location = 'uksouth'
param tags = {
  module: 'vm'
  example: 'basic'
  usage: 'demo'
}
param resourcePrefix = 'vm-bas-demo-uks-01'
param adminPassword = 'super-secure-password9'
