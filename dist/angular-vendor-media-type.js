(function() {
  angular.module('ngVendorMimeType', []).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('httpRequestInterceptorVendorMimeType');
    }
  ]).provider('httpRequestInterceptorVendorMimeType', function() {
    var AcceptHeaderProcessor, HttpRequestInterceptorVendorMimeTypeProvider, MimeTypeTransformer;
    MimeTypeTransformer = (function() {
      var MIME_TYPE_PATTERN, MIME_TYPE_SEPARATOR, append, toString;

      MIME_TYPE_SEPARATOR = '.';

      MIME_TYPE_PATTERN = /([\s\w\d+\-\*\.]+)\/([\s\w\d+-\/\*\.]+)((:?;[\s\w\d+\-*\."=]*)*)/;

      function MimeTypeTransformer(vendor, useVersionParam) {
        this.vendor = vendor;
        this.useVersionParam = useVersionParam;
        this.vendorMimeType = toString(vendor, useVersionParam);
      }

      MimeTypeTransformer.prototype.transform = function(mimeType) {
        var matches, parameters, ref, ref1, result, subtype, type;
        matches = MIME_TYPE_PATTERN.exec(mimeType);
        ref = matches.slice(1, 4), type = ref[0], subtype = ref[1], parameters = ref[2];
        result = [];
        append(result, type);
        append(result, '/');
        append(result, this.vendorMimeType);
        append(result, '+');
        append(result, subtype);
        append(result, parameters);
        if (this.useVersionParam === true && (((ref1 = this.vendor) != null ? ref1.version : void 0) != null)) {
          append(result, '; version=');
          append(result, this.vendor.version);
        }
        return result.join('');
      };

      toString = function(vendor, useVersionParam) {
        var parts;
        parts = [];
        append(parts, vendor != null ? vendor.name : void 0);
        append(parts, vendor != null ? vendor.application : void 0);
        if (useVersionParam === false && ((vendor != null ? vendor.version : void 0) != null)) {
          parts.push('v' + vendor.version);
        }
        return parts.join(MIME_TYPE_SEPARATOR);
      };

      append = function(parts, value) {
        if (value != null) {
          return parts.push(value);
        }
      };

      return MimeTypeTransformer;

    })();
    AcceptHeaderProcessor = (function() {
      var SEPARATOR;

      SEPARATOR = ',';

      function AcceptHeaderProcessor(config) {
        this.config = angular.extend({
          mimeTypePattern: /([\s\w\d+\-\/\*\.]+)((:?;[\s\w\d+\-*\.=])*)/
        }, config);
        this.transformer = new MimeTypeTransformer(this.config.vendor, config.useVersionParam);
      }

      AcceptHeaderProcessor.prototype.process = function(header) {
        var headerMimeType, headerMimeTypes, i, len, mime, result;
        if (header == null) {
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
          result.push(mime);
        }
        return result.join(SEPARATOR);
      };

      AcceptHeaderProcessor.prototype.extractMimeTypes = function(header) {
        return header.split(SEPARATOR);
      };

      AcceptHeaderProcessor.prototype.matchesMimeTypes = function(headerMimeType) {
        var i, len, match, mimeType, mimeTypePattern, ref, type;
        mimeTypePattern = this.config.mimeTypePattern;
        if (!mimeTypePattern.test(headerMimeType)) {
          return false;
        }
        match = mimeTypePattern.exec(headerMimeType);
        type = match[1].trim();
        ref = this.config.mimeTypes;
        for (i = 0, len = ref.length; i < len; i++) {
          mimeType = ref[i];
          if (mimeType === type) {
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
        this.useVersionParam = false;
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
        var matchesPath, mimeTypes, paths, processor, useVersionParam, vendor;
        paths = this.paths;
        mimeTypes = this.mimeTypes;
        vendor = this.vendor;
        useVersionParam = this.useVersionParam;
        processor = new AcceptHeaderProcessor({
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
            if (angular.isDefined(vendor && matchesPath(config.url))) {
              config.headers.Accept = processor.process(config.headers.Accept);
              config.headers['Content-Type'] = processor.process(config.headers['Content-Type']);
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
