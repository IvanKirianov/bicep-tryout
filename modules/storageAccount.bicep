@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountType string
param location string = resourceGroup().location
param storageAccountName string = 'sta${uniqueString(resourceGroup().id)}'
param advancedThreatProtectionEnabled bool = true

resource sta 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {}
}

resource atpSettings 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = if (advancedThreatProtectionEnabled) {
  name: 'current'
  scope: sta
  properties: {
    isEnabled: true
  }
}

output storageAccountName string = storageAccountName
output storageAccountId string = sta.id
