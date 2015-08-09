(function() {
  angular.module('ngVendorMediaType', []).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('httpRequestInterceptorVendorMediaType');
    }
  ]).provider('httpRequestInterceptorVendorMediaType', function() {
    var HeaderProcessor, HttpRequestInterceptorVendorMediaTypeProvider, MediaType, MediaTypeParser, MediaTypeTransformer, append;
    append = function(parts, value) {
      if (value != null) {
        return parts.push(value);
      }
    };
    MediaType = (function() {
      function MediaType(type1, subtype1, parameters1) {
        this.type = type1;
        this.subtype = subtype1;
        this.parameters = parameters1;
      }

      MediaType.prototype.toString = function() {
        var result;
        result = [];
        append(result, this.type);
        append(result, '/');
        append(result, this.subtype);
        append(result, this.parameters);
        return result.join('');
      };

      MediaType.prototype.equal = function(other) {
        return other.type.trim() === this.type.trim() && other.subtype.trim() === this.subtype.trim();
      };

      return MediaType;

    })();
    MediaTypeParser = (function() {
      function MediaTypeParser(pattern) {
        this.pattern = pattern;
      }

      MediaTypeParser.prototype.parse = function(mediaType) {
        var matches, parameters, ref, subtype, type;
        matches = this.pattern.exec(mediaType);
        ref = matches.slice(1, 4), type = ref[0], subtype = ref[1], parameters = ref[2];
        return new MediaType(type, subtype, parameters);
      };

      return MediaTypeParser;

    })();
    MediaTypeTransformer = (function() {
      var MEDIA_TYPE_SEPARATOR, toVendorString;

      MEDIA_TYPE_SEPARATOR = '.';

      function MediaTypeTransformer(vendor1, useVersionParam1) {
        this.vendor = vendor1;
        this.useVersionParam = useVersionParam1;
      }

      MediaTypeTransformer.prototype.transform = function(mediaType) {
        var parameters, params, ref, ref1, subtype;
        ref = [mediaType.subtype, mediaType.parameters], subtype = ref[0], parameters = ref[1];
        mediaType.subtype = toVendorString(this.vendor, this.useVersionParam) + '+' + subtype;
        if (this.useVersionParam === true && (((ref1 = this.vendor) != null ? ref1.version : void 0) != null)) {
          params = [];
          append(params, '; version=');
          append(params, this.vendor.version);
          mediaType.parameters += params.join('');
        }
        return mediaType;
      };

      toVendorString = function(vendor, useVersionParam) {
        var parts;
        parts = [];
        append(parts, vendor != null ? vendor.name : void 0);
        append(parts, vendor != null ? vendor.application : void 0);
        if (useVersionParam === false && ((vendor != null ? vendor.version : void 0) != null)) {
          parts.push('v' + vendor.version);
        }
        return parts.join(MEDIA_TYPE_SEPARATOR);
      };

      return MediaTypeTransformer;

    })();
    HeaderProcessor = (function() {
      var SEPARATOR, parseMediaTypes;

      SEPARATOR = ',';

      function HeaderProcessor(config) {
        this.config = config;
        this.parser = new MediaTypeParser(this.config.mediaTypePattern);
        this.transformer = new MediaTypeTransformer(this.config.vendor, this.config.useVersionParam);
        this.mediaTypes = parseMediaTypes(this.parser, this.config.mediaTypes);
      }

      HeaderProcessor.prototype.process = function(header) {
        var headerMediaType, headerMediaTypes, i, len, mediaType, result;
        if (!((header != null) && header)) {
          return header;
        }
        headerMediaTypes = this.extractMediaTypes(header);
        result = [];
        for (i = 0, len = headerMediaTypes.length; i < len; i++) {
          headerMediaType = headerMediaTypes[i];
          mediaType = headerMediaType;
          if (this.matchesMediaTypes(headerMediaType)) {
            mediaType = this.transformer.transform(headerMediaType);
          }
          result.push(mediaType.toString());
        }
        return result.join(SEPARATOR);
      };

      HeaderProcessor.prototype.extractMediaTypes = function(header) {
        return parseMediaTypes(this.parser, header.split(SEPARATOR));
      };

      HeaderProcessor.prototype.matchesMediaTypes = function(headerMediaType) {
        var i, len, mediaType, ref;
        ref = this.mediaTypes;
        for (i = 0, len = ref.length; i < len; i++) {
          mediaType = ref[i];
          if (mediaType.equal(headerMediaType)) {
            return true;
          }
        }
        return false;
      };

      parseMediaTypes = function(parser, mediaTypes) {
        var i, len, mediaType, types;
        types = [];
        if ((mediaTypes != null) && mediaTypes.length > 0) {
          for (i = 0, len = mediaTypes.length; i < len; i++) {
            mediaType = mediaTypes[i];
            types.push(parser.parse(mediaType));
          }
        }
        return types;
      };

      return HeaderProcessor;

    })();
    HttpRequestInterceptorVendorMediaTypeProvider = (function() {
      var MEDIA_TYPE_PATTERN;

      MEDIA_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\."=]*)*)/;

      function HttpRequestInterceptorVendorMediaTypeProvider(headers1, paths1, mediaTypes1, useVersionParam1) {
        this.headers = headers1;
        this.paths = paths1;
        this.mediaTypes = mediaTypes1;
        this.useVersionParam = useVersionParam1 != null ? useVersionParam1 : false;
      }

      HttpRequestInterceptorVendorMediaTypeProvider.prototype.matchingRequests = function(paths1) {
        this.paths = paths1;
        return this;
      };

      HttpRequestInterceptorVendorMediaTypeProvider.prototype.matchingMediaTypes = function(mediaTypes1) {
        this.mediaTypes = mediaTypes1;
        return this;
      };

      HttpRequestInterceptorVendorMediaTypeProvider.prototype.withVendor = function(vendor1) {
        this.vendor = vendor1;
        return this;
      };

      HttpRequestInterceptorVendorMediaTypeProvider.prototype.withVersionParam = function() {
        this.useVersionParam = true;
        return this;
      };

      HttpRequestInterceptorVendorMediaTypeProvider.prototype.withoutVersionParam = function() {
        this.useVersionParam = false;
        return this;
      };

      HttpRequestInterceptorVendorMediaTypeProvider.prototype.$get = function($q) {
        var headers, matchesPath, mediaTypes, paths, processor, useVersionParam, vendor;
        headers = this.headers;
        paths = this.paths;
        mediaTypes = this.mediaTypes;
        vendor = this.vendor;
        useVersionParam = this.useVersionParam;
        processor = new HeaderProcessor({
          mediaTypePattern: MEDIA_TYPE_PATTERN,
          mediaTypes: mediaTypes,
          vendor: vendor,
          useVersionParam: useVersionParam
        });
        matchesPath = function(url) {
          var i, len, path;
          for (i = 0, len = paths.length; i < len; i++) {
            path = paths[i];
            if (url.match(path)) {
              return true;
            }
          }
          return false;
        };
        return {
          'request': function(config) {
            var header, i, len;
            if (angular.isDefined(vendor) && matchesPath(config.url)) {
              for (i = 0, len = headers.length; i < len; i++) {
                header = headers[i];
                config.headers[header] = processor.process(config.headers[header]);
              }
            }
            return config || $q.when(config);
          }
        };
      };

      return HttpRequestInterceptorVendorMediaTypeProvider;

    })();
    return new HttpRequestInterceptorVendorMediaTypeProvider(['Accept', 'Content-Type'], [/.*/], ['text/xml', 'application/xml', 'application/json']);
  });

}).call(this);
