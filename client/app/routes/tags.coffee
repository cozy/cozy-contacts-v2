app = undefined

module.exports = class TagsRouter extends Backbone.SubRoute

    routes:
        ':slug': 'filter'


    initialize: ->
        app = require 'application'

        style = document.createElement 'style'
        style.appendChild document.createTextNode ''
        document.head.appendChild style
        @sheet = style.sheet

        @listenTo app.channel, 'filter:tag', (tag) =>
            @sheet.deleteRule idx for rule, idx in @sheet.cssRules


    filter: (slug) ->
        app.search 'tag', slug

        idx = @sheet.cssRules.length
        @sheet.insertRule """
            [role=row]:not(.tag_#{slug}),
            [role=rowgroup]:not(.tag_#{slug}) { display: none }
        """, idx
