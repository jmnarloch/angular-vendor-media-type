# Angular Vendor Media Type

> Angular http interceptor that sets you vendor specific versioned media type

[![Build Status](https://travis-ci.org/jmnarloch/angular-vendor-media-type.svg?branch=master)](https://travis-ci.org/jmnarloch/angular-vendor-media-type)

## Setup

Install the plugin through bower:

```
bower install angular-vendor-media-type --save
```

In your Angular module register plugin as module dependency

```
angular.module('app', ['ngVendorMimeType'])
```

## Configure

Optionally configure the `httpRequestInterceptorVendorMimeTypeProvider` by setting the matched request urls,
mime types and the vendor information:

```
angular.module('app', ['ngVendorMimeType'])
.config(function(httpRequestInterceptorVendorMimeTypeProvider) {
      httpRequestInterceptorVendorMimeTypeProvider.matchingRequests([/.*api.*/]);
      httpRequestInterceptorVendorMimeTypeProvider.matchingMimeTypes(['text/xml', 'application/xml',
                                                                      'application/json']);
      httpRequestInterceptorVendorMimeTypeProvider.withVendor(
        name: 'vnd',
        application: 'appname',
        version: 1
      );
});
```

## How it works

The extension intercept any outgoing $http request by *transforming* the `Accept` header MIME types. 
If your application make fallowing request:
  
```
GET /devices/all
Accept: */*,application/json
```

The `Accept` header will be transformed into:
 
```
GET /devices/all
Accept: */*,application/vnd.appname.v1+json
```

Note: only the configured MIME types will be altered, you can use the 
`httpRequestInterceptorVendorMimeTypeProvider.matchingMimeTypes` method for configuring the desired MIME types.

## License

MIT