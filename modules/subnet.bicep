param subnetName string
param subnetAddressPrefix string
param delegations array
param virtualNetworkName string

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2020-11-01'existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: subnetName
  parent: virtualnetwork
  properties:{
    addressPrefix: subnetAddressPrefix
    delegations: delegations
    }
  }
