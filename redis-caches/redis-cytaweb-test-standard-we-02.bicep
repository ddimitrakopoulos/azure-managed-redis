param Redis_redis_cytaweb_test_standard_we_02_name string = 'redis-cytaweb-test-standard-we-02'

resource Redis_redis_cytaweb_test_standard_we_02_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_test_standard_we_02_name
  location: 'West Europe'
  tags: {
    'business unit': 'it'
    criticality: 'low'
    environment: 'test'
    workload: 'portal'
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
      maxclients: '1000'
      'maxmemory-reserved': '125'
      'maxfragmentationmemory-reserved': '125'
      'maxmemory-delta': '125'
    }
    updateChannel: 'Stable'
    zonalAllocationPolicy: 'Automatic'
    disableAccessKeyAuthentication: false
  }
}

resource Redis_redis_cytaweb_test_standard_we_02_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_standard_we_02_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_test_standard_we_02_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_standard_we_02_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_test_standard_we_02_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_standard_we_02_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_test_standard_we_02_name_pep_redis_cytaweb_test_we_02_f3b37c70_be8e_4a4b_a8d7_780ea9515dc5 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_standard_we_02_name_resource
  name: 'pep-redis-cytaweb-test-we-02.f3b37c70-be8e-4a4b-a8d7-780ea9515dc5'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
