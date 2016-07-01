{Filtered} = BackboneProjections
TagView = require 'views/contacts/components/tag'


module.exports = class ContactTagsActonView extends Mn.CompositeView

    tagName: 'dl'

    attributes:
        'aria-haspopup': true
        'aria-expanded': false
        'data-position': 'bottom right'

    template: require 'views/templates/contacts/components/edit_tags'


    childView: TagView

    childViewOptions: (model) ->
        contactViewModel: @model

    childViewContainer: 'ul'


    ui:
        tags:     'li:not(.create) input'
        create:   '.create'
        dropdown: 'dd'


    events:
        'change @ui.tags':                  'onClickTag'
        'click @ui.create button':          'toggleCreate'
        'keydown @ui.create [name="name"]': 'addNewTag'
        # Prevent unwanted dropdown close
        'click @ui.dropdown':               (event) -> event.stopPropagation()

    modelEvents:
        'change:tags': (model) ->
            @toggleCreate false
            @children.invoke 'render'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents


    onClickTag: (event) ->
        tags = @$('li:not(.create) input')
            .serializeArray()
            .map (tag) => @collection.get(tag.value).get 'name'

        @triggerMethod 'tags:update', tags


    toggleCreate: (toggle) ->
        if _.isNull(toggle) or not _.isBoolean(toggle)
            toggle = @ui.create.attr('aria-expanded') isnt 'true'

        @ui.create.attr 'aria-expanded', toggle
        @ui.create.find('[name="name"]').val ''

        @ui.create.find('input[name="name"]').trigger 'focus' if toggle


    addNewTag: (event) ->
        event.stopPropagation()

        value = event.currentTarget.value
        return if event.which isnt 13 or _.isEmpty value

        @triggerMethod 'tags:add', value
