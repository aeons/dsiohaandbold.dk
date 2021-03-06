module.exports = function(grunt) {
  require('load-grunt-tasks')(grunt);

  //  grunt-rsync

  grunt.initConfig({
    shell: {
      jekyll: {
        command: 'rm -rf _site/*; bundle exec jekyll build',
        stdout: true
      }
    },

    watch: {
      options: {
        livereload: true
      },
      jekyllSources: {
        files: [
          '!_site/**',
          '**/*.md',
          '*.html',
          '*.yml',
          '_data/**',
          '_hold/**',
          '_includes/**',
          '_layouts/**',
          '_plugins/**',
          '_posts/**',
          '_sass/**',
          'assets/**',
          'pages/**'
        ],
        tasks: ['shell:jekyll']
      }
    },

    connect: {
      server: {
        options: {
          base: '_site/',
          port: 4000
        }
      }
    },

    open: {
      server: {
        path: 'http://localhost:<%= connect.server.options.port %>/'
      }
    }
  });

  grunt.registerTask('server', [
    'connect:server',
    'shell:jekyll',
    'open:server',
    'watch'
  ]);

  grunt.registerTask('build', ['shell:jekyll'])

  grunt.registerTask('default', 'server');
};
