(function() {
  angular.module('ngVendorMimeType', []).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('httpRequestInterceptorVendorMimeType');
    }
  ]).provider('httpRequestInterceptorVendorMimeType', function() {
    var HeaderProcessor, HttpRequestInterceptorVendorMimeTypeProvider, MimeType, MimeTypeParser, MimeTypeTransformer, append, parseMimeTypes;
    parseMimeTypes = function(parser, mimeTypes) {
      var i, len, mimeType, mimes;
      mimes = [];
      if ((mimeTypes != null) && mimeTypes.length > 0) {
        for (i = 0, len = mimeTypes.length; i < len; i++) {
          mimeType = mimeTypes[i];
          mimes.push(parser.parse(mimeType));
        }
      }
      return mimes;
    };
    append = function(parts, value) {
      if (value != null) {
        return parts.push(value);
      }
    };
    MimeType = (function() {
      function MimeType(type1, subtype1, parameters1) {
        this.type = type1;
        this.subtype = subtype1;
        this.parameters = parameters1;
      }

      MimeType.prototype.toString = function() {
        var result;
        result = [];
        append(result, this.type);
        append(result, '/');
        append(result, this.subtype);
        append(result, this.parameters);
        return result.join('');
      };

      MimeType.prototype.equal = function(other) {
        return other.type.trim() === this.type.trim() && other.subtype.trim() === this.subtype.trim();
      };

      return MimeType;

    })();
    MimeTypeParser = (function() {
      function MimeTypeParser(pattern) {
        this.pattern = pattern;
      }

      MimeTypeParser.prototype.parse = function(mimeType) {
        var matches, parameters, ref, subtype, type;
        matches = this.pattern.exec(mimeType);
        ref = matches.slice(1, 4), type = ref[0], subtype = ref[1], parameters = ref[2];
        return new MimeType(type, subtype, parameters);
      };

      return MimeTypeParser;

    })();
    MimeTypeTransformer = (function() {
      var MIME_TYPE_SEPARATOR, toVendorString;

      MIME_TYPE_SEPARATOR = '.';

      function MimeTypeTransformer(vendor1, useVersionParam1) {
        this.vendor = vendor1;
        this.useVersionParam = useVersionParam1;
      }

      MimeTypeTransformer.prototype.transform = function(mimeType) {
        var parameters, params, ref, ref1, subtype;
        ref = [mimeType.subtype, mimeType.parameters], subtype = ref[0], parameters = ref[1];
        mimeType.subtype = toVendorString(this.vendor, this.useVersionParam) + '+' + subtype;
        if (this.useVersionParam === true && (((ref1 = this.vendor) != null ? ref1.version : void 0) != null)) {
          params = [];
          append(params, '; version=');
          append(params, this.vendor.version);
          mimeType.parameters += params.join('');
        }
        return mimeType;
      };

      toVendorString = function(vendor, useVersionParam) {
        var parts;
        parts = [];
        append(parts, vendor != null ? vendor.name : void 0);
        append(parts, vendor != null ? vendor.application : void 0);
        if (useVersionParam === false && ((vendor != null ? vendor.version : void 0) != null)) {
          parts.push('v' + vendor.version);
        }
        return parts.join(MIME_TYPE_SEPARATOR);
      };

      return MimeTypeTransformer;

    })();
    HeaderProcessor = (function() {
      var SEPARATOR;

      SEPARATOR = ',';

      function HeaderProcessor(parser, config) {
        this.parser = parser;
        this.config = config;
        this.transformer = new MimeTypeTransformer(config.vendor, config.useVersionParam);
      }

      HeaderProcessor.prototype.process = function(header) {
        var headerMimeType, headerMimeTypes, i, len, mime, result;
        if (!((header != null) && header)) {
          return header;
        }
        headerMimeTypes = this.extractMimeTypes(header);
        result = [];
        for (i = 0, len = headerMimeTypes.length; i < len; i++) {
          headerMimeType = headerMimeTypes[i];
          mime = headerMimeType;
          if (this.matchesMimeTypes(headerMimeType)) {
            mime = this.transformer.transform(headerMimeType);
          }
          result.push(mime.toString());
        }
        return result.join(SEPARATOR);
      };

      HeaderProcessor.prototype.extractMimeTypes = function(header) {
        return parseMimeTypes(this.parser, header.split(SEPARATOR));
      };

      HeaderProcessor.prototype.matchesMimeTypes = function(headerMimeType) {
        var i, len, mimeType, ref;
        ref = this.config.mimeTypes;
        for (i = 0, len = ref.length; i < len; i++) {
          mimeType = ref[i];
          if (mimeType.equal(headerMimeType)) {
            return true;
          }
        }
        return false;
      };

      return HeaderProcessor;

    })();
    HttpRequestInterceptorVendorMimeTypeProvider = (function() {
      var MIME_TYPE_PATTERN;

      MIME_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\."=]*)*)/;

      function HttpRequestInterceptorVendorMimeTypeProvider(headers1, paths1, mimeTypes1, useVersionParam1) {
        this.headers = headers1;
        this.paths = paths1;
        this.mimeTypes = mimeTypes1;
        this.useVersionParam = useVersionParam1 != null ? useVersionParam1 : false;
      }

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.matchingRequests = function(paths1) {
        this.paths = paths1;
        return this;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.matchingMimeTypes = function(mimeTypes1) {
        this.mimeTypes = mimeTypes1;
        return this;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.withVendor = function(vendor1) {
        this.vendor = vendor1;
        return this;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.withVersionParam = function() {
        this.useVersionParam = true;
        return this;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.withoutVersionParam = function() {
        this.useVersionParam = false;
        return this;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.$get = function($q) {
        var headers, matchesPath, mimeTypes, parser, paths, processor, useVersionParam, vendor;
        parser = new MimeTypeParser(MIME_TYPE_PATTERN);
        headers = this.headers;
        paths = this.paths;
        mimeTypes = parseMimeTypes(parser, this.mimeTypes);
        vendor = this.vendor;
        useVersionParam = this.useVersionParam;
        processor = new HeaderProcessor(parser, {
          mimeTypes: mimeTypes,
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

      return HttpRequestInterceptorVendorMimeTypeProvider;

    })();
    return new HttpRequestInterceptorVendorMimeTypeProvider(['Accept', 'Content-Type'], [/.*/], ['text/xml', 'application/xml', 'application/json']);
  });

}).call(this);
