'use strict'

# Load required Node.js modules
path = require 'path'

# Load LiveReload snippet
lrUtils = require 'grunt-contrib-livereload/lib/utils'
lrSnippet = lrUtils.livereloadSnippet

# Helper function for LiveReload
folderMount = (connect, point) ->
  return connect.static path.resolve(point)


#
# Grunt main configuration
# ------------------------
module.exports = (grunt) ->

  #
  # Initial configuration object for Grunt
  # passed to `grunt.initConfig()`
  #
  conf =

    # Setup basic paths and read them by `<%= path.PROP %>`
    path:
      source: 'src'
      publish: 'dist'

    #
    # Task to remove files & directories
    #
    # * [grunt-contrib-clean](https://github.com/gruntjs/grunt-contrib-clean)
    #
    clean:
      options:
        force: true
      publish:
        src: '<%= path.publish %>'

    #
    # Task to launch Connect & LiveReload static web server
    #
    # * [grunt-contrib-connect](https://github.com/gruntjs/grunt-contrib-connect)
    # * [grunt-contrib-livereload](https://github.com/gruntjs/grunt-contrib-livereload)
    #
    connect:
      publish:
        options:
          port: 50000
          middleware: (connect, options) ->
            return [lrSnippet, folderMount(connect, 'dist')]

    #
    # Task to copy files
    #
    # * [grunt-contrib-copy](https://github.com/gruntjs/grunt-contrib-copy)
    #
    copy:
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: [
          '**/*'
          '!**/*.coffee'
          '!**/*.jade'
          '!**/*.jst'
          '!**/*.less'
          '!**/*.litcoffee'
          '!**/*.sass'
          '!**/*.scss'
          '!**/*.styl'
        ]
        dest: '<%= path.publish %>'

    #
    # Task to compile Jade
    #
    # * [grunt-contrib-jade](https://github.com/gruntjs/grunt-contrib-jade)
    #
    jade:
      options:
        pretty: true
        data: grunt.file.readJSON 'package.json'
      source:
        expand: true
        cwd: '<%= path.source %>'
        src: '**/!(_)*.jade'
        dest: '<%= path.publish %>'
        ext: '.html'

    #
    # Task to observe file changes & fire up related tasks
    #
    # * [grunt-regarde](https://github.com/yeoman/grunt-regarde)
    #
    regarde:
      source:
        files: '<%= path.source %>/**/*'
        tasks: [
          'default'
          'livereload'
        ]


  #
  # List of sequential tasks
  # passed to `grunt.registerTask tasks.TASK`
  #
  tasks =
    html: [
      'jade'
    ]
    watch: [
      'livereload-start'
      'connect'
      'regarde'
    ]
    default: [
      'copy:source'
      'html'
    ]


  # Load Grunt plugins
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-livereload'
  grunt.loadNpmTasks 'grunt-regarde'

  # Load initial configuration being set up above
  grunt.initConfig conf

  # Regist sequential tasks being listed above
  grunt.registerTask 'html', tasks.html
  grunt.registerTask 'watch', tasks.watch
  grunt.registerTask 'default', tasks.default
