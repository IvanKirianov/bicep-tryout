targetScope = 'subscription'

// REQUIRED PARAMETERS

@description('Required. Subscription GUID.')
param subscriptionId string = subscription().subscriptionId

@description('Required. ResourceGroup location.')
param location string = 'northeurope'

@description('Required. ResourceGroup Name.')
param targetResourceGroup string = 'rg-application-prod-ne'

@description('Required. Creating UTC for deployments.')
param deploymentNameSuffix string = utcNow()

// Build Options
/*
  First build, set buildKeyVault to true.

  After the initial build, import the required certificates to your keyvault.

  Once the certificate is imported:
  Set buildAppGateway value to true
  Set buildKeyVault to false
  Deploy main.bicep
*/

param buildKeyVault bool = false
param buildAppGateway bool = true


@description('Required. Resource Group name of virtual network if using existing vnet and subnet.')
param vNetResourceGroupName string = 'rg-application-prod-ne'

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param vNetAddressPrefixes array = [
  '172.19.0.0/16'
]

@description('Required. The Address Prefix of ASE.')
param aseSubnetAddressPrefix string = '172.19.1.0/24'

@description('Required. The Address Prefix of AppGw.')
param appGwSubnetAddressPrefix string = '172.19.0.0/24'

@description('Required. Array of Security Rules to deploy to the Network Security Group.')
param networkSecurityGroupSecurityRules array = [
  {
    name: 'Port_443'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: '100'
      direction: 'Inbound'
      sourcePortRanges: []
      destinationPortRanges: []
      sourceAddressPrefixes: []
      destinationAddressPrefixes: []
    }
  }
]


// Application Gateway Parameters
param sslCertificateName string = 'cert'

// DNS Zone Parameters
@description('DNS Zone Name')
param dnsZoneName string = 'application.com'

@description('Hostnames for DNS')
param hostnames array = [
  '*.${dnsZoneName}'
]
// APPLICATION GATEWAY PARAMETERS
@description('Integer containing port number')
param port int = 443

@description('Application gateway tier')
@allowed([
  'Standard'
  'WAF'
  'Standard_v2'
  'WAF_v2'
])
param tier string = 'WAF_v2'

@description('Application gateway sku')
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param sku string = 'WAF_v2'

@description('Capacity (instance count) of application gateway')
@minValue(1)
@maxValue(32)
param capacity int = 2

@description('Autoscale capacity (instance count) of application gateway')
@minValue(1)
@maxValue(32)
param autoScaleMaxCapacity int = 10

@description('Private IP Allocation Method')
param privateIPAllocationMethod string = 'Dynamic'

@description('Backend http setting protocol')
param protocol string = 'Https'

@description('Enabled/Disabled. Configures cookie based affinity.')
param cookieBasedAffinity string = 'Disabled'

@description('Pick Hostname From BackEndAddress Setting')
param pickHostNameFromBackendAddress bool = true

@description('Integer containing backend http setting request timeout')
param requestTimeout int = 20

param requireServerNameIndication bool = true

@description('Public IP Sku')
param publicIpSku string = 'Standard'

@description('Public IP Applocation Method')
param publicIPAllocationMethod string = 'Static'

@description('Enable HTTP/2 support')
param http2Enabled bool = true

@description('Request Routing Rule Type')
param requestRoutingRuleType string = 'Basic'

@description('Object containing Web Application Firewall configurations')
param webApplicationFirewall object = {
  enabled: true
  firewallMode: 'Prevention'
  ruleSetType: 'OWASP'
  ruleSetVersion: '3.1'
  // disabledRuleGroups: []
  // exclusions: []
  requestBodyCheck: true
  maxRequestBodySizeInKb: 128
  fileUploadLimitInMb: 100
}

// APPLICATION SERVICE ENVIRONMENT
@description('ASE kind | ASEV3 | ASEV2')
param aseKind string = 'ASEV3'

param aseLbMode string = 'Web, Publishing'

// NAMING CONVENTION RULES
/*
  These parameters are for the naming convention

  environment // FUNCTION or GOAL OF ENVIRONMENT
  function // FUNCTION or GOAL OF ENVIRONMENT
  index // STARTING INDEX NUMBER
  appName // APP NAME

  EXAMPLE RESULT: tier3-t-environment-vnet-01 // tier3{appName}, t[environment], environment{function}, VNET{abbreviation}, 01{index}

*/

// ENVIRONMENT

@allowed([
  'dev'
  'test'
  'staging'
  'prod'
])
param environment string = 'prod'

// FUNCTION or GOAL OF ENVIRONMENT

param function string = 'ne'

// STARTING INDEX NUMBER

param index int = 1

// APP NAME

param appName string = 'application'

// RESOURCE NAME CONVENTIONS WITH ABBREVIATIONS

