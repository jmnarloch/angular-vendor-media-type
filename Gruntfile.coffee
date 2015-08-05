
module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt);
  require('time-grunt')(grunt);

  grunt.initConfig(
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
    'wiredep:test',
    'karma'
  ]);

  grunt.registerTask('build', [
    'wiredep:test',
    'karma'
  ]);