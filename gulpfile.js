var browserify = require('browserify'),
	partialify = require('partialify'),
	coffeeify = require('coffeeify'),
	jadeify = require('jadeify'),
	stylify = require('stylify'),
	vueify = require('vueify'),
	watchify = require('watchify'),
	exorcist = require('exorcist'),
	transform = require('vinyl-transform'),
	gulp = require('gulp'),
	livereload = require('gulp-livereload'),
	jshint = require('gulp-jshint'),
	jsfmt = require('gulp-jsfmt'),
	watch = require('gulp-watch'),
	source = require('vinyl-source-stream'),
	stylus = require('gulp-stylus'),
	nib = require('nib'),
	sourcemaps = require('gulp-sourcemaps');

var dest = './build/';
var apps = {
	redactor: {
		dest: 'main.js',
		source: './js/index.coffee'
	},
}

var css = function() {
	gulp.src('./css/**/*.styl')
		.pipe(stylus({
			use: [nib() /*, jeet()*/ ],
			sourcemap: {
				inline: true,
				sourceRoot: '..',
				basePath: 'css'
			}
		}))
		.pipe(gulp.dest(dest));
}

gulp.task('css', css);
gulp.task('watch-css', ['css'], function() {
	gulp.watch('css/**').on('change', css);
});


function handleErrors(err) {
	var args = Array.prototype.slice.call(arguments);
	console.error(err.toString());
	this.emit('end');
}

var fn = function(app, isWatching) {
	return function() {
		var bundler = browserify({
			cache: {},
			packageCache: {},
			fullPaths: true,
			entries: [app.source],
			debug: true
		});
		var bundle = function() {
			return bundler
				.transform(partialify)
				.transform(coffeeify)
				.transform(jadeify)
				.transform('stylify', {
					// set    : { setting: value },
					// include: [ path, ... ],
					// import : [ path, ... ],
					// define : { key: value },
					use: [nib()],
				})
				//.transform(vueify)
				.bundle().on('error', handleErrors)
				.pipe(source(app.dest))
				.pipe(transform(function() {
					return exorcist(dest + app.dest + '.map');
				}))
				.pipe(gulp.dest(dest));
		};

		if (isWatching) {
			bundler = watchify(bundler);
			bundler.on('update', bundle);
		}

		return bundle();
	}
}

var w = ['watch-css'];
var b = ['css'];
for (var k in apps) {
	gulp.task('browserify-' + k, fn(apps[k], false));
	gulp.task('watch-' + k, fn(apps[k], true));
	b.push('browserify-' + k);
	w.push('watch-' + k);
}

gulp.task('watch', w);
gulp.task('build', b);

gulp.task('lint', function() {
	return gulp.src('./js/**/*.js')
		.pipe(jshint())
		.pipe(jshint.reporter('jshint-stylish'));
});

gulp.task('fmt', function() {
	return gulp.src('./js/**/*.js')
		.pipe(jsfmt.format())
	//.pipe(jshint.reporter('jshint-stylish'));
});

gulp.task('server', function(next) {
	var connect = require('connect');
	connect()
		.use(connect.static('./'))
		.use(connect.static('public'))
		.use(connect.directory('public'))
		.use(function(req, res) {
			if (req.method == 'POST') {
				console.log(req.body);
			} else {
				res.end('FUCK U\n');
			}
		})
		.listen(process.env.PORT || 9000, next);
});

gulp.task('reload', ['server'], function() {
	var server = livereload();
	gulp.watch('public/**').on('change', function(event) {
		server.changed(event.path);
		console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
	});
});

gulp.task('default', ['watch']);
