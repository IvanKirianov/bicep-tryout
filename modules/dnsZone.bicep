param dnsZoneName string
param location string = resourceGroup().location
param appNameWeb string
param appNameGeo string
param appNameApi string
param publicIpAddress string

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: dnsZoneName
  location: location
  properties:{
    zoneType: 'Public'
  }
}

resource dnsARecordWeb 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: appNameWeb
  parent: dnsZone
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: publicIpAddress
      }
    ]
  }
}

resource dnsARecordGeo 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: appNameGeo
  parent: dnsZone
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: publicIpAddress
      }
    ]
  }
}

resource dnsARecordApi 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: appNameApi
  parent: dnsZone
  properties: {
    TTL: 3600
    ARecords: [
      {
        ipv4Address: publicIpAddress
      }
    ]
  }
}
