$           = require "jquery"
_           = require "underscore"
Backbone    = require "backbone"
ContactInfo = require "./contactinfo.coffee"

class ContactsView extends Backbone.View

  tagName: "ul"

  attributes:
    "data-role": "listview"

  initialize: ->
    _.bindAll(this, "render")
    @template = _.template $("#template-contact").html()

  render: ->
    listHTML = @collection.map (model) => @template model.toJSON()
    @$el.html listHTML.join("")
    this

module.exports = ContactsView
