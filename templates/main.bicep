param rgName string = 'az-latency'
//param rgName string = 'az-latency-2'
param watcherRG string = 'NetworkWatcherRG'
param location string = 'westeurope'

param bastionVnetName string = 'bastionvnet'
param bastionVnetRange string = '172.18.0.0/16'
param bastionSubnetName string = 'AzureBastionSubnet'
param bastionSubnetRange string = '172.18.100.0/24'
param bastionSubnet2Name string = 'subnet2'
param bastionSubnet2Range string = '172.18.101.128/24'
param bastionSubnet3Name string = 'subnet3'
param bastionSubnet3Range string = '172.18.102.160/24'
var bastionVnetId = bastionvnet.outputs.vnetid
var bastionSubnetid = bastionvnet.outputs.subnet1id

param vnet1Name string = 'vnet1'
param vnet1Range string = '172.16.0.0/16'
param vnet1Subnet1Name string = 'subnet1'
param vnet1Subnet1Range string = '172.16.1.0/24'
param vnet1Subnet2Name string = 'subnet2'
param vnet1Subnet2Range string = '172.16.2.0/24'
param vnet1Subnet3Name string = 'subnet3'
param vnet1Subnet3Range string = '172.16.3.0/24'
var vnet1Id = vnet1.outputs.vnetid
var vnet1Subnet1id = vnet1.outputs.subnet1id
var vnet1Subnet2id = vnet1.outputs.subnet2id
var vnet1Subnet3id = vnet1.outputs.subnet3id

/*param vnet2Name string = 'vnet2'
param vnet2Range string = '172.17.0.0/16'
param vnet2Subnet1Name string = 'subnet1'
param vnet2Subnet1Range string = '172.17.1.0/24'
param vnet2Subnet2Name string = 'subnet2'
param vnet2Subnet2Range string = '172.17.2.0/24'
param vnet2Subnet3Name string = 'subnet3'
param vnet2Subnet3Range string = '172.17.3.0/24'
var vnet2Id = vnet2.outputs.vnetid
var vnet2Subnet1id = vnet2.outputs.subnet1id
var vnet2Subnet2id = vnet2.outputs.subnet2id
var vnet2Subnet3id = vnet2.outputs.subnet3id
*/
var vm1name = vm1.outputs.vmname
var vm2name = vm2.outputs.vmname
var vm3name = vm3.outputs.vmname

var vm1id = vm1.outputs.vmid
var vm2id = vm2.outputs.vmid
var vm3id = vm3.outputs.vmid

param vm1Name string = 'vm1'
param vm2Name string = 'vm2'
param vm3Name string = 'vm3'

targetScope = 'subscription'

param adminUsername string = 'AzureAdmin'

param adminPassword string = 'AZlatency-2024'

resource azrg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module vnet1 'vnet.bicep' = {
  name: 'vnet1'
  scope: azrg
  params: {
    location: location
    vnetName: vnet1Name
    vnetaddressrange: vnet1Range
    subnet1name: vnet1Subnet1Name
    subnet1range:vnet1Subnet1Range
    subnet2name:vnet1Subnet2Name
    subnet2range: vnet1Subnet2Range
    subnet3name: vnet1Subnet3Name
    subnet3range: vnet1Subnet3Range
  }
}

/*module vnet2 'vnet.bicep' = {
  name: 'vnet2'
  scope: azrg
  params: {
    location: location
    vnetName: vnet2Name
    vnetaddressrange: vnet2Range
    subnet1name: vnet2Subnet1Name
    subnet1range:vnet2Subnet1Range
    subnet2name:vnet2Subnet2Name
    subnet2range: vnet2Subnet2Range
    subnet3name: vnet2Subnet3Name
    subnet3range: vnet2Subnet3Range
  }
}*/

