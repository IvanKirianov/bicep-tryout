param location string = resourceGroup().location
param psqlResourceName string


param psqlLogin string
@secure()
param psqlPassword string
param psqlDatabaseName string
param storageSizeGB int
param startIpAddressAse string
param endIpAddressAse string

resource postgreSQL 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: psqlResourceName
  location: location
  properties: {
      administratorLogin: psqlLogin
      administratorLoginPassword: psqlPassword
      version: '13'
      availabilityZone: '1'
      storage: {
        storageSizeGB: storageSizeGB
    }
  }
  sku: {
      name: 'Standard_D2ds_v4'
      tier: 'GeneralPurpose'
  }
}


resource postgreSQLDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
  name: '${postgreSQL.name}/${psqlDatabaseName}'
}

resource firewallRules 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
    name: '${postgreSQL.name}/ase'
    properties: {
        startIpAddress: startIpAddressAse
        endIpAddress: endIpAddressAse
    }
  }

output fqdn string = postgreSQL.properties.fullyQualifiedDomainName
