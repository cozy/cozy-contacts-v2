module.exports = class Form extends Mn.Behavior

    events: ->
        'click @ui.add':     'addField'
        'keyup @ui.autoAdd': 'addField'
        'keyup @ui.inputs':  _.debounce @updateFields, 250
        'change @ui.inputs':  @updateFields

    triggers:
        'click @ui.submit': 'form:submit'


    updateFields: (event) ->
        el = event.currentTarget
        (attrs = {}).setValueOf el.name, el.value
        @view.model.set attrs, silent: true if @view.model
        @view.triggerMethod 'form:updatefield', event


    addField: (event)  ->
        if event.type is 'click'
            @view.triggerMethod 'form:addfield', event.currentTarget.value
        else
            $group   = @$(event.currentTarget).parents('[data-type]')
            type     = $group.data 'type'
            hasEmpty = !!$group.find('.value')
                .filter -> !this.value
                .length
            @view.triggerMethod 'form:addfield', type unless hasEmpty
