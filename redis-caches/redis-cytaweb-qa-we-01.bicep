param Redis_redis_cytaweb_qa_we_01_name string = 'redis-cytaweb-qa-we-01'

resource Redis_redis_cytaweb_qa_we_01_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_qa_we_01_name
  location: 'West Europe'
  tags: {
    'business unit': 'it'
    criticality: 'medium'
    environment: 'qa'
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
      'aad-enabled': 'true'
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

resource Redis_redis_cytaweb_qa_we_01_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_we_01_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_qa_we_01_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_we_01_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_qa_we_01_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_we_01_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_qa_we_01_name_pep_Redis_redis_cytaweb_qa_we_01_name_10ea3636_adfc_4414_b2d3_d3f85ad05da0 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_we_01_name_resource
  name: 'pep-${Redis_redis_cytaweb_qa_we_01_name}.10ea3636-adfc-4414-b2d3-d3f85ad05da0'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
