@description('Project name')
param projectName string

@description('Deployment environment (dev, test, prod)')
param environment string

@description('Azure location for resources')
param location string

@description('Admin username for VMs')
param adminUsername string

@description('Admin password for VMs')
@secure()
param adminPassword string

var resourcePrefix = '${projectName}-${environment}'
var tags = {
  Project: projectName
  Environment: environment
  Owner: 'GitHubActions'
  Purpose: 'HybridADLab'
}

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: '${resourcePrefix}-vnet'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

// Network Security Group
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${resourcePrefix}-nsg'
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          priority: 1000
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

// Public IPs
resource dcPublicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: '${resourcePrefix}-dc-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource defenderPublicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: '${resourcePrefix}-defender-pip'
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// Network Interfaces
resource dcNic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${resourcePrefix}-dc-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: dcPublicIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource defenderNic 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${resourcePrefix}-defender-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: defenderPublicIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// Virtual Machines
resource dcVm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${resourcePrefix}-dc'
  location: location
  tags: union(tags, {
    Role: 'DomainController'
  })
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: '${resourcePrefix}-dc'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: dcNic.id
        }
      ]
    }
  }
}

resource defenderVm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: '${resourcePrefix}-defender'
  location: location
  tags: union(tags, {
    Role: 'DefenderForIdentity'
  })
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
    osProfile: {
      computerName: '${resourcePrefix}-defender'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: defenderNic.id
        }
      ]
    }
  }
}

// Outputs
output dcPublicIpAddress string = dcPublicIp.properties.ipAddress
output defenderPublicIpAddress string = defenderPublicIp.properties.ipAddress
