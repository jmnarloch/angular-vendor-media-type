describe 'ngVendorMimeType', ->
  $httpBackend = null
  $http = null

  describe 'With unconfigured provider', ->
    beforeEach module('ngVendorMimeType')

    beforeEach inject ($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $http = $injector.get('$http')

    afterEach ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    describe 'Should not match the request url', ->
      it 'should not alter the Accept', ->
        path = '/views/index.html'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'text/html'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'text/html'
          )
        ))
        $httpBackend.flush()

    describe 'Should match the request url', ->
      it 'should not alter the Accept header uri with undefined vendor mime type', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'application/json'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'application/json'
          )
        ))
        $httpBackend.flush()

  describe 'With configured provider', ->
    beforeEach module 'ngVendorMimeType', (httpRequestInterceptorVendorMimeTypeProvider) ->
      httpRequestInterceptorVendorMimeTypeProvider.matchingRequests([/.*api.*/])
      httpRequestInterceptorVendorMimeTypeProvider.matchingMimeTypes(['text/xml', 'application/xml',
                                                                      'application/json'])
      httpRequestInterceptorVendorMimeTypeProvider.withVendor(
        name: 'vnd',
        application: 'appname',
        version: '1'
      )
      httpRequestInterceptorVendorMimeTypeProvider.withoutVersionParam()
      return

    beforeEach inject (($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $http = $injector.get('$http')
    )

    afterEach ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    describe 'Should not match the request url', ->
      it 'should not alter the Accept header', ->
        path = '/views/index.html'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'text/html'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'text/html'
          )
        ))
        $httpBackend.flush()

    describe 'Should match the request url', ->
      it 'should alter the Accept header', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'application/vnd.appname.v1+json'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'application/json'
          )
        ))
        $httpBackend.flush()

    describe 'Should match the request url', ->
      it 'should alter the Accept header', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'application/vnd.appname.v1+json'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'application/json'
          )
        ))
        $httpBackend.flush()

    describe 'Should match the request url with multiple mimetypes', ->
      it 'should alter the Accept header', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == '*/*,application/*,application/vnd.appname.v1+json'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': '*/*,application/*,application/json'
          )
        ))
        $httpBackend.flush()

    describe 'Should match the request url with multiple mimetypes and quality', ->
      it 'should alter the Accept header', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'application/vnd.appname.v1+json; q=0.8,application/vnd.appname.v1+xml; q=0.6'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'application/json; q=0.8,application/xml; q=0.6'
          )
        ))
        $httpBackend.flush()

    describe 'Should not match the request mime types', ->
      it 'should not alter the Accept header', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == '*/*,text/plain,text/html'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': '*/*,text/plain,text/html'
          )
        ))
        $httpBackend.flush()

    describe 'Should not match the request empty mime types', ->
      it 'should not alter the Accept header', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == ''
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': ''
          )
        ))
        $httpBackend.flush()

  describe 'With configured provider', ->
    beforeEach module 'ngVendorMimeType', (httpRequestInterceptorVendorMimeTypeProvider) ->
      httpRequestInterceptorVendorMimeTypeProvider.matchingRequests([/.*/])
      httpRequestInterceptorVendorMimeTypeProvider.matchingMimeTypes(['text/xml', 'application/xml',
                                                                      'application/json'])
      httpRequestInterceptorVendorMimeTypeProvider.withVendor(
        name: 'vnd',
        application: 'appname',
        version: '1'
      )
      httpRequestInterceptorVendorMimeTypeProvider.withVersionParam()
      return

    beforeEach inject (($injector) ->
      $httpBackend = $injector.get('$httpBackend')
      $http = $injector.get('$http')
    )

    afterEach ->
      $httpBackend.verifyNoOutstandingExpectation()
      $httpBackend.verifyNoOutstandingRequest()

    describe 'Should match the request url', ->
      it 'should alter the Accept header with version parameter', ->
        path = '/api/invoices'
        $httpBackend.expectGET(path, (headers) ->
          return headers.Accept == 'application/vnd.appname+json; version=1'
        ).respond(200)
        $http.get(path, (
          headers: (
            'Accept': 'application/json'
          )
        ))
        $httpBackend.flush()
