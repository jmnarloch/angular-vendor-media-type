(function() {
  angular.module('ngVendorMimeType', []).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('httpRequestInterceptorVendorMimeType');
    }
  ]).provider('httpRequestInterceptorVendorMimeType', function() {
    var AcceptHeaderProcessor, HttpRequestInterceptorVendorMimeTypeProvider;
    AcceptHeaderProcessor = (function() {
      var SEPARATOR;

      SEPARATOR = ',';

      function AcceptHeaderProcessor(config) {
        this.config = angular.extend({
          mimeTypePattern: /([\s\w\d+-\/\/*.]+)(:?;[\s\w\d+-\/\/*.=])?/
        }, config);
      }

      AcceptHeaderProcessor.prototype.process = function(header) {
        var headerMimeTypes;
        headerMimeTypes = this.extractMimeTypes(header);
        if (this.matchesMimeTypes(headerMimeTypes)) {
          return this.config.vendorMimeType;
        }
        return header;
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

      AcceptHeaderProcessor.prototype.matchesMimeTypes = function(headerMimeTypes) {
        var i, len, mimeType, ref;
        ref = this.config.mimeTypes;
        for (i = 0, len = ref.length; i < len; i++) {
          mimeType = ref[i];
          if (headerMimeTypes.indexOf(mimeType) > -1) {
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
