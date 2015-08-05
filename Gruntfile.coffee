
module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt);
  require('time-grunt')(grunt);

  grunt.initConfig(
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
        src: 'karma.conf.js',
        devDependencies: true,
        fileTypes: 
          js: 
            block: /(([\s\t]*)\/\/\s*bower:*(\S*))(\n|\r|.)*?(\/\/\s*endbower)/gi,
            detect: 
              js: /'(.*\.js)'/gi
            replace: 
              js: '\'{{filePath}}\','

    karma: 
      unit: 
        configFile: 'karma.conf.js',
        singleRun: true
  )

  grunt.registerTask('test', [
    'coffeelint:test',
    'wiredep:test',
    'karma'
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