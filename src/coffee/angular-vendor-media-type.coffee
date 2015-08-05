angular.module 'ngVendorMimeType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMimeType'
]
.provider('httpRequestInterceptorVendorMimeType', ->

  class HttpRequestInterceptorVendorMimeTypeProvider

    constructor: ->
      @paths = [/.*api.*/]
      @mimeTypes = ['text/xml', 'application/xml', 'application/json']
      @mimeTypePattern = /([\s\w\d+-//*.]+)(:?;[\s\w\d+-//*.=])?/
      @vendorMimeType = ''
      @vendor

    setVendorMimeType: (@vendorMimeType) ->
    matchingRequests: (@paths) ->
    matchingMimeTypes: (@mimeTypes) ->
    withVendor: (@vendor) ->

    $get: ($q) ->
      paths = @paths
      mimeTypes = @mimeTypes
      mimeTypePattern = @mimeTypePattern
      vendorMimeType = @vendorMimeType

      extractMimeTypes = (header) ->
        return header.split(',').map((mime) ->
          if not mimeTypePattern.test mime
            return mime

          match = mimeTypePattern.exec mime
          return match[1].trim()
        )

      matchesPath = (url) ->
        for path in paths
          if url.match(path)
            return true

        return false

      matchesMimeTypes = (acceptMimeTypes) ->
        for mimeType in mimeTypes
          if acceptMimeTypes.indexOf(mimeType) > -1
            return true
        return false

      return (
        'request': (config) ->
          if vendorMimeType

            acceptMimeTypes = extractMimeTypes(config.headers.Accept)
            if matchesPath(config.url) && matchesMimeTypes(acceptMimeTypes)
              config.headers.Accept = vendorMimeType

          return config || $q.when(config)
      )

  return new HttpRequestInterceptorVendorMimeTypeProvider()
)