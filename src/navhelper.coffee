$            = require "jquery"
_            = require "underscore"
ContactInfo  = require "./contactinfo.coffee"
ContactsView = require "./contactsview.coffee"

module.exports = NavHelper =

	addBackButtons: ->
		backHTML = _.template $("#back-button").html()

		$("[data-role=page]").each ->
			$el     = $(this)
			backBtn = $el.data("backbtn") || "false"

			return if backBtn is "false"

			title = $el.data("backtitle") || "Back"
			route = if backBtn in ["index", "true"]
				""
			else
				backBtn

			$el.find("[data-role=header]")
			.prepend(backHTML {title, route})

	addGravatarIcons: ->
		gravatarHTML = $("#gravatar").html()

		$("[data-gravatar=true]>[data-role=header]").each ->
			$(this).append(gravatarHTML)

	loadContactInfo: ->
		contactInfo  = new ContactInfo()
		contactsView = new ContactsView(collection: contactInfo)
		contactInfo.fetch(reset: true).then ->
			$("#contact>div[data-role=content]").prepend(contactsView.el)
			contactsView.render()
