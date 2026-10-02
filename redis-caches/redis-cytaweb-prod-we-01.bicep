param Redis_redis_cytaweb_prod_we_01_name string = 'redis-cytaweb-prod-we-01'

resource Redis_redis_cytaweb_prod_we_01_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_prod_we_01_name
  location: 'West Europe'
  tags: {
    'business unit': 'it'
    criticality: 'high'
    environment: 'prod'
    workload: 'portal'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    redisVersion: '6.0'
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    redisConfiguration: {
      'aad-enabled': 'true'
      maxclients: '7500'
      'maxmemory-reserved': '642'
      'maxfragmentationmemory-reserved': '642'
      'maxmemory-delta': '642'
      'zonal-configuration': '{\r\n  "preferredPrimaryZoneId": "3",\r\n  "zoneNodeTopology": {\r\n    "1": [\r\n      "0"\r\n    ],\r\n    "2": [\r\n      "1"\r\n    ],\r\n    "3": [\r\n      "2"\r\n    ]\r\n  }\r\n}'
    }
    replicasPerMaster: 2
    replicasPerPrimary: 2
    updateChannel: 'Stable'
    zonalAllocationPolicy: 'UserDefined'
    disableAccessKeyAuthentication: true
  }
}

resource Redis_redis_cytaweb_prod_we_01_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_prod_we_01_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_prod_we_01_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_prod_we_01_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_prod_we_01_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_prod_we_01_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_prod_we_01_name_pep_Redis_redis_cytaweb_prod_we_01_name_9dc860c8_d1c2_4bc2_9cb3_073cd20b2b51 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_prod_we_01_name_resource
  name: 'pep-${Redis_redis_cytaweb_prod_we_01_name}.9dc860c8-d1c2-4bc2-9cb3-073cd20b2b51'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
