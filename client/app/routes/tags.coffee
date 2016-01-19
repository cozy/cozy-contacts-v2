app = undefined

module.exports = class ContactsRouter extends Backbone.SubRoute

    routes:
        ':slug': 'filter'


    initialize: ->
        app = require 'application'

        style = document.createElement 'style'
        style.appendChild document.createTextNode ''
        document.head.appendChild style
        @sheet = style.sheet

        @listenTo app.vent, 'filter:tag', (tag) =>
            rulesLen = @sheet.cssRules.length
            if tag and rulesLen > 1 or not tag and rulesLen is 1
                @sheet.deleteRule 0


    filter: (slug) ->
        app.search 'tag', slug

        idx = @sheet.cssRules.length
        @sheet.insertRule """
            [role=row]:not(.tag_#{slug}),
            [role=rowgroup]:not(.tag_#{slug}) { display: none }
        """, idx
