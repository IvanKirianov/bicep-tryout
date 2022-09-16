param location string
param firewallRulenName string

resource firewallrule 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' = {
  name: firewallRulenName
  location: location
  properties:  {
    customRules: [
        {
            name: 'AllowOnlyUA'
            priority: 10
            ruleType: 'MatchRule'
            action: 'Block'
            matchConditions: [
                {
                    matchVariables: [
                        {
                            variableName: 'RemoteAddr'
                        }
                    ]
                    operator: 'GeoMatch'
                    negationConditon: false
                    matchValues: [
                        'RU'
                        'BY'
                        'IN'
                        'MX'
                    ]
                    transforms: []
                }
            ]
        }
    ]
    policySettings: {
        requestBodyCheck: true
        maxRequestBodySizeInKb: 128
        fileUploadLimitInMb: 100
        state: 'Enabled'
        mode: 'Prevention'
    }
    managedRules: {
        managedRuleSets: [
            {
                ruleSetType: 'OWASP'
                ruleSetVersion: '3.1'
                ruleGroupOverrides: [
                    {
                        ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
                        rules: [
                            {
                                ruleId: '941320'
                                state: 'Disabled'
                            }
                            {
                                ruleId: '941160'
                                state: 'Disabled'
                            }
                            {
                                ruleId: '941150'
                                state: 'Disabled'
                            }
                        ]
                    }
                    {
                        ruleGroupName: 'REQUEST-931-APPLICATION-ATTACK-RFI'
                        rules: [
                            {
                                ruleId: '931130'
                                state: 'Disabled'
                            }
                        ]
                    }
                    {
                        ruleGroupName: 'REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION'
                        rules: [
                            {
                                ruleId: '943110'
                                state: 'Disabled'
                            }
                            {
                                ruleId: '943100'
                                state: 'Disabled'
                            }
                        ]
                    }
                ]
            }
        ]
        exclusions: []
    }
}
}


output id string = firewallrule.id
