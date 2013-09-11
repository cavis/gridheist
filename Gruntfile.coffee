#
# grunt config
#
module.exports = (grunt) ->

  # init the configuration
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    banner:
      """
      # ==============================================================
      # <%= pkg.title %> v<%= pkg.version %>
      # <%= pkg.description %>
      # <%= pkg.homepage %>
      # ==============================================================
      # Copyright (c) 2013 <%= pkg.author %>
      # Licensed under http:#en.wikipedia.org/wiki/MIT_License
      # ==============================================================
      """
    bannerjs: "<%= banner.replace(/^#/gm, '//') %>"
    bannercss: "<%= banner.replace(/^#/, '/*').replace(/^#/gm, ' *') + ' */' %>"

    # clean build directory
    clean:
      build: 'build'

    # coffeescript compiling
    coffee:
      compile:
        files:
          'build/gridheist.js' : 'src/gridheist.coffee'

    # sass compiling
    sass:
      compile:
        files:
          'build/gridheist.css' : 'src/gridheist.scss'

    # banner for the build files (with the correct kind of comments)
    wrap:
      js:
        src: 'build/gridheist.js'
        dest: '.'
        options: wrapper: ['<%= bannerjs %>', '']
      css:
        src: 'build/gridheist.css'
        dest: '.'
        options: wrapper: ['<%= bannercss %>', '']
      coffee:
        src: 'src/gridheist.coffee'
        dest: 'build/gridheist.coffee'
        options: wrapper: ['<%= banner %>', '']
      sass:
        src: 'src/gridheist.scss'
        dest: 'build/gridheist.scss'
        options: wrapper: ['<%= bannerjs %>', '']

    # minify js
    uglify:
      options: banner: '<%= bannerjs %>\n'
      build:
        src: 'build/gridheist.js'
        dest: 'build/gridheist.min.js'

    # minify css
    cssmin:
      options: banner: '<%= bannercss %>'
      build:
        src: 'build/gridheist.css'
        dest: 'build/gridheist.min.css'

    # watcher
    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: ['coffee', 'wrap:js', 'wrap:coffee', 'uglify']
      sass:
        files: 'src/*.scss'
        tasks: ['sass', 'wrap:css', 'wrap:sass', 'cssmin']

    # fetch some image json
    http:
      pixabay:
        url: 'http://pixabay.com/api/'
        qs:
          username:    '<%= grunt.option("username") %>'
          key:         '<%= grunt.option("key") %>'
          search_term: '<%= grunt.option("search") %>'
          image_type:  'photo'
          per_page:    50
        dest: 'example/images.json'

    # dev server
    connect:
      server:
        options:
          open: 'test/dynamic.html'
          keepalive: true
          # base: 'test'


  # externals
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-connect')
  grunt.loadNpmTasks('grunt-contrib-cssmin')
  grunt.loadNpmTasks('grunt-contrib-sass')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-http')
  grunt.loadNpmTasks('grunt-wrap')

  # test
  grunt.registerTask 'prettyjson', ->
    json = grunt.file.readJSON('example/images.json')
    grunt.file.delete 'example/images.json'
    grunt.file.write 'example/images.json', JSON.stringify(json, null, 2)
  grunt.registerTask 'images', (username, apikey, search='bunnies') ->
    grunt.option.init username: username, key: apikey, search: search
    grunt.task.run ['http', 'prettyjson']

  # build
  grunt.registerTask('build', ['clean', 'coffee', 'sass', 'wrap', 'uglify', 'cssmin'])
  grunt.registerTask('default', ['build'])

