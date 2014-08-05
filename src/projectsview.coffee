$        = require "jquery"
_        = require "underscore"
Backbone = require "backbone"

class ProjectsView extends Backbone.View

  attributes:
    "data-role":  "collapsible-set"
    "data-inset": "false"

  initialize: ->
    _.bindAll(this, "render")
    @template = _.template $("#template-projects").html()

  render: ->
    listHTML = @collection.map (model) => @template model.toJSON()
    @$el.html listHTML.join("")
    this

module.exports = ProjectsView
