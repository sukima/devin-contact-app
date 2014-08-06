_        = require "underscore"
Backbone = require "backbone"

class Projects extends Backbone.Collection

  url: "/projects.json"

  initialize: ->
    _.bindAll this, "fetchContent"

  fetchContent: ->
    contentPromises = @map (model) ->
      $.ajax(url: model.get("url"), dataType: "html")
      .then (data) -> model.set("content", data)
    $.when(contentPromises...)

module.exports = Projects
