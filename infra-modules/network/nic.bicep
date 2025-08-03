param name string
param location string
param subnetId string
param nsgId string

resource nic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

output nicId string = nic.id
