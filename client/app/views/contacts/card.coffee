module.exports = class ContactCardView extends Mn.ItemView

    template: require 'views/templates/contacts/card'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'

    behaviors:
        Navigator: behaviorClass: require 'lib/behaviors/navigator'
        Dialog:    behaviorClass: require 'lib/behaviors/dialog'
        Form:      behaviorClass: require 'lib/behaviors/form'

    ui:
        navigate:     '[href^=contacts]'
        edit:         '.edit'
        save:         '.save'
        addfield:     '.add button'
        autoAddField: '.auto .value'
        inputFields:  'input, textarea'

    events: ->
        'click @ui.addfield':     'addField'
        'keyup @ui.autoAddField': 'addField'
        'keyup @ui.inputFields':  _.debounce @updateFields, 250
        'click @ui.save':         'save'

    modelEvents:
        'change:edit': 'render'


    initialize: ->
        @model.attachViewEvents @


    onShow: ->
        @ui.edit.focus()


    addField: (event)  ->
        if event.type is 'click'
            @triggerMethod "field:add", event.currentTarget.value
        else
            type = @$(event.currentTarget).siblings('.name').val()
            hasEmpty = !!@$(".#{type} input.value")
                .filter -> $(this).val() is ''
                .length

            @triggerMethod "field:add", type unless hasEmpty


    updateFields: (event) ->
        el = event.currentTarget
        (attrs = {}).setValueOf el.name, el.value
        @model.set attrs


    save: (event) ->
        @model.save()
