param Redis_redis_cytaweb_dev_we_01_name string = 'redis-cytaweb-dev-we-01'

resource Redis_redis_cytaweb_dev_we_01_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_dev_we_01_name
  location: 'West Europe'
  tags: {
    workload: 'portal'
    'business unit': 'it'
    criticality: 'low'
    environment: 'dev'
  }
  properties: {
    redisVersion: '6.0'
    sku: {
      name: 'Standard'
      family: 'C'
      capacity: 1
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    redisConfiguration: {
      'maxmemory-reserved': '125'
      maxclients: '1000'
      'maxfragmentationmemory-reserved': '125'
      'maxmemory-delta': '125'
    }
    updateChannel: 'Stable'
    zonalAllocationPolicy: 'NoZones'
    disableAccessKeyAuthentication: false
  }
}

resource Redis_redis_cytaweb_dev_we_01_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_dev_we_01_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_dev_we_01_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_dev_we_01_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_dev_we_01_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_dev_we_01_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_dev_we_01_name_pep_Redis_redis_cytaweb_dev_we_01_name_88c5e20d_5df4_4d37_b9b3_1475f298a94a 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_dev_we_01_name_resource
  name: 'pep-${Redis_redis_cytaweb_dev_we_01_name}.88c5e20d-5df4-4d37-b9b3-1475f298a94a'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
