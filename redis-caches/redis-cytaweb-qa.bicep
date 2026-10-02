param Redis_redis_cytaweb_qa_name string = 'redis-cytaweb-qa'

resource Redis_redis_cytaweb_qa_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_qa_name
  location: 'West Europe'
  tags: {
    applicationName: 'CytaWeb'
    environment: 'qa'
    workload: 'portal'
    'business unit': 'it'
    criticality: 'medium'
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
      'maxmemory-reserved': '21'
      'maxfragmentationmemory-reserved': '21'
      'maxmemory-policy': 'volatile-lru'
      'maxmemory-delta': '21'
    }
    updateChannel: 'Stable'
    zonalAllocationPolicy: 'NoZones'
    disableAccessKeyAuthentication: false
  }
}

resource Redis_redis_cytaweb_qa_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_qa_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_qa_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_qa_name_1 'Microsoft.Cache/Redis/firewallRules@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_name_resource
  name: '1'
  properties: {
    startIP: '0.0.0.0'
    endIP: '255.255.255.255'
  }
}

resource Redis_redis_cytaweb_qa_name_pe_Redis_redis_cytaweb_qa_name_156e54f6_2308_4871_9ef8_08f8535af226 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_qa_name_resource
  name: 'pe-${Redis_redis_cytaweb_qa_name}.156e54f6-2308-4871-9ef8-08f8535af226'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
