module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Generate library from Peg grammar
    peg:
      preparser:
        src: 'grammar/gss-preparser.peg'
        dest: 'lib/gss-preparser.js'

    # Build the browser Component
    component_build:
      'gss-preparser':
        output: './browser/'
        config: './component.json'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      noflo:
        files:
          './browser/gss-preparser.min.js': ['./browser/gss-preparser.js']

    # Automated recompilation and testing when developing
    watch:
      build:
        files: ['spec/*.coffee', 'grammar/*.peg']
        tasks: ['build']
      test:
        files: ['spec/*.coffee', 'grammar/*.peg']
        tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/*.coffee']

    # CoffeeScript compilation
    coffee:
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**.coffee']
        dest: 'spec'
        ext: '.js'

    # BDD tests on browser
    mocha_phantomjs:
      all: ['spec/runner.html']

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-peg'
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-cafe-mocha'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'build', ['peg', 'coffee', 'component_build', 'uglify']
  @registerTask 'test', ['build', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
