# Bicep - Azurerm Route Table - Basic

This example deploys route table with some basic configuration to a resource group with Bicep.

To run:

Deploy with a what-if: `az deployment sub create -l 'uksouth' --confirm-with-what-if --template-file basic.bicep --parameters basic.bicepparam`

On deletion, remove the resource group with `az group delete --name rg-rt-bas-demo-uks-01`.
