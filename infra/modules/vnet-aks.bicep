param name string
param location string

resource vnet_aks 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  properties: {
    subnets: [
      {
        name: 'default'
        // id: '/subscriptions/162af800-175c-415e-a4ae-93c1b4f4e082/resourceGroups/rg-tj-lotteri/providers/Microsoft.Network/virtualNetworks/rg-tj-lotteri-vnet/subnets/default'
        properties: {
          addressPrefix: '10.224.0.0/16'
        }
      }
    ]
    addressSpace: {
      addressPrefixes: [
        '10.224.0.0/12'
      ]
    }
  }
  tags: {}
}
