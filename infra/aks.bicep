@description('The name of the Managed Cluster resource.')
param clusterName string

@description('The location of AKS resource.')
param location string

@allowed([
  'prod'
  'dev'
])
param environment string

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

@description('Network policy used for building Kubernetes network.')
param networkPolicy string

@description('A CIDR notation IP range from which to assign service cluster IPs.')
param serviceCidr string

@description('Containers DNS server IP address.')
param dnsServiceIP string

resource acrpullrole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource networkcontributorrole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
}

resource acrlotteri 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: 'acr-lotteri'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
  tags: {}
}

resource akscluster 'Microsoft.ContainerService/managedClusters@2023-04-01' = {
  location: location
  name: 'aks-${clusterName}-${environment}'
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: enableRBAC
    dnsPrefix: 'aks-${clusterName}-${environment}'
    nodeResourceGroup: 'mc-${resourceGroup().name}'
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
        vnetSubnetID: vnet_aks.properties.subnets[0].id
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
}

resource vnet_aks 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-${clusterName}-${environment}'
  location: location
  properties: {
    subnets: [
      {
        name: 'snet-${clusterName}-${environment}'
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

resource aksacrroleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acrlotteri
  name: guid(acrlotteri.id, akscluster.id, acrpullrole.id)
  properties: {
    principalId: akscluster.properties.identityProfile.kubeletidentity.clientId
    roleDefinitionId: acrpullrole.id
    principalType: 'ServicePrincipal'
  }
}

resource aksvnetroleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: vnet_aks
  name: guid(vnet_aks.id, akscluster.id, networkcontributorrole.id)
  properties: {
    principalId: akscluster.identity.principalId
    roleDefinitionId: acrpullrole.id
    principalType: 'ServicePrincipal'
  }
}

output controlPlaneFQDN string = akscluster.properties.fqdn
