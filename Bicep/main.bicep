// Parameters for reusability
param resourceGroupName string = 'my-example-rg'
param location string = 'East US'
param storageAccountName string

// Create a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

// Create a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
  tags: {
    environment: 'dev'
  }
  dependsOn: [
    resourceGroup
  ]
}

// Outputs
output resourceGroupId string = resourceGroup.id
output storageAccountId string = storageAccount.id
