
$httpBackend = null
$http = null

expectGET = (config) ->
  $httpBackend.expectGET(config.path, (headers) ->
    matches = true
    for k, v of config.expected
      if headers[k] != config.expected[k]
        matches = false
        break
    return matches
  ).respond(200)
  $http.get(config.path, (
    headers: config.headers
  ))
  $httpBackend.flush()

expectPOST = (config) ->
  $httpBackend.expectPOST(config.path, undefined, (headers) ->
    matches = true
    for k, v of config.expected
      if headers[k] != config.expected[k]
        matches = false
        break
    return matches
  ).respond(200)
  $http.post(config.path, config.data, (
    headers: config.headers
  ))
  $httpBackend.flush()

describe 'ngVendorMediaType', ->

  describe 'with unconfigured provider', ->
    beforeEach module('ngVendorMediaType')

    beforeEach inject ($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $http = $injector.get('$http')

    afterEach ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    describe 'should not match the request url', ->
      it 'should not alter the Accept', ->
        expectGET
          path: '/views/index.html'
          headers:
            'Accept': 'text/html'
          expected:
            'Accept': 'text/html'

    describe 'should match the request url', ->
      it 'should not alter the Accept header uri with undefined vendor media type', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': 'application/json'
          expected:
            'Accept': 'application/json'

  describe 'with configured provider', ->
    beforeEach module 'ngVendorMediaType', (httpRequestInterceptorVendorMediaTypeProvider) ->
      httpRequestInterceptorVendorMediaTypeProvider
          .matchingRequests([/.*api.*/])
          .matchingMediaTypes(['text/xml', 'application/xml', 'application/json'])
          .withVendor(
            name: 'vnd',
            application: 'appname',
            version: '1'
          )
          .withoutVersionParam()
      return

    beforeEach inject (($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $http = $injector.get('$http')
    )

    afterEach ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    describe 'should not match the request url', ->
      it 'should not alter the Accept header', ->
        expectGET
          path: '/views/index.html'
          headers:
            'Accept': 'text/html'
          expected:
            'Accept': 'text/html'

    describe 'should match the request url', ->
      it 'should alter the Accept header', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': 'application/json'
          expected:
            'Accept': 'application/vnd.appname.v1+json'

    describe 'should match the request url', ->
      it 'should alter the Content-Type header', ->
        expectPOST
          path: '/api/invoices'
          data:
            message: 'test'
          headers:
            'Content-Type': 'application/json'
          expected:
            'Content-Type': 'application/vnd.appname.v1+json'

    describe 'should match the request url', ->
      it 'should alter both Accept and Content-Type headers', ->
        expectPOST
          path: '/api/invoices'
          data:
            message: 'test'
          headers:
            'Accept': 'application/json'
            'Content-Type': 'application/json'
          expected:
            'Accept': 'application/vnd.appname.v1+json'
            'Content-Type': 'application/vnd.appname.v1+json'

    describe 'should match the request url', ->
      it 'should alter both Acept and Content-Type headers', ->
        expectPOST
          path: '/api/invoices'
          data:
            message: 'test'
          headers:
            'Accept': 'application/json'
            'Content-Type': 'text/xml'
          expected:
            'Accept': 'application/vnd.appname.v1+json'
            'Content-Type': 'text/vnd.appname.v1+xml'

    describe 'should match the request url with multiple media types', ->
      it 'should alter the Accept header', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': '*/*,application/*,application/json'
          expected:
            'Accept': '*/*,application/*,application/vnd.appname.v1+json'

    describe 'should match the request url with multiple media types and whitespaces', ->
      it 'should alter the Accept header', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': '*/*, application/*, application/json'
          expected:
            'Accept': '*/*, application/*, application/vnd.appname.v1+json'

    describe 'should match the request url with multiple media types and quality factor', ->
      it 'should alter the Accept header', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': 'application/json; q=0.8,application/xml; q=0.6'
          expected:
            'Accept': 'application/vnd.appname.v1+json; q=0.8,application/vnd.appname.v1+xml; q=0.6'

    describe 'should match the request url with multiple media types, quality factor and custom parameters', ->
      it 'should alter the Accept header', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': 'application/json; profile="test"; q=0.8,application/xml; q=0.6'
          expected:
            'Accept': 'application/vnd.appname.v1+json; profile="test"; q=0.8,application/vnd.appname.v1+xml; q=0.6'

    describe 'should not match the request media types', ->
      it 'should not alter the Accept header', ->
        expectGET
          path: '/views/index.html'
          headers:
            'Accept': 'application/json; q=0.8,application/xml; q=0.6'
          expected:
            'Accept': 'application/json; q=0.8,application/xml; q=0.6'

    describe 'should not match the request empty media types', ->
      it 'should not alter the Accept header', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': ''
          expected:
            'Accept': ''

  describe 'with configured provider', ->
    beforeEach module 'ngVendorMediaType', (httpRequestInterceptorVendorMediaTypeProvider) ->
      httpRequestInterceptorVendorMediaTypeProvider
          .matchingRequests([/.*/])
          .matchingMediaTypes(['text/xml', 'application/xml', 'application/json'])
          .withVendor(
            name: 'vnd',
            application: 'appname',
            version: '1'
          )
          .withVersionParam()
      return

    beforeEach inject (($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $http = $injector.get('$http')
    )

    afterEach ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    describe 'should match the request url', ->
      it 'should alter the Accept header with version parameter', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': 'application/json'
          expected:
            'Accept': 'application/vnd.appname+json; version=1'

    describe 'should match the request url', ->
      it 'should alter the Accept header with version parameter for multiple media types', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': '*/*, application/*, application/json'
          expected:
            'Accept': '*/*, application/*, application/vnd.appname+json; version=1'

    describe 'should match the request url', ->
      it 'should alter the Accept header with version parameter for multiple media types and custom properties', ->
        expectGET
          path: '/api/invoices'
          headers:
            'Accept': '*/*, application/*, application/json; profile="test"'
          expected:
            'Accept': '*/*, application/*, application/vnd.appname+json; profile="test"; version=1'