var publicIpAddressNamingConvention = replace(names.outputs.resourceName, '[PH]', 'pip')
var privateDNSZoneNamingConvention = asev3.outputs.dnssuffix
var virtualNetworkNamingConvention = replace(names.outputs.resourceName, '[PH]', 'vnet')
var managedIdentityNamingConvention = replace(names.outputs.resourceName, '[PH]', 'mi')
var keyVaultNamingConvention= replace(names.outputs.resourceName, '[PH]', 'kv')
var aseSubnetNamingConvention = replace(names.outputs.resourceName, '[PH]', 'snet')
var appGwSubnetNamingConvention = replace(names.outputs.resourceName, '[PH]', 'appgw-snet')
var aseNamingConvention = replace(names.outputs.resourceName, '[PH]', 'ase')
var appServicePlanNamingConvention = replace(names.outputs.resourceName, '[PH]', 'sp')
var applicationGatewayNamingConvention = replace(names.outputs.resourceName, '[PH]', 'gw')
var networkSecurityGroupNamingConvention = replace(names.outputs.resourceName, '[PH]', 'nsg')
var appNamingConvention= replace(names.outputs.resourceName, '[PH]', 'web')
var webAppFqdnNamingConvention = '${appNamingConvention}.${aseNamingConvention}.appserviceenvironment.net'
var keyVaultSecretIdNamingConvention = 'https://${keyVaultNamingConvention}.vault.azure.net/secrets/${sslCertificateName}'

var aseSubnet = [
  {
    name: replace(names.outputs.resourceName, '[PH]', 'snet')
    addressPrefix: aseSubnetAddressPrefix
    delegations: [
      {
        name: 'Microsoft.Web.hostingEnvironments'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroupName: networkSecurityGroupNamingConvention
  }
]

module rg 'modules/resourceGroup.bicep' = {
  name: 'resourceGroup-deployment-${deploymentNameSuffix}'
  scope: subscription(subscriptionId)
  params: {
    name: targetResourceGroup
    location: location
    tags: {}
  }
}

module names 'modules/namingConvention.bicep' = {
  name: 'naming-convention-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    environment: environment
    function: function
    index: index
    appName: appName
  }
  dependsOn: [
    rg
  ]
}


module msi 'modules/managedIdentity.bicep' = {
  name: 'managed-identity-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    managedIdentityName:managedIdentityNamingConvention
    location: location
  }
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(targetResourceGroup, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: msi.outputs.msiPrincipalId
  }
  dependsOn: [
    rg
    names
    msi
  ]
}



module keyvault 'modules/keyVault.bicep' = if (buildKeyVault == true) {
  name: 'keyvault-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    keyVaultName: keyVaultNamingConvention
    objectId: msi.outputs.msiPrincipalId
  }
  dependsOn: [
    rg
    names
    msi
  ]
}

module storage 'modules/storageAccount.bicep' = if (buildKeyVault == true) {
  name: 'storage-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    storageAccountName: names.outputs.storageAccountName
    storageAccountType: 'Standard_LRS'
  }
  dependsOn: [
    rg
    names
  ]
}

module postgresql 'modules/postgreSqlFlex.bicep' = if (buildKeyVault == true) {
  name: 'postgresql-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    psqlResourceName: names.outputs.dbName
    psqlLogin: 'psqadmin'
    psqlPassword: '3kY4#q3MzeTK'
    psqlDatabaseName: 'dbnametest'
    storageSizeGB: 128
    startIpAddressAse: '10.10.10.100'
    endIpAddressAse: '10.10.10.101'
  }
  dependsOn: [
    rg
    names
    keyvault
  ]
}


module nsg 'modules/nsg.bicep' =  {
  name: 'nsg-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    nsgName: networkSecurityGroupNamingConvention
    networkSecurityGroupSecurityRules: networkSecurityGroupSecurityRules
  }
  dependsOn: [
    rg
    names
  ]
}

module virtualnetwork 'modules/virtualNetwork.bicep' =  {
  name: 'vnet-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    virtualNetworkName: virtualNetworkNamingConvention
    vNetAddressPrefixes: vNetAddressPrefixes
    subnets: aseSubnet
  }
  dependsOn: [
    rg
    names
    nsg
  ]
}
module subnet 'modules/subnet.bicep' = {
  name: 'ase-subnet-delegation-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, vNetResourceGroupName)
  params: {
    virtualNetworkName: virtualNetworkNamingConvention
    subnetName: aseSubnetNamingConvention
    subnetAddressPrefix: aseSubnetAddressPrefix
    delegations: [
      {
        name: 'Microsoft.Web.hostingEnvironments'
        properties: {
          serviceName: 'Microsoft.Web/hostingEnvironments'
        }
      }
    ]
  }
  dependsOn: [
    virtualnetwork
    rg
    names
    nsg
  ]
}

