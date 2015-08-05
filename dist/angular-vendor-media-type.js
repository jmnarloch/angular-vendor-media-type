(function() {
  angular.module('ngVendorMimeType', []).config([
    '$httpProvider', function($httpProvider) {
      return $httpProvider.interceptors.push('httpRequestInterceptorVendorMimeType');
    }
  ]).provider('httpRequestInterceptorVendorMimeType', function() {
    this.paths = [/.*api.*/];
    this.mimeTypes = ['text/xml', 'application/xml', 'application/json'];
    this.mimeTypePattern = /([\s\w\d+-\/\\*\\.]+)(:?[\s\w\d+-\/\\*\\.=])?/;
    this.vendorMimeType = '';
    this.setPaths = function(paths1) {
      this.paths = paths1;
    };
    this.setMimeTypes = function(mimeTypes1) {
      this.mimeTypes = mimeTypes1;
    };
    this.setMimeTypePattern = function(mimeTypePattern1) {
      this.mimeTypePattern = mimeTypePattern1;
    };
    this.setVendorMimeType = function(vendorMimeType1) {
      this.vendorMimeType = vendorMimeType1;
    };
    this.$get = [
      '$q', function($q) {
        var extractMimeTypes, matchesMimeTypes, matchesPath, mimeTypePattern, mimeTypes, paths, vendorMimeType;
        paths = this.paths;
        mimeTypes = this.mimeTypes;
        mimeTypePattern = this.mimeTypePattern;
        vendorMimeType = this.vendorMimeType;
        extractMimeTypes = function(header) {
          return header.split(',').map(function(mime) {
            var match;
            if (!mimeTypePattern.test(mime)) {
              return mime;
            }
            match = mimeTypePattern.exec(mime);
            return match[1].trim();
          });
        };
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
        matchesMimeTypes = function(acceptMimeTypes) {
          var i, len, mimeType;
          for (i = 0, len = mimeTypes.length; i < len; i++) {
            mimeType = mimeTypes[i];
            if (acceptMimeTypes.indexOf(mimeType) > -1) {
              return true;
            }
          }
          return false;
        };
        return {
          'request': function(config) {
            var acceptMimeTypes;
            if (vendorMimeType) {
              acceptMimeTypes = extractMimeTypes(config.headers.Accept);
              if (matchesPath(config.url) && matchesMimeTypes(acceptMimeTypes)) {
                config.headers.Accept = vendorMimeType;
              }
            }
            return config || $q.when(config);
          }
        };
      }
    ];
  });

}).call(this);
