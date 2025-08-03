param location string = 'eastus'
param adminUsername string
param adminPassword string

// Deploy VNet
module vnetModule '../../infra-modules/network/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    name: 'demoVNet'
    location: location
    addressPrefixes: ['10.0.0.0/16']
  }
}

// Deploy NSG
module nsgModule '../../infra-modules/network/nsg.bicep' = {
  name: 'nsgDeployment'
  params: {
    name: 'demoNSG'
    location: location
  }
}

// Deploy NIC for DC
module dcNicModule '../../infra-modules/network/nic.bicep' = {
  name: 'dcNicDeployment'
  params: {
    name: 'demo-dc-nic'
    location: location
    subnetId: vnetModule.outputs.vnetId
    nsgId: nsgModule.outputs.nsgId
  }
}

// Deploy NIC for AD Connect
module adConnectNicModule '../../infra-modules/network/nic.bicep' = {
  name: 'adConnectNicDeployment'
  params: {
    name: 'demo-adconnect-nic'
    location: location
    subnetId: vnetModule.outputs.vnetId
    nsgId: nsgModule.outputs.nsgId
  }
}

// Deploy DC VM
module dcVmModule '../../infra-modules/compute/vm.bicep' = {
  name: 'dcVmDeployment'
  params: {
    name: 'demo-dc'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: dcNicModule.outputs.nicId
  }
}

// Deploy AD Connect VM
module adConnectVmModule '../../infra-modules/compute/vm.bicep' = {
  name: 'adConnectVmDeployment'
  params: {
    name: 'demo-adconnect'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    nicId: adConnectNicModule.outputs.nicId
  }
}
