angular.module 'ngVendorMimeType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMimeType'
]
.provider('httpRequestInterceptorVendorMimeType', ->

  class MediaTypeTransformer

    MEDIA_TYPE_SEPARATOR = '.'
    MEDIA_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\.=])*)/

    constructor: (vendor) ->
      @vendorMimeType = toString(vendor)

    transform: (mediaType) ->

      result = []
      matches = MEDIA_TYPE_PATTERN.exec mediaType
      type = matches[1]
      subtype = matches[2]
      parameters = matches[3]

      append(result, type)
      append(result, '/')
      append(result, @vendorMimeType)
      append(result, '+')
      append(result, subtype)
      append(result, parameters)

      result.join('')

    toString = (vendor) ->
      parts = []
      append(parts, vendor?.name)
      append(parts, vendor?.application)
      if vendor?.version
        parts.push('v' + vendor.version)

      parts.join(MEDIA_TYPE_SEPARATOR)

    append = (parts, value) ->
      if value?
        parts.push(value)

  class AcceptHeaderProcessor

    SEPARATOR = ','

    constructor: (config) ->
      @config = angular.extend((
        mimeTypePattern: /([\s\w\d+\-\/\*\.]+)((:?;[\s\w\d+\-*\.=])*)/
      ), config)
      @transformer = new MediaTypeTransformer(@config.vendor)

    process: (header) ->
      headerMimeTypes = @extractMimeTypes(header)

      result = []
      for headerMimeType in headerMimeTypes
        mime = headerMimeType
        if @matchesMimeTypes(headerMimeType)
          mime = @transformer.transform(headerMimeType)

        result.push(mime)

      return result.join(SEPARATOR)

    extractMimeTypes: (header) ->
      mimeTypePattern = @config.mimeTypePattern

      return header.split(SEPARATOR).map((mime) ->
        if not mimeTypePattern.test mime
          return mime

        match = mimeTypePattern.exec mime
        return match[1].trim()
      )

    matchesMimeTypes: (headerMimeType) ->
      for mimeType in @config.mimeTypes
        if headerMimeType == mimeType
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