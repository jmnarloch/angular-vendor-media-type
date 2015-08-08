angular.module 'ngVendorMediaType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMediaType'
]
.provider('httpRequestInterceptorVendorMediaType', ->

  parseMediaTypes = (parser, mediaTypes) ->
    types = []
    if mediaTypes? and mediaTypes.length > 0
      for mediaType in mediaTypes
        types.push(parser.parse(mediaType))

    types

  append = (parts, value) ->
    if value?
      parts.push value

  class MediaType

    constructor: (@type, @subtype, @parameters) ->

    toString: () ->
      result = []
      append result, @type
      append result, '/'
      append result, @subtype
      append result, @parameters
      result.join('')

    equal: (other) ->
      return other.type.trim() == @type.trim() and
          other.subtype.trim() == @subtype.trim()

  class MediaTypeParser

    constructor: (@pattern) ->

    parse: (mediaType) ->

      matches = @pattern.exec mediaType
      [type, subtype, parameters] = matches[1..3]

      new MediaType(type, subtype, parameters)

  class MediaTypeTransformer

    MEDIA_TYPE_SEPARATOR = '.'

    constructor: (@vendor, @useVersionParam) ->

    transform: (mediaType) ->

      [subtype, parameters] = [mediaType.subtype, mediaType.parameters]
      mediaType.subtype = toVendorString(@vendor, @useVersionParam) + '+' + subtype

      if @useVersionParam is true and @vendor?.version?
        params = []
        append params, '; version='
        append params, @vendor.version
        mediaType.parameters += params.join('')

      mediaType

    toVendorString = (vendor, useVersionParam) ->
      parts = []
      append parts, vendor?.name
      append parts, vendor?.application
      if useVersionParam is false and vendor?.version?
        parts.push 'v' + vendor.version

      parts.join MEDIA_TYPE_SEPARATOR

  class HeaderProcessor

    SEPARATOR = ','

    constructor: (parser, config) ->
      @parser = parser
      @config = config
      @transformer = new MediaTypeTransformer(config.vendor, config.useVersionParam)

    process: (header) ->
      unless header? and header
        return header

      headerMediaTypes = @extractMediaTypes header

      result = []
      for headerMediaType in headerMediaTypes
        mediaType = headerMediaType
        if @matchesMediaTypes headerMediaType
          mediaType = @transformer.transform headerMediaType

        result.push mediaType.toString()

      return result.join SEPARATOR

    extractMediaTypes: (header) ->
      return parseMediaTypes(@parser, header.split(SEPARATOR))

    matchesMediaTypes: (headerMediaType) ->
      for mediaType in @config.mediaTypes
        if mediaType.equal(headerMediaType)
          return true
      return false

  class HttpRequestInterceptorVendorMediaTypeProvider

    MEDIA_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\."=]*)*)/

    constructor: (@headers, @paths, @mediaTypes, @useVersionParam = false) ->

    matchingRequests: (@paths) -> @
    matchingMediaTypes: (@mediaTypes) -> @
    withVendor: (@vendor) -> @
    withVersionParam: () ->
      @useVersionParam = true
      @
    withoutVersionParam: () ->
      @useVersionParam = false
      @

    $get: ($q) ->
      parser = new MediaTypeParser(MEDIA_TYPE_PATTERN)

      headers = @headers
      paths = @paths
      mediaTypes = parseMediaTypes(parser, @mediaTypes)
      vendor = @vendor
      useVersionParam = @useVersionParam

      processor = new HeaderProcessor(parser, {
        mediaTypes: mediaTypes
        vendor: vendor
        useVersionParam: useVersionParam
      })

      matchesPath = (url) ->
        for path in paths
          if url.match(path)
            return true

        return false

      return (
        'request': (config) ->
          if angular.isDefined(vendor) and matchesPath(config.url)
            for header in headers
              config.headers[header] = processor.process config.headers[header]

          return config or $q.when(config)
      )

  return new HttpRequestInterceptorVendorMediaTypeProvider(
    ['Accept', 'Content-Type'], [/.*/], ['text/xml', 'application/xml', 'application/json'])
)