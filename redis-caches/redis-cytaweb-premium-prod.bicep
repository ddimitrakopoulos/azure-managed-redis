param Redis_redis_cytaweb_premium_prod_name string = 'redis-cytaweb-premium-prod'

resource Redis_redis_cytaweb_premium_prod_name_resource 'Microsoft.Cache/Redis@2025-08-01-preview' = {
  name: Redis_redis_cytaweb_premium_prod_name
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
      maxclients: '7500'
      'maxmemory-reserved': '642'
      'maxfragmentationmemory-reserved': '642'
      'maxmemory-delta': '642'
      'zonal-configuration': '{\r\n  "preferredPrimaryZoneId": "1",\r\n  "zoneNodeTopology": {\r\n    "1": [\r\n      "0",\r\n      "3"\r\n    ],\r\n    "2": [\r\n      "1"\r\n    ],\r\n    "3": [\r\n      "2"\r\n    ]\r\n  }\r\n}'
    }
    replicasPerMaster: 3
    replicasPerPrimary: 3
    updateChannel: 'Stable'
    zonalAllocationPolicy: 'UserDefined'
    disableAccessKeyAuthentication: false
  }
}

resource Redis_redis_cytaweb_premium_prod_name_Data_Contributor 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_premium_prod_name_resource
  name: 'Data Contributor'
  properties: {
    permissions: '+@all -@dangerous +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_premium_prod_name_Data_Owner 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_premium_prod_name_resource
  name: 'Data Owner'
  properties: {
    permissions: '+@all allkeys'
  }
}

resource Redis_redis_cytaweb_premium_prod_name_Data_Reader 'Microsoft.Cache/Redis/accessPolicies@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_premium_prod_name_resource
  name: 'Data Reader'
  properties: {
    permissions: '+@read +@connection -client +client|caching +client|getname +client|getredir +client|id +client|list +client|reply +client|setinfo +client|setname +client|tracking +cluster|info +cluster|nodes +cluster|slots allkeys'
  }
}

resource Redis_redis_cytaweb_premium_prod_name_pe_Redis_redis_cytaweb_premium_prod_name_ee592302_2d3e_4182_907e_03146b1af47f 'Microsoft.Cache/Redis/privateEndpointConnections@2025-08-01-preview' = {
  parent: Redis_redis_cytaweb_premium_prod_name_resource
  name: 'pe-${Redis_redis_cytaweb_premium_prod_name}.ee592302-2d3e-4182-907e-03146b1af47f'
  properties: {
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      description: 'Auto-Approved'
      actionsRequired: 'None'
    }
  }
}
