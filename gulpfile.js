require('coffee-script/register');
var fs          = require('fs');
var path        = require('path');
var glob        = require('glob');
var gulp        = require('gulp');
var gutil       = require('gulp-util');
var rimraf      = require('gulp-rimraf');
var uglify      = require('gulp-uglify');
var streamify   = require('gulp-streamify');
var header      = require('gulp-header');
var sass        = require('gulp-sass');
var concat      = require('gulp-concat');
var minifyCss   = require('gulp-minify-css');
var serve       = require('gulp-serve');
var source      = require('vinyl-source-stream');
var es          = require('event-stream');
var browserify  = require('browserify');
var coffeeify   = require('coffeeify');
var encryptInfo = require('./lib/encryptinfo');
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
    entries: ['./scss/style.scss'],
    output: 'style.css',
    bower: [
      './bower_components/jquery-mobile-bower/css/jquery.mobile-1.4.2.css'
    ]
  },
  info: {
    entries: [infoFile],
    output: 'info.json'
  }
};

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

gulp.task('style', function() {
  var libsStream = gulp.src(builds.styles.bower);
  var sassStream = gulp.src(builds.styles.entries).pipe(sass());
  return es.concat(libsStream, sassStream)
    .pipe(concat(builds.styles.output))
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

gulp.task('clean', function() {
  var buildFiles = Object.keys(builds).map(function(build) {
    return path.join(destDir, builds[build].output);
  });
  return gulp.src(buildFiles, {read: false}).pipe(rimraf());
});

gulp.task('watch', ['browserify', 'style', 'info'], function() {
  gulp.watch(['./src/**/*.js', './src/**/*.coffee'], ['browserify'])
  .on('change', reportChange);

  gulp.watch(['./scss/**/*.scss'], ['style'])
  .on('change', reportChange);

  gulp.watch(infoFile, ['info'])
  .on('change', reportChange);
});

gulp.task('server', ['watch'], serve(destDir));

gulp.task('copy-assets', function() {
  if (destDir === assetsDir) { return; }

  var includes = path.join(assetsDir, '**/*');
  var excludes = Object.keys(builds).map(function(buildName) {
    return '!' + path.join(assetsDir, builds[buildName].output);
  });

  return gulp.src([includes].concat(excludes))
    .pipe(gulp.dest(destDir));
});

gulp.task('default', ['copy-assets', 'browserify', 'style', 'info'], function() {
  gutil.log('Build environment: ' + (
    isProduction ?
    gutil.colors.blue('production') :
    gutil.colors.green('development')
  ));
});
