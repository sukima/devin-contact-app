Backbone = require "backbone"

class ErrorView extends Backbone.View

  className: "alert alert-danger"

  render: (err={}, type, reason) ->
    type = if err.status && err.status >= 400
      err.status
    else
      type

    message = if reason? and type?
      "#{reason} (#{type})"
    else
      err.message || err

    if err.responseText && err.status >= 400
      message += "<br>#{err.responseText}"

    @$el.html "<strong>There was an error:</strong> #{message}"
    this

module.exports = ErrorView
