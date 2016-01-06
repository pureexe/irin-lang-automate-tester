gulp = require("gulp")
gutil = require('gulp-util')
tester = require("./gulp-irin-tester.coffee")

gulp.task 'default', ->
  gutil.log "Running",gutil.colors.cyan("irin-lang"),"automated tester..."
  gulp.src(['case/**/config.json']).pipe(tester())
