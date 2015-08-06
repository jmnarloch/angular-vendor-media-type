(function() {
  angular.module('ngVendorMimeType', []).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('httpRequestInterceptorVendorMimeType');
    }
  ]).provider('httpRequestInterceptorVendorMimeType', function() {
    var AcceptHeaderProcessor, HttpRequestInterceptorVendorMimeTypeProvider, MediaTypeTransformer;
    MediaTypeTransformer = (function() {
      var MEDIA_TYPE_PATTERN, MEDIA_TYPE_SEPARATOR, append, toString;

      MEDIA_TYPE_SEPARATOR = '.';

      MEDIA_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\.=])*)/;

      function MediaTypeTransformer(vendor) {
        this.vendorMimeType = toString(vendor);
      }

      MediaTypeTransformer.prototype.transform = function(mediaType) {
        var matches, parameters, result, subtype, type;
        result = [];
        matches = MEDIA_TYPE_PATTERN.exec(mediaType);
        type = matches[1];
        subtype = matches[2];
        parameters = matches[3];
        append(result, type);
        append(result, '/');
        append(result, this.vendorMimeType);
        append(result, '+');
        append(result, subtype);
        append(result, parameters);
        return result.join('');
      };

      toString = function(vendor) {
        var parts;
        parts = [];
        append(parts, vendor != null ? vendor.name : void 0);
        append(parts, vendor != null ? vendor.application : void 0);
        if (vendor != null ? vendor.version : void 0) {
          parts.push('v' + vendor.version);
        }
        return parts.join(MEDIA_TYPE_SEPARATOR);
      };

      append = function(parts, value) {
        if (value != null) {
          return parts.push(value);
        }
      };

      return MediaTypeTransformer;

    })();
    AcceptHeaderProcessor = (function() {
      var SEPARATOR;

      SEPARATOR = ',';

      function AcceptHeaderProcessor(config) {
        this.config = angular.extend({
          mimeTypePattern: /([\s\w\d+\-\/\*\.]+)((:?;[\s\w\d+\-*\.=])*)/
        }, config);
        this.transformer = new MediaTypeTransformer(this.config.vendor);
      }

      AcceptHeaderProcessor.prototype.process = function(header) {
        var headerMimeType, headerMimeTypes, i, len, mime, result;
        headerMimeTypes = this.extractMimeTypes(header);
        result = [];
        for (i = 0, len = headerMimeTypes.length; i < len; i++) {
          headerMimeType = headerMimeTypes[i];
          mime = headerMimeType;
          if (this.matchesMimeTypes(headerMimeType)) {
            mime = this.transformer.transform(headerMimeType);
          }
          result.push(mime);
        }
        return result.join(SEPARATOR);
      };

      AcceptHeaderProcessor.prototype.extractMimeTypes = function(header) {
        var mimeTypePattern;
        mimeTypePattern = this.config.mimeTypePattern;
        return header.split(SEPARATOR).map(function(mime) {
          var match;
          if (!mimeTypePattern.test(mime)) {
            return mime;
          }
          match = mimeTypePattern.exec(mime);
          return match[1].trim();
        });
      };

      AcceptHeaderProcessor.prototype.matchesMimeTypes = function(headerMimeType) {
        var i, len, mimeType, ref;
        ref = this.config.mimeTypes;
        for (i = 0, len = ref.length; i < len; i++) {
          mimeType = ref[i];
          if (headerMimeType === mimeType) {
            return true;
          }
        }
        return false;
      };

      return AcceptHeaderProcessor;

    })();
    HttpRequestInterceptorVendorMimeTypeProvider = (function() {
      function HttpRequestInterceptorVendorMimeTypeProvider(paths, mimeTypes) {
        this.paths = paths;
        this.mimeTypes = mimeTypes;
      }

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.setVendorMimeType = function(vendorMimeType1) {
        this.vendorMimeType = vendorMimeType1;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.matchingRequests = function(paths1) {
        this.paths = paths1;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.matchingMimeTypes = function(mimeTypes1) {
        this.mimeTypes = mimeTypes1;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.withVendor = function(vendor1) {
        this.vendor = vendor1;
      };

      HttpRequestInterceptorVendorMimeTypeProvider.prototype.$get = function($q) {
        var matchesPath, mimeTypes, paths, processor, vendor, vendorMimeType;
        paths = this.paths;
        mimeTypes = this.mimeTypes;
        vendorMimeType = this.vendorMimeType;
        vendor = this.vendor;
        processor = new AcceptHeaderProcessor({
          mimeTypes: mimeTypes,
          vendorMimeType: vendorMimeType,
          vendor: vendor
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
            var value;
            if ((vendorMimeType || angular.isDefined(vendor)) && matchesPath(config.url)) {
              value = processor.process(config.headers.Accept);
              config.headers.Accept = value;
            }
            return config || $q.when(config);
          }
        };
      };

      return HttpRequestInterceptorVendorMimeTypeProvider;

    })();
    return new HttpRequestInterceptorVendorMimeTypeProvider([/.*/], ['text/xml', 'application/xml', 'application/json']);
  });

}).call(this);
