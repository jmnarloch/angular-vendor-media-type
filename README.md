# Angular Vendor Media Type [![Build Status](https://travis-ci.org/jmnarloch/angular-vendor-media-type.svg?branch=master)](https://travis-ci.org/jmnarloch/angular-vendor-media-type) [![Coverage Status](https://coveralls.io/repos/jmnarloch/angular-vendor-media-type/badge.svg?branch=master&service=github)](https://coveralls.io/github/jmnarloch/angular-vendor-media-type?branch=master) [![npm version](https://badge.fury.io/js/angular-vendor-media-type.svg)](http://badge.fury.io/js/angular-vendor-media-type)

> Angular $http interceptor that sets you vendor specific versioned media type

## Setup

Install the plugin through bower:

```
bower install angular-vendor-media-type --save
```

In your Angular module register plugin as module dependency

```
angular.module('app', ['ngVendorMediaType'])
```

## Configure

Optionally configure the `httpRequestInterceptorVendorMediaTypeProvider` by setting the matched request urls,
media types and the vendor information using fluent API:

```
angular.module('app', ['ngVendorMediaType'])
.config(function(httpRequestInterceptorVendorMediaTypeProvider) {
    httpRequestInterceptorVendorMediaTypeProvider
      .matchingRequests([/.*api.*/])
      .matchingMediaTypes(['text/xml', 'application/xml', 'application/json'])
      .withVendor({
        name: 'vnd',
        application: 'appname',
        version: '1'
      })
});
```

## How it works

The extension intercepts any outgoing $http request and *transforms* the `Accept` and `Content-Type` headers media types. 
If your application makes fallowing request:
  
```
GET /devices
Accept: */*,application/json
```

The `Accept` header will be transformed into:
 
```
GET /devices
Accept: */*,application/vnd.appname.v1+json
```

Note: only the configured MIME types will be altered, you can use the 
`httpRequestInterceptorVendorMimeTypeProvider.matchingMimeTypes` method for specifying the desired ones.

## Options

`httpRequestInterceptorVendorMimeTypeProvider` defines a set of methods for configuring its behaviour

### matchingRequests
Default value: `[\.*\]`

Defines the list of request url regexes

### matchingMediaTypes
Default value: `['text/xml', 'application/xml', 'application/json']`

Defines the list of media types to modify

### withVendor
Default value: `null`

Defines the vendor information

### withVersionParam
Default value: `false`

Allows to pass the version as additional media type parameter i.e.: `application/vnd.appname+json; version=1`

### withoutVersionParam
Default value: `false`

Disables passing the media type version parameter

## Migrate from 1.x to 2.x

For consistency all MIME Type references in object or module naming has been changes into Media Type. 

## License

MIT