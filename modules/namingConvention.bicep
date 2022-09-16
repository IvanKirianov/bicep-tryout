@maxLength(8)
param appName string
param function string
@allowed([
  'dev'
  'test'
  'staging'
  'prod'
])

param environment string
param index int

var functionShort = length(function) > 5 ? substring(function,0,5) : function
var appNameShort = length(appName) > 5 ? substring(appName,0,5) : appName

var resourceNamePlaceHolder = '${appName}-${environment}-${function}-[PH]-${padLeft(index,2,'0')}'
var resourceNameShortPlaceHolder = '${appName}-${environment}-${functionShort}-[PH]-${padLeft(index,2,'0')}'

var dbNamePlaceHolder = '${appName}${environment}${functionShort}psql${padLeft(index,2,'0')}'
var storageAccountNamePlaceHolder = '${appName}${environment}${functionShort}sta${padLeft(index,2,'0')}'
var vmNamePlaceHolder = '${appNameShort}-${environment}-${functionShort}-${padLeft(index,2,'0')}'
var networkSecurityGroupNamePlaceHolder = '${appName}${environment}${functionShort}-nsg${padLeft(index,2,'0')}'

output resourceName string = resourceNamePlaceHolder
output resourceNameShort string = resourceNameShortPlaceHolder
output storageAccountName string = storageAccountNamePlaceHolder
output dbName string = dbNamePlaceHolder
output networkSecurityGroupName string = networkSecurityGroupNamePlaceHolder
output vmName string = vmNamePlaceHolder

