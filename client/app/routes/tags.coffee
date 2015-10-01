module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        ':slug': 'filter'


    filter: (slug) ->
        app = require 'application'
        app.model.set 'filter', slug
