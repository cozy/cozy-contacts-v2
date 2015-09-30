module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        ':slug': 'filter'


    filter: (slug) ->
        app = require 'application'
        app.search 'tag', slug
