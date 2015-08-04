angular.module 'ngVendorMimeType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMimeType'
]
.provider 'httpRequestInterceptorVendorMimeType', ->
  @matchList = [/.*api.*/]
  @vendorMimeType = ''

  @setMatchList = (@matchList) ->

  @setVendorMimeType = (@vendorMimeType) ->

  @$get = ['$q', ($q) ->
    matchList = @matchList
    vendorMimeType = @vendorMimeType

    return (
      'request': (config) ->

        if vendorMimeType
          matches = false
          for pattern in matchList
            if config.url.match(pattern)
              matches = true

          if matches
            config.headers.Accept = vendorMimeType

        return config || $q.when(config)
    )
  ]
  return