module bastionvnet 'vnet.bicep' = {
  name: 'bastionvnet'
  scope: azrg
  params: {
    location: location
    vnetName: bastionVnetName
    vnetaddressrange: bastionVnetRange
    subnet1name: bastionSubnetName
    subnet1range:bastionSubnetRange
    subnet2name:bastionSubnet2Name
    subnet2range: bastionSubnet2Range
    subnet3name: bastionSubnet3Name
    subnet3range: bastionSubnet3Range
  }
}

module vm1 'vm.bicep' = {
  name: 'vm1'
  scope: azrg
  params: {
    location: location
    vmName: vm1Name
    adminUser: adminUsername
    adminPw: adminPassword
    subnetId: vnet1Subnet1id
    availabilityZone: '1'
  }
}
module iisextvm1 'iisvmext.bicep' = {
  name: 'iisextvm1'
  scope: azrg
  dependsOn: [
    vm1
  ]
  params: {
    vmname: vm1Name
    location: location
  }
}
module vm2 'vm.bicep' = {
  name: 'vm2'
  scope: azrg
  params: {
    location: location
    vmName: vm2Name
    adminUser: adminUsername
    adminPw: adminPassword
    subnetId: vnet1Subnet2id
    availabilityZone: '2'
  }
}
module iisextvm2 'iisvmext.bicep' = {
  name: 'iisextvm2'
  scope: azrg
  dependsOn: [
    vm2
  ]
  params: {
    vmname: vm2Name
    location: location
  }
}

module vm3 'vm.bicep' = {
  name: 'vm3'
  scope: azrg
  params: {
    location: location
    vmName: vm3Name
    adminUser: adminUsername
    adminPw: adminPassword
    subnetId: vnet1Subnet3id
    availabilityZone: '3'
  }
}
module iisextvm3 'iisvmext.bicep' = {
  name: 'iisextvm3'
  scope: azrg
  dependsOn: [
    vm3
  ]
  params: {
    vmname: vm3Name
    location: location
  }
}

module bastion 'bastion.bicep' = {
  scope: azrg
  name: 'bastion'
  dependsOn: [
    bastionvnet
  ]
  params: {
    bastionSubnetid: bastionSubnetid
    location: location
  }
}


module peerb1 'vnetpeering.bicep' ={
  scope: azrg
  name: 'peerb1'
  dependsOn: [
    bastionvnet
    vnet1
  ]
  params: {
    vnet1Name: vnet1Name
    vnet2Name: bastionVnetName
    vnet1id: vnet1Id
    vnet2id: bastionVnetId
  }
}

module peer1b 'vnetpeering.bicep' ={
  scope: azrg
  name: 'peer1b'
  dependsOn: [
    bastionvnet
    vnet1
  ]
  params: {
    vnet2Name: vnet1Name
    vnet1Name: bastionVnetName
    vnet2id: vnet1Id
    vnet1id: bastionVnetId
  }
}

/*module peerb2 'vnetpeering.bicep' ={
  scope: azrg
  name: 'peerb2'
  dependsOn: [
    bastionvnet
    vnet2
  ]
  params: {
    vnet1Name: vnet2Name
    vnet2Name: bastionVnetName
    vnet1id: vnet2Id
    vnet2id: bastionVnetId
  }
}
module peer2b 'vnetpeering.bicep' ={
  scope: azrg
  name: 'peer2b'
  dependsOn: [
    bastionvnet
    vnet2
  ]
  params: {
    vnet2Name: vnet2Name
    vnet1Name: bastionVnetName
    vnet2id: vnet2Id
    vnet1id: bastionVnetId
  }
}
*/

module conmon 'conmon.bicep' = {
scope: resourceGroup(watcherRG)
name: 'conmon'
dependsOn:[
  vm1
  vm2
  vm3
  iisextvm1
  iisextvm2
  iisextvm3
]
params: {
  location: location
  watcherName: 'NetworkWatcher_${location}'
  mainRG: rgName
  
  vm1name: vm1name
  vm2name: vm2name
  vm3name: vm3name

  vm1id: vm1id 
  vm2id: vm2id
  vm3id: vm3id
}

}

