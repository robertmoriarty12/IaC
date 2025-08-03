@description('Name of the Network Security Group')
param name string

@description('Location for the NSG')
param location string

@description('Array of security rules')
param securityRules array = [
  {
    name: 'AllowRDP'
    priority: 1000
    direction: 'Inbound'
    access: 'Allow'
    protocol: 'Tcp'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    destinationPortRange: '3389'
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: name
  location: location
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        priority: rule.priority
        access: rule.access
        direction: rule.direction
        protocol: rule.protocol
        sourceAddressPrefix: rule.sourceAddressPrefix
        destinationAddressPrefix: rule.destinationAddressPrefix
        destinationPortRange: rule.destinationPortRange
      }
    }]
  }
}

output nsgId string = nsg.id
