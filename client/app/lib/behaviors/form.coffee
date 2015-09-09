module.exports = class Form extends Mn.Behavior

    events: ->
        'click @ui.add':     'addField'
        'keyup @ui.autoAdd': 'addField'
        'keyup @ui.inputs':  _.debounce @updateFields, 250

    triggers:
        'click @ui.submit': 'form:submit'


    updateFields: (event) ->
        el = event.currentTarget
        (attrs = {}).setValueOf el.name, el.value
        @view.model.set attrs


    addField: (event)  ->
        if event.type is 'click'
            @view.triggerMethod 'form:addfield', event.currentTarget.value
        else
            type = @$(event.currentTarget).parents('[data-group]').data 'group'
            hasEmpty = !!@$("[data-group=#{type}] input.value")
                .filter -> $(this).val() is ''
                .length

            @view.triggerMethod 'form:addfield', type unless hasEmpty
