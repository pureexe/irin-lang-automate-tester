fs = require("fs")
path = require("path")
Irin = require("./src/irin-lang.coffee")
through = require('through2')
gutil = require('gulp-util')
PluginError = gutil.PluginError
PLUGIN_NAME = 'gulp-irin-tester'

#throw new PluginError(PLUGIN_NAME, 'Missing prefix text!');

tester = ()->
  through.obj (file,enc,cb)->
    if file.isNull()
      return cb(null,file)
    if file.isBuffer()
      return irinLangTest(file,cb)

irinLangTest = (file,callback)->
  configJson = JSON.parse(file.contents)
  dirName = path.dirname(file.history[0])
  mainFile = configJson.file
  repeat = 10
  if configJson.repeat
    repeat = configJson.repeat
  toCallback = repeat
  goback = ()->
    toCallback--
    if toCallback == 0
      callback(null,file)
  for i in [1..repeat]
    bot = new Irin dirName+"/"+mainFile,(err)->
      if err
        isValidError = false
        if configJson.error
          for e in configJson.error
            min = 0
            if e.length < err.message.length
              min = e.length
            else
              min = err.message.length
            if e.substring(0,min) == err.message.substring(0,min)
              isValidError = true
        if not isValidError
          gutil.log gutil.colors.cyan("irin-lang"),"crash on", gutil.colors.red("interpetion")
          gutil.log gutil.colors.red("Error"),"detect on",gutil.colors.cyan(dirName+"/"+mainFile)
          throw new gutil.PluginError(PLUGIN_NAME,err)
      else
        botReply = []
        if configJson.input
          for input in configJson.input
            botReply.push(bot.reply(input))
        else
          gutil.log gutil.colors.cyan("irin-lang"),"crash on empty",gutil.colors.red("bot.reply")
          gutil.log gutil.colors.red("Error"),"detect on",gutil.colors.cyan(dirName+"/"+mainFile)
          throw new gutil.PluginError(PLUGIN_NAME,"Wrong reply")
        if not configJson.reply
          gutil.log gutil.colors.cyan("config.json"),"have no element name",gutil.colors.red("reply")
          throw new gutil.PluginError(PLUGIN_NAME,"config.json fault")
        for cReply in configJson.reply
          isValidReply = false
          if typeof cReply == "string"
            cReply = [cReply]
          for tReply in cReply
            if tReply == botReply[0]
              isValidReply = true
          if not isValidReply
            gutil.log gutil.colors.cyan("irin-lang"),"got wrong",gutil.colors.red("answer")
            gutil.log "bot reply is",gutil.colors.red(botReply[0])
            gutil.log gutil.colors.red("Error"),"detect on",gutil.colors.cyan(dirName+"/"+mainFile)
            throw new gutil.PluginError(PLUGIN_NAME,"Wrong reply")
          botReply.shift()
      goback()

#
#  gutil.log gutil.colors.cyan()

module.exports = tester
