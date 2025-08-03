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
module vnet '../../infra-modules/network/vnet.bicep' = {
  name: '${resourcePrefix}-vnet'
  params: {
    name: '${resourcePrefix}-vnet'
    location: location
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.0.0.0/24'
      }
    ]
    tags: tags
  }
}

// Network Security Group
module nsg '../../infra-modules/network/nsg.bicep' = {
  name: '${resourcePrefix}-nsg'
  params: {
    name: '${resourcePrefix}-nsg'
    location: location
    securityRules: [
      {
        name: 'AllowRDP'
        priority: 1000
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourceAddressPrefix: 'Internet'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    ]
    tags: tags
  }
}

// Public IPs for VMs
module dcPublicIp '../../infra-modules/network/publicip.bicep' = {
  name: '${resourcePrefix}-dc-pip'
  params: {
    name: '${resourcePrefix}-dc-pip'
    location: location
    tags: tags
  }
}

module defenderPublicIp '../../infra-modules/network/publicip.bicep' = {
  name: '${resourcePrefix}-defender-pip'
  params: {
    name: '${resourcePrefix}-defender-pip'
    location: location
    tags: tags
  }
}

// Network Interfaces
module dcNic '../../infra-modules/network/nic.bicep' = {
  name: '${resourcePrefix}-dc-nic'
  params: {
    name: '${resourcePrefix}-dc-nic'
    location: location
    subnetId: vnet.outputs.subnetIds[0]
    nsgId: nsg.outputs.nsgId
    publicIpId: dcPublicIp.outputs.publicIpId
    tags: tags
  }
}

module defenderNic '../../infra-modules/network/nic.bicep' = {
  name: '${resourcePrefix}-defender-nic'
  params: {
    name: '${resourcePrefix}-defender-nic'
    location: location
    subnetId: vnet.outputs.subnetIds[0]
    nsgId: nsg.outputs.nsgId
    publicIpId: defenderPublicIp.outputs.publicIpId
    tags: tags
  }
}

// Virtual Machines
module dcVm '../../infra-modules/compute/vm.bicep' = {
  name: '${resourcePrefix}-dc-vm'
  params: {
    name: '${resourcePrefix}-dc'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: dcNic.outputs.nicId
    vmSize: 'Standard_D2s_v3'
    tags: union(tags, {
      Role: 'DomainController'
    })
  }
}

module defenderVm '../../infra-modules/compute/vm.bicep' = {
  name: '${resourcePrefix}-defender-vm'
  params: {
    name: '${resourcePrefix}-defender'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: defenderNic.outputs.nicId
    vmSize: 'Standard_D4s_v3'
    tags: union(tags, {
      Role: 'DefenderForIdentity'
    })
  }
}

// Outputs
output vnetName string = vnet.outputs.vnetName
output dcVmName string = dcVm.name
output defenderVmName string = defenderVm.name
output dcPublicIpAddress string = dcPublicIp.outputs.publicIpAddress
output defenderPublicIpAddress string = defenderPublicIp.outputs.publicIpAddress
