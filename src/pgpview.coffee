$        = require "jquery"
_        = require "underscore"
Backbone = require "backbone"

class PGPView extends Backbone.View

	initialize: ->
		@template = _.template $("#template-pgp").html()

	render: ->
    @$el.html(@template @model.toJSON())
		this

module.exports = PGPView
