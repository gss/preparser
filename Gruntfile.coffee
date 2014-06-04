module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Generate library from Peg grammar
    peg:
      preparser:
        src: 'src/grammar.peg'
        dest: 'lib/parser.js'

    # Build the browser Component
    componentbuild:
      'gss-preparser':
        options:
          name: 'gss-preparser'
        src: '.'
        dest: 'browser'
        scripts: true
        styles: false

    # JavaScript minification for the browser
    uglify:
      options:
        report: 'min'
      'gss-preparser':
        files:
          './browser/gss-preparser.min.js': ['./browser/gss-preparser.js']

    # Automated recompilation and testing when developing
    watch:
      build:
        files: ['spec/**/*.coffee', 'src/**/*.{coffee,peg}']
        tasks: ['build']
      test:
        files: ['spec/**/*.coffee', 'src/**/*.{coffee,peg}']
        tasks: ['test']

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['spec/**/*.coffee']
      options:
        reporter: 'spec'

    # CoffeeScript compilation
    coffee:
      src:
        options:
          bare: true
        expand: true
        cwd: 'src'
        src: ['**/*.coffee']
        dest: 'lib'
        ext: '.js'
      spec:
        options:
          bare: true
        expand: true
        cwd: 'spec'
        src: ['**/*.coffee']
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

  @registerTask 'build', ['coffee:src', 'peg', 'componentbuild', 'uglify']
  @registerTask 'test', ['build', 'coffee:spec', 'cafemocha', 'mocha_phantomjs']
  @registerTask 'default', ['build']
