angular.module 'ngVendorMimeType', []
.config ['$httpProvider', ($httpProvider) ->
  $httpProvider.interceptors.push 'httpRequestInterceptorVendorMimeType'
]
.provider('httpRequestInterceptorVendorMimeType', ->

  parseMimeTypes = (parser, mimeTypes) ->
    mimes = []
    if mimeTypes? and mimeTypes.length > 0
      for mimeType in mimeTypes
        mimes.push(parser.parse(mimeType))

    mimes

  append = (parts, value) ->
    if value?
      parts.push value

  class MimeType

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

  class MimeTypeParser

    constructor: (@pattern) ->

    parse: (mimeType) ->

      matches = @pattern.exec mimeType
      [type, subtype, parameters] = matches[1..3]

      new MimeType(type, subtype, parameters)

  class MimeTypeTransformer

    MIME_TYPE_SEPARATOR = '.'

    constructor: (@vendor, @useVersionParam) ->

    transform: (mimeType) ->

      [subtype, parameters] = [mimeType.subtype, mimeType.parameters]
      mimeType.subtype = toVendorString(@vendor, @useVersionParam) + '+' + subtype

      if @useVersionParam is true and @vendor?.version?
        params = []
        append params, '; version='
        append params, @vendor.version
        mimeType.parameters += params.join('')

      mimeType

    toVendorString = (vendor, useVersionParam) ->
      parts = []
      append parts, vendor?.name
      append parts, vendor?.application
      if useVersionParam is false and vendor?.version?
        parts.push 'v' + vendor.version

      parts.join MIME_TYPE_SEPARATOR

  class HeaderProcessor

    SEPARATOR = ','

    constructor: (parser, config) ->
      @parser = parser
      @config = config
      @transformer = new MimeTypeTransformer(config.vendor, config.useVersionParam)

    process: (header) ->
      unless header? and header
        return header

      headerMimeTypes = @extractMimeTypes header

      result = []
      for headerMimeType in headerMimeTypes
        mime = headerMimeType
        if @matchesMimeTypes headerMimeType
          mime = @transformer.transform headerMimeType

        result.push mime.toString()

      return result.join SEPARATOR

    extractMimeTypes: (header) ->
      return parseMimeTypes(@parser, header.split(SEPARATOR))

    matchesMimeTypes: (headerMimeType) ->
      for mimeType in @config.mimeTypes
        if mimeType.equal(headerMimeType)
          return true
      return false

  class HttpRequestInterceptorVendorMimeTypeProvider

    MIME_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\."=]*)*)/

    constructor: (@headers, @paths, @mimeTypes, @useVersionParam = false) ->

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
      parser = new MimeTypeParser(MIME_TYPE_PATTERN)

      headers = @headers
      paths = @paths
      mimeTypes = parseMimeTypes(parser, @mimeTypes)
      vendor = @vendor
      useVersionParam = @useVersionParam

      processor = new HeaderProcessor(parser, {
        mimeTypes: mimeTypes
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

  return new HttpRequestInterceptorVendorMimeTypeProvider(
    ['Accept', 'Content-Type'], [/.*/], ['text/xml', 'application/xml', 'application/json'])
)