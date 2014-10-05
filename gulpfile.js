require('coffee-script/register');
var fs          = require('fs');
var path        = require('path');
var glob        = require('glob');
var del         = require('del');
var gulp        = require('gulp');
var gutil       = require('gulp-util');
var uglify      = require('gulp-uglify');
var streamify   = require('gulp-streamify');
var header      = require('gulp-header');
var less        = require('gulp-less');
var concat      = require('gulp-concat');
var minifyCss   = require('gulp-minify-css');
var serve       = require('gulp-serve');
var source      = require('vinyl-source-stream');
var es          = require('event-stream');
var browserify  = require('browserify');
var coffeeify   = require('coffeeify');
var encryptInfo = require('bad-cipher/gulp-encrypt');
var pkg         = require('./package.json');

var isProduction = gutil.env.production || gutil.env.prod;
var infoFile     = gutil.env.info || './info.json';

var assetsDir = './public';
var destDir   = gutil.env.prefix || assetsDir;
var preamble  = './preamble.txt';
var builds    = {
  bundle: {
    entries: ['./src/app.coffee'],
    output: 'bundle.js'
  },
  specs: {
    entries: [
      './test/**/*spec.js',
      './test/**/*spec.coffee'
    ],
    output: 'specs.js'
  },
  styles: {
    entries: ['./styles/style.less'],
    output: 'style.css',
    lessIncludePaths: [
      './bower_components/jquery-mobile-bower/css'
    ]
  },
  info: {
    entries: [infoFile],
    output: 'info.json'
  }
};

var publicFilesGlobs = (function() {
  var globs;
  return function() {
    if (globs) { return globs; }

    var includes = path.join(assetsDir, '**/*');
    var excludes = Object.keys(builds).map(function(buildName) {
      return '!' + path.join(assetsDir, builds[buildName].output);
    });

    globs = [includes].concat(excludes);
    return globs;
  };
})();

function globFiles(entries) {
  return entries.map(function(entry) {
    return glob.sync(entry);
  }).reduce(function(memo, entries) {
    return memo.concat(entries);
  }, []);
}

function streamHeaderFile(file) {
  return streamify(
    header(fs.readFileSync(file, 'utf-8'), { pkg: pkg })
  );
}

function reportChange(e) {
  gutil.log(gutil.template('File <%= file %> was <%= type %>, rebuilding...', {
    file: e.path,
    type: e.type
  }));
}

function reportSaved(buildName) {
  return function() {
    var destPath = gutil.colors.magenta(path.join(destDir, builds[buildName].output));
    gutil.log('Saved ' + buildName + ' to ' + destPath);
  };
}

gulp.task('info', function() {
  return gulp.src(builds.info.entries)
    .pipe(concat(builds.info.output))
    .pipe(isProduction ? encryptInfo(gutil.env.passwd) : gutil.noop())
    .pipe(gulp.dest(destDir))
    .on("end", reportSaved('info'));
});

gulp.task('styles', function() {
  gulp.src(builds.styles.entries)
    .pipe(less({paths: builds.styles.lessIncludePaths}))
    .pipe(isProduction ? minifyCss({keepSpecialComments: 0}) : gutil.noop())
    .pipe(streamHeaderFile(preamble))
    .pipe(gulp.dest(destDir))
    .on("end", reportSaved('styles'));
});

gulp.task('specs', function() {
  return browserify(globFiles(builds.specs.entries))
    .bundle({debug: true})
    .pipe(source(builds.specs.output))
    .pipe(gulp.dest(destDir))
    .on("end", reportSaved('specs'));
});

gulp.task('browserify', function() {
  return browserify(globFiles(builds.bundle.entries))
    .bundle()
    .pipe(source(builds.bundle.output))
    .pipe(isProduction ? streamify(uglify()) : gutil.noop())
    .pipe(streamHeaderFile(preamble))
    .pipe(gulp.dest(destDir))
    .on("end", reportSaved('bundle'));
});

gulp.task('clean', function(done) {
  var buildFiles = Object.keys(builds).map(function(build) {
    return path.join(destDir, builds[build].output);
  });

  del(buildFiles, done);
});

gulp.task('watch', ['browserify', 'styles', 'info'], function() {
  gulp.watch(['./src/**/*.js', './src/**/*.coffee'], ['browserify'])
  .on('change', reportChange);

  gulp.watch(['./styles/**/*.less'], ['styles'])
  .on('change', reportChange);

  gulp.watch(infoFile, ['info'])
  .on('change', reportChange);

  gulp.watch(publicFilesGlobs(), ['copy-assets'])
  .on('change', reportChange);
});

gulp.task('server', ['watch'], serve(destDir));

gulp.task('copy-assets', function() {
  if (destDir === assetsDir) { return; }

  return gulp.src(publicFilesGlobs())
    .pipe(gulp.dest(destDir));
});

gulp.task('default', ['copy-assets', 'browserify', 'styles', 'info'], function() {
  gutil.log('Build environment: ' + (
    isProduction ?
    gutil.colors.blue('production') :
    gutil.colors.green('development')
  ));
});
