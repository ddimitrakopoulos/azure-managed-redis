param Redis_redis_cytaweb_test_v6_name string = 'redis-cytaweb-test-v6'

resource Redis_redis_cytaweb_test_v6_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_test_v6_name
  location: 'West Europe'
  tags: {
    workload: 'portal'
    'business unit': 'it'
    criticality: 'low'
    environment: 'test'
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
      'maxmemory-policy': 'volatile-lru'
      'maxmemory-delta': '125'
    }
    updateChannel: 'Stable'
    zonalAllocationPolicy: 'NoZones'
    disableAccessKeyAuthentication: false
  }
}

resource Redis_redis_cytaweb_test_v6_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_v6_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_test_v6_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_v6_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_test_v6_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_v6_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_test_v6_name_Redis_redis_cytaweb_test_v6_name_private_endpoint_a6cbcc7e_1195_4993_91c9_a8b51521d042 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_test_v6_name_resource
  name: '${Redis_redis_cytaweb_test_v6_name}-private-endpoint.a6cbcc7e-1195-4993-91c9-a8b51521d042'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
