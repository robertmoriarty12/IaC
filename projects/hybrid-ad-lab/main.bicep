param projectName string
param environment string
param location string

@description('Admin username for VMs')
param adminUsername string

@description('Admin password for VMs')
param adminPassword string

var resourcePrefix = '${projectName}-${environment}'

module vnet '../../infra-modules/network/vnet.bicep' = {
  name: '${resourcePrefix}-vnet'
  params: {
    name: '${resourcePrefix}-vnet'
    location: location
    addressPrefixes: ['10.0.0.0/16']
  }
}

module nsg '../../infra-modules/network/nsg.bicep' = {
  name: '${resourcePrefix}-nsg'
  params: {
    name: '${resourcePrefix}-nsg'
    location: location
  }
}

module nic1 '../../infra-modules/network/nic.bicep' = {
  name: '${resourcePrefix}-dc-nic'
  params: {
    name: '${resourcePrefix}-dc-nic'
    location: location
    subnetId: vnet.outputs.vnetId
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
  }
}
