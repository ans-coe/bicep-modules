# Bicep - Azurerm Virtual Network - Basic

This example deploys virtual network with some basic configuration to a resource group with Bicep.

To run:

1. Create the resource group: `az group create --location uksouth --name rg-vnet-demo`
2. Deploy with a what-if: `az deployment group create --resource-group rg-vnet-demo --confirm-with-what-if --template-file basic.bicep --parameters basic.bicepparam`

On deletion, remove the resource group with `az group delete --name rg-vnet-demo`.
