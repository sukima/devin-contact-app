$            = require "jquery"
_            = require "underscore"
ContactInfo  = require "./contactinfo.coffee"
ContactsView = require "./contactsview.coffee"
PGPInfo      = require "./pgpinfo.coffee"
PGPView      = require "./pgpview.coffee"
Projects     = require "./projects.coffee"
ProjectsView = require "./projectsview.coffee"
ErrorView    = require "./errorview.coffee"

renderViewInto = (view, pageEl) ->
  pageEl = $(pageEl)
  (data, type, reason) ->
    view.render(data, type, reason)
    pageEl.find("div[data-role=content]").prepend(view.el)
    pageEl.trigger "create"

renderErrorInto = (pageEl) ->
  renderViewInto new ErrorView(), pageEl

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

    contactInfo.fetch(reset: true)
    .then(renderViewInto contactsView, "#contact")
    .fail(renderErrorInto "#contact")

  loadPGPInfo: ->
    pgpInfo = new PGPInfo()
    pgpView = new PGPView(model: pgpInfo)

    pgpInfo.fetch(reset: true)
    .then(renderViewInto pgpView, "#pgp")
    .fail(renderErrorInto "#pgp")

  loadProjects: ->
    projects     = new Projects()
    projectsView = new ProjectsView(collection: projects)

    projects.fetch(reset: true)
    .then(projects.fetchContent)
    .then(renderViewInto projectsView, "#projects")
    .fail(renderErrorInto "#projects")
