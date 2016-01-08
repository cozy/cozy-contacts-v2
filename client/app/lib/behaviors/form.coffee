module.exports = class Form extends Mn.Behavior

    behaviors:
        Keyboard:
            keymaps:
                '13':
                    event: 'form:key:enter'
                    preventDefault: false


    events: ->
        'click @ui.formAdd':     'addField'
        'keyup @ui.formAutoAdd': 'addField'
        'keyup @ui.formInputs':  _.debounce @updateFields, 250
        'change @ui.formInputs': 'updateFields'
        'click @ui.formClear':   'clearField'
        'click @ui.formDelete':  'deleteField'

    triggers:
        'click @ui.formSubmit': 'form:submit'


    updateFields: (event, el) ->
        el ?= event.currentTarget
        (attrs = {}).setValueOf el.name, el.value
        @view.model?.set attrs, silent: true
        el.classList.toggle 'empty', el.value is ''
        @view.triggerMethod 'form:field:update', el, event


    addField: (event) ->
        if event.type is 'click'
            @view.triggerMethod 'form:field:add', event.currentTarget.value
        else
            $group   = @$(event.currentTarget).parents('[data-type]')
            type     = $group.data 'type'
            hasEmpty = !!$group.find('.value')
                .filter -> !this.value
                .length
            @view.triggerMethod 'form:field:add', type unless hasEmpty


    clearField: (event) ->
        $el = @$(event.currentTarget).prev '.value'
        $el.val null
        @view.triggerMethod 'form:field:clear', event
        @updateFields event, $el[0]


    deleteField: (event) ->
        cid = @$(event.currentTarget).parents('[data-cid]').data 'cid'
        @view.triggerMethod 'form:field:delete', cid, event

