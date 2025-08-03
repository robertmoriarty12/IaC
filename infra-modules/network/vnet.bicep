@description('Name of the Virtual Network')
param name string

@description('Location of the Virtual Network')
param location string

@description('Address prefixes for the VNet')
param addressPrefixes array

@description('Array of subnets with name and addressPrefix')
param subnets array = [
  {
    name: 'default'
    addressPrefix: '10.0.0.0/24'
  }
]

@description('Tags to apply to the VNet')
param tags object = {}

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name

// More reliable subnet output
output subnetIds array = [for subnet in vnet.properties.subnets: subnet.id]
output subnetNames array = [for subnet in vnet.properties.subnets: subnet.name]
