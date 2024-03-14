# Bicep - Azurerm Network Security Group - Basic

This example deploys a Network Security Group with some basic configuration to a resource group with Bicep.

To run:

Deploy with a what-if: `az deployment sub create -l 'uksouth' --confirm-with-what-if --template-file basic.bicep --parameters basic.bicepparam`

On deletion, remove the resource group with `az group delete --name rg-nsg-bas-demo-uks-01`.
