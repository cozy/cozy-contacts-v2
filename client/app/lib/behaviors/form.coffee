module.exports = class Form extends Mn.Behavior

    behaviors:
        Keyboard:
            keymaps:
                '13': 'form:enter'


    events: ->
        'click @ui.add':     'addField'
        'keyup @ui.autoAdd': 'addField'
        'keyup @ui.inputs':  _.debounce @updateFields, 250
        'change @ui.inputs': 'updateFields'
        'click @ui.clear':   'clearField'
        'click @ui.delete':  'deleteField'

    triggers:
        'click @ui.submit': 'form:submit'


    updateFields: (event, el) ->
        el ?= event.currentTarget
        (attrs = {}).setValueOf el.name, el.value
        @view.model?.set attrs, silent: true
        @view.triggerMethod 'form:updatefield', event


    addField: (event) ->
        if event.type is 'click'
            @view.triggerMethod 'form:addfield', event.currentTarget.value
        else
            $group   = @$(event.currentTarget).parents('[data-type]')
            type     = $group.data 'type'
            hasEmpty = !!$group.find('.value')
                .filter -> !this.value
                .length
            @view.triggerMethod 'form:addfield', type unless hasEmpty


    clearField: (event) ->
        $el = @$(event.currentTarget).prev '.value'
        $el.val null
        @view.triggerMethod 'form:clearfield', event
        @updateFields event, $el[0]


    deleteField: (event) ->
        cid = @$(event.currentTarget).parents('[data-cid]').data 'cid'
        @view.triggerMethod 'form:deletefield', cid, event
