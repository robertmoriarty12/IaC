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

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: name
  location: location
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

// ✅ Simpler output for guaranteed compatibility
output subnetIds array = [
  for (subnet, i) in subnets: vnet.properties.subnets[i].id
]
