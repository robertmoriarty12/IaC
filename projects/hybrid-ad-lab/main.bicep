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
}

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
  }
}

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
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        destinationPortRange: '3389'
      }
    ]
  }
}

module nic1 '../../infra-modules/network/nic.bicep' = {
  name: '${resourcePrefix}-dc-nic'
  params: {
    name: '${resourcePrefix}-dc-nic'
    location: location
    subnetId: vnet.outputs.subnetIds[0]
    nsgId: nsg.outputs.nsgId
  }
}

module vm1 '../../infra-modules/compute/vm.bicep' = {
  name: '${resourcePrefix}-dc-vm'
  params: {
    name: '${resourcePrefix}-dc'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: nic1.outputs.nicId
    tags: tags
  }
}