module appgwSubnet 'modules/subnet.bicep' =  {
  name: 'appgw-subnet-delegation-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, vNetResourceGroupName)
  params: {
    virtualNetworkName: virtualNetworkNamingConvention
    subnetName: appGwSubnetNamingConvention
    subnetAddressPrefix: appGwSubnetAddressPrefix
    delegations: []
  }
  dependsOn: [
    virtualnetwork
    rg
    names
    nsg
    subnet
  ]
}
module asev3 'modules/appServiceEnvironment.bicep' = {
  name: 'ase-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    aseName: aseNamingConvention
    aseVnetId: virtualnetwork.outputs.vNetId
    aseSubnetName: aseSubnetNamingConvention
    kind: aseKind
    aseLbMode: aseLbMode
  }
  dependsOn: [
    virtualnetwork
    rg
    names
    nsg
    subnet
  ]
}

module appserviceplan 'modules/appServicePlan.bicep' = {
  name: 'app-serviceplan-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    appServicePlanName: appServicePlanNamingConvention
    hostingEnvironmentId: asev3.outputs.hostingid
  }
  dependsOn: [
    asev3
    rg
    names
    nsg
  ]
}

module privatednszone 'modules/privateDnsZone.bicep' = {
  name: 'private-dns-zone-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    privateDNSZoneName: privateDNSZoneNamingConvention
    virtualNetworkId: virtualnetwork.outputs.vNetId
    aseName: aseNamingConvention
  }
  dependsOn: [
    rg
    names
  ]
}

module web 'modules/webAppBehindASE.bicep' = {
  name: 'web-app-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    managedIdentityName: managedIdentityNamingConvention
    aseName: aseNamingConvention
    hostingPlanName: appServicePlanNamingConvention
    appName: '${appName}-${environment}-${function}-web-01'
  }
  dependsOn: [
    appserviceplan
    rg
    names
    nsg
  ]
}

module geo 'modules/webAppBehindASE.bicep' = {
  name: 'geo-app-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    managedIdentityName: managedIdentityNamingConvention
    aseName: aseNamingConvention
    hostingPlanName: appServicePlanNamingConvention
    appName: '${appName}-${environment}-${function}-geo-01'
  }
  dependsOn: [
    appserviceplan
    rg
    names
    nsg
  ]
}

module api 'modules/webAppBehindASE.bicep' = {
  name: 'api-app-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    managedIdentityName: managedIdentityNamingConvention
    aseName: aseNamingConvention
    hostingPlanName: appServicePlanNamingConvention
    appName: '${appName}-${environment}-${function}-api-01'
  }
  dependsOn: [
    appserviceplan
    rg
    names
    nsg
  ]
}


module applicationGateway 'modules/applicationGateway.bicep' = if (buildAppGateway) {
  name: 'applicationgateway-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    subscriptionId: subscriptionId
    resourceGroup: targetResourceGroup
    location: location
    applicationGatewayName: applicationGatewayNamingConvention
    vNetName: virtualNetworkNamingConvention
    subnetName: appGwSubnetNamingConvention
    webAppFqdn: webAppFqdnNamingConvention
    keyVaultSecretid: keyVaultSecretIdNamingConvention
    sslCertificateName: sslCertificateName
    managedIdentityName: managedIdentityNamingConvention
    hostnames: hostnames
    port: port
    tier: tier
    sku: sku
    capacity: capacity
    autoScaleMaxCapacity: autoScaleMaxCapacity
    privateIPAllocationMethod: privateIPAllocationMethod
    protocol: protocol
    cookieBasedAffinity: cookieBasedAffinity
    pickHostNameFromBackendAddress: pickHostNameFromBackendAddress
    requestTimeout: requestTimeout
    requireServerNameIndication: requireServerNameIndication
    publicIpAddressName: publicIpAddressNamingConvention
    publicIpSku: publicIpSku
    publicIPAllocationMethod: publicIPAllocationMethod
    http2Enabled: http2Enabled
    requestRoutingRuleType: requestRoutingRuleType
    firewallPolicyId: firewallRule.outputs.id
  }
  dependsOn: [
    rg
    names
    virtualnetwork
    subnet
    nsg
    appgwSubnet
    keyvault
    msi
    firewallRule
  ]
}


module firewallRule 'modules/firewallRule.bicep' = if (buildAppGateway) {
  name: 'firewallRule-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    location: location
    firewallRulenName: 'AllowUAOnly'
  }
  dependsOn: [
    rg
    names
    virtualnetwork
    subnet
    nsg
    appgwSubnet
    keyvault
    msi
  ]
}


module dnsZone 'modules/dnsZone.bicep' = if (buildAppGateway) {
  name: 'dnszone-deployment-${deploymentNameSuffix}'
  scope: resourceGroup(subscriptionId, targetResourceGroup)
  params: {
    dnsZoneName: dnsZoneName
    location: 'Global'
    appNameWeb: '${appName}-${environment}-${function}-web-01'
    appNameGeo: '${appName}-${environment}-${function}-geo-01'
    appNameApi: '${appName}-${environment}-${function}-api-01'
    publicIpAddress: buildAppGateway ? applicationGateway.outputs.publicIpAddress : ''
  }
  dependsOn: [
    asev3
    privatednszone
    virtualnetwork
    nsg
    applicationGateway
  ]
}
