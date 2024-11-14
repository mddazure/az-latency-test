param vnetName string
param location string

param vnetaddressrange string
param subnet1name string
param subnet1range string
param subnet2name string
param subnet2range string
param subnet3name string
param subnet3range string

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' =  {
  name: vnetName
  location: location
  properties:{
    addressSpace:{
      addressPrefixes:[
        vnetaddressrange       
      ]
    }
    subnets:[
      {
      name: subnet1name
      properties:{
        addressPrefix: subnet1range
        networkSecurityGroup: {
          id: nsg.id
          } 
        }
      }
      {
        name: subnet2name
        properties:{
          addressPrefix: subnet2range
          networkSecurityGroup: {
            id: nsg.id
            }
        }
      }
      {
        name: subnet3name
        properties:{
          addressPrefix: subnet3range
          networkSecurityGroup: {
            id: nsg.id
            }
        }
      }
    ]
  }
}
resource nsg 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: '${vnetName}-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-TCP-in'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 100
          description: 'Allow TCP'
          }
        }
        {
        name: 'Allow-TCP-out'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Outbound'
          priority: 200
          description: 'Allow TCP'
          }
        }
        {  
        name: 'Allow-ICMP-in'
        properties: {
          protocol: 'ICMP'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Inbound'
          priority: 120
          description: 'Allow ICMP'
          }
        }
        {
        name: 'Allow-ICMP-out'
        properties: {
          protocol: 'ICMP'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          direction: 'Outbound'
          priority: 220
          description: 'Allow ICMP'
          }
        }
      ]
    } 
}









output vnetid string = vnet.id
output subnet1id string = vnet.properties.subnets[0].id
output subnet2id string = vnet.properties.subnets[1].id
output subnet3id string = vnet.properties.subnets[2].id
