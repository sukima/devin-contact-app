$         = require "jquery"
AppRouter = require "./approuter.coffee"
NavHelper = require "./navhelper.coffee"

$(document).on "mobileinit", ->
  $.mobile.ajaxEnabled          = false
  $.mobile.linkBindingEnabled   = false
  $.mobile.hashListeningEnabled = false
  $.mobile.pushStateEnabled     = false
  $.mobile.autoInitializePage   = false

$ ->
  NavHelper.addBackButtons()
  NavHelper.addGravatarIcons()
  NavHelper.loadContactInfo()
  NavHelper.loadPGPInfo()
  $.mobile.initializePage()

  new AppRouter()
  Backbone.history.start()

require "jquery-mobile"
