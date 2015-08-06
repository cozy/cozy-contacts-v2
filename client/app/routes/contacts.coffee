module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        '': 'index'


    index: ->
        console.debug 'contacts default subroute'
