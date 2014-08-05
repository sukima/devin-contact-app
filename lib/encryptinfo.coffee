through       = require "through2"
{PluginError} = require "gulp-util"
BadCipher     = require "../src/badcipher"

generateUUID = ->
  timestamp   = Date.now()
  uuid        = ""
  hexChars    = "0123456789abcdef"
  uuidPattern = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"

  for position in uuidPattern by -1
    switch position
      when "x"
        uuid = hexChars.charAt(timestamp + Math.random() * 0xFF & 15) + uuid
      when "-", "4"
        uuid = position + uuid
      else
        uuid = hexChars.charAt(Math.random() * 4 + 8 | 0) + uuid

    timestamp >>= 2

  uuid

encryptInfo = (passwd=generateUUID()) ->
  through.obj (file, enc, callback) ->

    if file.isStream()
      @emit "error", new PluginError("encryptInfo", "Streaming not supported")

    if file.isBuffer()
      try
        data  = JSON.parse file.contents.toString()
        edata = BadCipher.encrypt(data, passwd)
        file.contents = new Buffer(JSON.stringify {edata})
        @push file
      catch err
        @emit "error", new PluginError("encryptInfo", err)

    callback()

module.exports = encryptInfo
