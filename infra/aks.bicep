@description('The name of the Managed Cluster resource.')
param resourceName string

@description('The location of AKS resource.')
param location string

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string

@description('Disk size (in GiB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The version of Kubernetes.')
param kubernetesVersion string = '1.7.7'

@description('Network plugin used for building Kubernetes network.')
@allowed([
  'azure'
  'kubenet'
])
param networkPlugin string

@description('Boolean flag to turn on and off of RBAC.')
param enableRBAC bool = true

@description('Boolean flag to turn on and off of virtual machine scale sets')
param vmssNodePool bool = false

@description('Boolean flag to turn on and off of virtual machine scale sets')
param windowsProfile bool = false

@description('The name of the resource group containing agent pool nodes.')
param nodeResourceGroup string

@description('Auto upgrade channel for a managed cluster.')
@allowed([
  'none'
  'patch'
  'rapid'
  'stable'
  'node-image'
])
param upgradeChannel string

@description('An array of AAD group object ids to give administrative access.')
param adminGroupObjectIDs array = []

@description('Enable or disable Azure RBAC.')
param azureRbac bool = false

@description('Enable or disable local accounts.')
param disableLocalAccounts bool = false

@description('Enable private network access to the Kubernetes cluster.')
param enablePrivateCluster bool = false

@description('Boolean flag to turn on and off Azure Policy addon.')
param enableAzurePolicy bool = false

@description('Boolean flag to turn on and off secret store CSI driver.')
param enableSecretStoreCSIDriver bool = false

@description('Specify the name of the Azure Container Registry.')
param acrName string

@description('The name of the resource group the container registry is associated with.')
param acrResourceGroup string

@description('The unique id used in the role assignment of the kubernetes service to the container registry service. It is recommended to use the default value.')
param guidValue string = newGuid()

@description('Network policy used for building Kubernetes network.')
param networkPolicy string

@description('Resource ID of virtual network subnet used for nodes and/or pods IP assignment.')
param vnetSubnetID string

@description('A CIDR notation IP range from which to assign service cluster IPs.')
param serviceCidr string

@description('Containers DNS server IP address.')
param dnsServiceIP string

var resourcegroupName = resourceGroup().name

module aks_acr_rbac './modules/aks-acr-rbac.bicep' = {
  name: 'aks_acr_rbac'
  scope: resourceGroup()
  params: {
    reference_parameters_resourceName_2023_04_01_identityProfile_kubeletidentity_objectId: reference(resourceName, '2023-04-01')
    resourceId_parameters_acrResourceGroup_Microsoft_ContainerRegistry_registries_parameters_acrName: resourceId(resourcegroupName, 'Microsoft.ContainerRegistry/registries/', acrName)
    acrName: acrName
    guidValue: guidValue
  }
  dependsOn: [
    akscluster
    acr_aks
  ]
}

module acr_aks './modules/acr-aks.bicep' = {
  name: 'acr_aks'
  scope: resourceGroup()
  params: {
    location: location
    name: 'lotteri'
  }
}

resource akscluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  location: location
  name: resourceName
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: enableRBAC
    dnsPrefix: dnsPrefix
    nodeResourceGroup: nodeResourceGroup
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: 1
        enableAutoScaling: true
        minCount: 1
        maxCount: 1
        vmSize: 'Standard_B2ls_v2'
        osType: 'Linux'
        storageProfile: 'ManagedDisks'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        availabilityZones: []
        nodeLabels: {}
        nodeTaints: []
        enableNodePublicIP: false
        tags: {}
        vnetSubnetID: vnetSubnetID
      }
    ]
    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
      networkPolicy: networkPolicy
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
    }
    autoUpgradeProfile: {
      upgradeChannel: upgradeChannel
    }
    disableLocalAccounts: disableLocalAccounts
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
    }
    addonProfiles: {
      azurepolicy: {
        enabled: enableAzurePolicy
      }
      azureKeyvaultSecretsProvider: {
        enabled: enableSecretStoreCSIDriver
        config: null
      }
    }
  }
  tags: {}
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  dependsOn: [
    vnet_aks
  ]
}

module vnet_aks './modules/vnet-aks.bicep' = {
  name: 'vnet_aks'
  params: {
    name: 'rg-tj-lotteri-vnet'
    location: location
  }
}

module aks_vnet_rbac './modules/aks-vnet-rbac.bicep' = {
  name: 'aks_vnet_rbac'
  scope: resourceGroup(resourcegroupName)
  params: {
    reference_parameters_resourceName_2023_04_01_Full_identity_principalId: reference(resourceName, '2023-04-01', 'Full')
  }
  dependsOn: [
    akscluster
    vnet_aks
  ]
}

output controlPlaneFQDN string = akscluster.properties.fqdn
