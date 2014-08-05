_        = require "underscore"
Backbone = require "backbone"

class Projects extends Backbone.Collection

  url: "/projects.json"

  parse: (resp, options) ->
    _.map resp, (content, section) -> {section, content}

module.exports = Projects
