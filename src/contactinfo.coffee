Backbone  = require "backbone"
BadCipher = require "bad-cipher"

class ContactInfo extends Backbone.Collection

  url: "info.json"

  parse: (resp, options) ->
    if resp.edata
      @wasDecrypted = true
      JSON.parse(BadCipher.decrypt(resp.edata))
    else
      @wasDecrypted = false
      resp

module.exports = ContactInfo
