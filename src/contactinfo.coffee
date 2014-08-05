Backbone  = require "backbone"
BadCipher = require "./badcipher.coffee"

class ContactInfo extends Backbone.Collection

  url: "info.json"

  parse: (resp, options) ->
    if resp.edata
      JSON.parse(BadCipher.decrypt(resp.edata))
    else
      resp

module.exports = ContactInfo
