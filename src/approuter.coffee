$        = require "jquery"
Backbone = require "backbone"

class AppRouter extends Backbone.Router

  routes:
    "":         -> @changeTo("#index")
    "about":    -> @changeTo("#about")
    "contact":  -> @changeTo("#contact")
    "pgp":      -> @changeTo("#pgp")
    "projects": -> @changeTo("#projects")

  changeTo: (pageSelector) ->
    $("body").pagecontainer "change", $(pageSelector)

module.exports = AppRouter
