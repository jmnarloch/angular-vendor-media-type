angular.module 'ngVendorMimeType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMimeType'
]
.provider('httpRequestInterceptorVendorMimeType', ->

  class AcceptHeaderProcessor

    SEPARATOR = ','

    constructor: (config) ->
      @config = angular.extend((
        mimeTypePattern: /([\s\w\d+-//*.]+)(:?;[\s\w\d+-//*.=])?/,
      ), config)

    process: (header) ->
      headerMimeTypes = @extractMimeTypes(header)

      if @matchesMimeTypes(headerMimeTypes)
        return @config.vendorMimeType

      return header

    extractMimeTypes: (header) ->
      mimeTypePattern = @config.mimeTypePattern

      return header.split(SEPARATOR).map((mime) ->
        if not mimeTypePattern.test mime
          return mime

        match = mimeTypePattern.exec mime
        return match[1].trim()
      )

    matchesMimeTypes: (headerMimeTypes) ->
      for mimeType in @config.mimeTypes
        if headerMimeTypes.indexOf(mimeType) > -1
          return true
      return false

  class HttpRequestInterceptorVendorMimeTypeProvider

    constructor: (paths, mimeTypes) ->
      @paths = paths
      @mimeTypes = mimeTypes

    setVendorMimeType: (@vendorMimeType) ->
    matchingRequests: (@paths) ->
    matchingMimeTypes: (@mimeTypes) ->
    withVendor: (@vendor) ->

    $get: ($q) ->
      paths = @paths
      mimeTypes = @mimeTypes
      vendorMimeType = @vendorMimeType
      vendor = @vendor

      processor = new AcceptHeaderProcessor(
        mimeTypes: mimeTypes
        vendorMimeType: vendorMimeType
        vendor: vendor
      )

      matchesPath = (url) ->
        for path in paths
          if url.match(path)
            return true

        return false

      return (
        'request': (config) ->
          if (vendorMimeType || angular.isDefined(vendor)) && matchesPath(config.url)

            value = processor.process(config.headers.Accept)
            config.headers.Accept = value

          return config || $q.when(config)
      )

  return new HttpRequestInterceptorVendorMimeTypeProvider([/.*/], ['text/xml', 'application/xml', 'application/json'])
)