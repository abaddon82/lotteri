using 'aks.bicep' /*TODO: Provide a path to a bicep template*/

param resourceName = 'aks-lotteri-dev'

param location = 'norwayeast'

param dnsPrefix = 'aks-lotteri-dev'

param kubernetesVersion = '1.28.0'

param networkPlugin = 'azure'

param enableRBAC = true

param nodeResourceGroup = 'rg-tj-lotteri'

param upgradeChannel = 'patch'

param adminGroupObjectIDs = []

param disableLocalAccounts = false

param azureRbac = false

param enablePrivateCluster = false

param enableAzurePolicy = false

param enableSecretStoreCSIDriver = false

param vmssNodePool = true

param vnetSubnetID = '/subscriptions/162af800-175c-415e-a4ae-93c1b4f4e082/resourceGroups/rg-tj-lotteri/providers/Microsoft.Network/virtualNetworks/rg-tj-lotteri-vnet/subnets/default'

param serviceCidr = '10.0.0.0/16'

param dnsServiceIP = '10.0.0.10'

param networkPolicy = 'calico'

param acrName = 'lotteri'

param acrResourceGroup = 'rg-tj-lotteri'
