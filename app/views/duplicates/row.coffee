ContactViewModel = require 'views/models/contact'


module.exports = class MergeRow extends Mn.ItemView

    template: require 'views/templates/duplicates/row'

    tagName: ->
        if @model.has 'result' then 'div' else 'dl'

    className: ->
        if @model.has 'result' then 'merged' else ''

    attributes: ->
        role: if @model.has 'result' then 'row' else 'rowgroup'


    ui:
        submit:   '[type="submit"]'
        dismiss:  '.cancel'


    modelEvents:
        'change':         'render'
        'contacts:merge': 'onContactsMerge'

    events:
        'click @ui.submit':      'merge'
        'click [type="checkbox"]': 'check'
        'click @ui.dismiss':     'dismiss'


    serializeData: ->
        if @model.has 'result'
            result = new  ContactViewModel { new: false }
            , { model: @model.get('result')}
        else
            result = undefined

        return _.extend super,
            candidates: @model.get('candidates').map (contact) ->
                new ContactViewModel { new: false }, { model: contact}
            selected: @model.get('candidates').map (contact) =>
                contact in @model.get('toMerge')
            isMergeable: @model.isMergeable()
            result: result
            merging: @merging


    check: (ev) ->
        elem = $(ev.target)
        @model.selectCandidate elem.val(), elem.is ':checked'


    dismiss: ->
        @model.collection.remove @model


    onContactsMerge: ->
        @merging = false
        @render()


    merge: ->
        @triggerMethod 'merge'
        @merging = true
        @$('button, input').prop 'disabled', true
        # Hack to help firefox to display the spinner.
        _.defer => @ui.submit.attr 'aria-busy', true

        mergeOptions = @model.buildMergeOptions()
        if Object.keys(mergeOptions).length is 0
            # No question to the user, go to merge directly
            @model.merge()
        else
            MergeView = require 'views/contacts/merge'
            {layout}  = require 'application'
            layout.showChildView 'alerts', new MergeView model: @model
