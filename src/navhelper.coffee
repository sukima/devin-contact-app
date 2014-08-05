$            = require "jquery"
ContactInfo  = require "./contactinfo.coffee"
ContactsView = require "./contactsview.coffee"

module.exports = NavHelper =

	addBackButtons: ->
		backHTML = $("#back-button").html()

		$("[data-backbtn=true]>[data-role=header]").each ->
			$(this).prepend(backHTML)

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
