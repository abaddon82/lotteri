param reference_parameters_resourceName_2023_04_01_Full_identity_principalId object

resource rg_tj_lotteri_vnet_default_Microsoft_Authorization_5fb491c7_9646_4b6c_b76a_1db2df651487 'Microsoft.Network/virtualNetworks/subnets/providers/roleAssignments@2018-09-01-preview' = {
  name: 'rg-tj-lotteri-vnet/default/Microsoft.Authorization/5fb491c7-9646-4b6c-b76a-1db2df651487'
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
    principalId: reference_parameters_resourceName_2023_04_01_Full_identity_principalId.identity.principalId
    principalType: 'ServicePrincipal'
    scope: '/subscriptions/162af800-175c-415e-a4ae-93c1b4f4e082/resourceGroups/rg-tj-lotteri/providers/Microsoft.Network/virtualNetworks/rg-tj-lotteri-vnet/subnets/default'
  }
}