module.exports = class ContactTagsActonView extends Mn.ItemView

    tagName: 'dl'

    attributes:
        'aria-haspopup': true
        'aria-expanded': false
        'data-position': 'bottom right'

    template: require 'views/templates/contacts/components/edit_tags'


    ui:
        tags:   ':input'
        labels: 'label'

    events:
        'change @ui.tags':  'onClickTag'
        'click @ui.labels': (event) -> event.stopPropagation()


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    serializeData: ->
        app = require 'application'

        tags: @model.get 'tags'
        alltags: app.tags.toJSON()


    onClickTag: (event) ->
        app = require 'application'

        tags = @ui.tags
            .serializeArray()
            .map (tag) -> app.tags.get(tag.value).get 'name'

        @triggerMethod 'tags:update', tags
