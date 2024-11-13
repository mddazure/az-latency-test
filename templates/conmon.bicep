param location string
param watcherName string
param mainRG string
param vm1name string
param vm2name string
param vm3name string

param vm1id string
param vm2id string
param vm3id string

resource nwwatcher 'Microsoft.Network/networkWatchers@2022-07-01' existing = {
  name: watcherName
}

resource conmon 'Microsoft.Network/networkWatchers/connectionMonitors@2022-07-01' = {
  name: 'conmon-${mainRG}'
  parent: nwwatcher
  location: location
  properties: {
    endpoints: [
      {
        name: vm1name
        type: 'AzureVM'
        resourceId:vm1id
      }
      {
        name: vm2name
        type: 'AzureVM'
        resourceId:vm2id
      }
      {
        name: vm3name
        type: 'AzureVM'
        resourceId:vm3id
      }
    ]
    testConfigurations: [
      {
        name: 'tcp-test_networkTestConfig'
        testFrequencySec: 30
        protocol: 'Tcp'
        tcpConfiguration: {
          port: 3389
          disableTraceRoute: false
        }
        successThreshold: {}
      }
      {
        name: 'http-test'
        testFrequencySec: 30
        protocol: 'Http'
        httpConfiguration: {
          port: 80
          method: 'Get'
          requestHeaders: []
          validStatusCodeRanges:[]
          preferHTTPS: false
        }
        successThreshold:{}
      }
    ]
    testGroups: [
      {
        name: 'source1'
        disable: false
        testConfigurations:[
          'tcp-test_networkTestConfig'
          'http-test'
        ]
        sources:[
          vm1name
        ]
        destinations: [
          vm2name
          vm3name
        ]
      }
      /*{
        name: 'source2'
        disable: false
        testConfigurations:[
          'tcp-test_networkTestConfig'
          'http-test'
        ]
        sources:[
          vm2name
        ]
        destinations: [
          vm1name
          vm3name
        ]
      }
      {
        name: 'source3'
        disable: false
        testConfigurations:[
          'tcp-test_networkTestConfig'
          'http-test'
        ]
        sources:[
          vm3name
        ]
        destinations: [
          vm1name
          vm2name
        ]
      }*/
    ]
  }
}  





