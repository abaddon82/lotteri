param name string
param location string

resource lotteri 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: {}
}
