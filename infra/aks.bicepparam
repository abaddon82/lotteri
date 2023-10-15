using 'aks.bicep'

param clusterName = 'lotteri'

param environment = 'dev'

param location = 'norwayeast'

param kubernetesVersion = '1.28.0'

param networkPlugin = 'azure'

param enableRBAC = true

param upgradeChannel = 'patch'

param adminGroupObjectIDs = []

param disableLocalAccounts = false

param azureRbac = false

param enablePrivateCluster = false

param enableAzurePolicy = false

param enableSecretStoreCSIDriver = false

param vmssNodePool = true

param serviceCidr = '10.0.0.0/16'

param dnsServiceIP = '10.0.0.10'

param networkPolicy = 'calico'
