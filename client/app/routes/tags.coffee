Slugifier = require '../lib/slugifier'
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


    filter: (tag) ->
        app.search 'tag', tag
        # We determine tag's slug right here. It's a little
        # bit too late, slugs should set at least when data is parsed
        # from the server, or directly server-side,
        # but it implies to change how the tags are working
        # in the whole application (i.e. use plain objects instead of strings).
        # This refactoring is too much at this time to fix only this bug.
        # See https://github.com/cozy/cozy-contacts/issues/262
        slug = Slugifier.slugify tag
        idx = @sheet.cssRules.length
        @sheet.insertRule """
            [role=row]:not(.tag_#{slug}),
            [role=rowgroup]:not(.tag_#{slug}) { display: none }
        """, idx
