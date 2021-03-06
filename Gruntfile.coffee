
module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt);
  require('time-grunt')(grunt);

  grunt.initConfig(
    bower:
      install:
        options:
          verbose: false
          targetDir: 'bower_components'

    clean:
      dist:
        files: [
          src: 'dist/*'
        ]

    coffee:
      compile:
        files:
          'dist/angular-vendor-media-type.js': 'src/coffee/angular-vendor-media-type.coffee'

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app:
        files:
          src: 'src/coffee/*.coffee'
      test:
        files:
          src: 'test/coffee/*.coffee'

    wiredep: 
      test: 
        src: 'karma.conf.coffee',
        devDependencies: true,
        fileTypes: 
          coffee:
            block: /(([\s\t]*)#\s*bower:*(\S*))(\n|\r|.)*?(#\s*endbower)/gi,
            detect: 
              js: /'(.*\.js)'/gi
            replace: 
              js: '\'{{filePath}}\','

    karma: 
      unit: 
        configFile: 'karma.conf.coffee',
        singleRun: true

    coveralls: {
      options: {
        coverageDir: 'coverage',
        force: true,
        recursive: true
      }
    }
  )

  grunt.registerTask('test', [
    'coffeelint:test',
    'bower:install',
    'wiredep:test',
    'karma',
    'coveralls'
  ]);

  grunt.registerTask('build', [
    'coffeelint:app',
    'clean:dist',
    'coffee'
  ]);

  grunt.registerTask('default', [
    'test',
    'build'
  ]);