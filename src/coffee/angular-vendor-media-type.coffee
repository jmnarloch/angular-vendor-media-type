angular.module 'ngVendorMimeType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMimeType'
]
.provider('httpRequestInterceptorVendorMimeType', ->

  class MediaTypeTransformer

    MIME_TYPE_SEPARATOR = '.'
    MIME_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\."=]*)*)/

    constructor: (vendor, useVersionParam) ->
      @vendor = vendor
      @useVersionParam = useVersionParam
      @vendorMimeType = toString(vendor, useVersionParam)

    transform: (mediaType) ->

      matches = MIME_TYPE_PATTERN.exec mediaType
      [type, subtype, parameters] = matches[1..3]
      result = []
      append result, type
      append result, '/'
      append result, @vendorMimeType
      append result, '+'
      append result, subtype
      append result, parameters

      if @useVersionParam is true and @vendor?.version?
        append result, '; version='
        append result, @vendor.version

      result.join('')

    toString = (vendor, useVersionParam) ->
      parts = []
      append parts, vendor?.name
      append parts, vendor?.application
      if useVersionParam is false and vendor?.version?
        parts.push 'v' + vendor.version

      parts.join MIME_TYPE_SEPARATOR

    append = (parts, value) ->
      if value?
        parts.push value

  class AcceptHeaderProcessor

    SEPARATOR = ','

    constructor: (config) ->
      @config = angular.extend((
        mimeTypePattern: /([\s\w\d+\-\/\*\.]+)((:?;[\s\w\d+\-*\.=])*)/
      ), config)
      @transformer = new MediaTypeTransformer(@config.vendor,
        config.useVersionParam
      )

    process: (header) ->
      if not header?
        return header

      headerMimeTypes = @extractMimeTypes header

      result = []
      for headerMimeType in headerMimeTypes
        mime = headerMimeType
        if @matchesMimeTypes headerMimeType
          mime = @transformer.transform headerMimeType

        result.push mime

      return result.join SEPARATOR

    extractMimeTypes: (header) ->
      return header.split(SEPARATOR)

    matchesMimeTypes: (headerMimeType) ->
      mimeTypePattern = @config.mimeTypePattern
      if not mimeTypePattern.test headerMimeType
        return false

      match = mimeTypePattern.exec headerMimeType
      type = match[1].trim()

      for mimeType in @config.mimeTypes
        if mimeType == type
          return true
      return false

  class HttpRequestInterceptorVendorMimeTypeProvider

    constructor: (paths, mimeTypes) ->
      @paths = paths
      @mimeTypes = mimeTypes
      @useVersionParam = false

    matchingRequests: (@paths) -> @
    matchingMimeTypes: (@mimeTypes) -> @
    withVendor: (@vendor) -> @
    withVersionParam: () ->
      @useVersionParam = true
      @
    withoutVersionParam: () ->
      @useVersionParam = false
      @

    $get: ($q) ->
      paths = @paths
      mimeTypes = @mimeTypes
      vendor = @vendor
      useVersionParam = @useVersionParam

      processor = new AcceptHeaderProcessor(
        mimeTypes: mimeTypes
        vendor: vendor
        useVersionParam: useVersionParam
      )

      matchesPath = (url) ->
        for path in paths
          if url.match(path)
            return true

        return false

      return (
        'request': (config) ->
          if angular.isDefined vendor and matchesPath config.url

            config.headers.Accept = processor.process config.headers.Accept
            config.headers['Content-Type'] = processor.process config.headers['Content-Type']

          return config or $q.when(config)
      )

  return new HttpRequestInterceptorVendorMimeTypeProvider([/.*/], ['text/xml', 'application/xml', 'application/json'])
)