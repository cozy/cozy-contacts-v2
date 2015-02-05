colorhash = require 'lib/colorhash'

module.exports = class Tag extends Backbone.Model
    urlRoot: 'tags'

    toString: -> @get 'name'
