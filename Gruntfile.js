module.exports = function(grunt) {

  // Load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  grunt.initConfig({
    shell: {
      jekyll: {
        command: 'rm -rf _site; bundle exec jekyll build',
        stdout: true
      }
    },

    watch: {
      options: {
        livereload: true
      },
      jekyllSources: {
        files: [
          '*.html', '*.yml', '_assets/javascripts/**.js', '_posts/**',
          'pages/**', '_data/**', '_hold/**', '_includes/**', '_layouts/**',
          '_plugins/**', '**/*.md'
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

  grunt.registerTask('default', 'server');
};
