module.exports = class MergeRow extends Mn.ItemView

    template: require 'views/templates/mergerow'

    tagName: 'dl'

    attributes:
        role: 'mergegroup'

    ui:
        submit:   '[type=submit]'
        dismiss:  '.cancel'


    modelEvents:
        'change': 'render'


    events:
        'click @ui.submit': 'merge'
        'click [type=checkbox]': 'check'
        'click @ui.dismiss': 'dismiss'


    check: (ev) ->
        elem = $(ev.target)
        @model.selectCandidate elem.val(), elem.is ':checked'

    dismiss: ->
        @destroy()

    merge: ->
        if @model.get('toMerge').length <= 1
            # cant merge one or 0 contact, pass
            console.log 'not enought contact to merge.'
            return

        mergeOptions = @model.buildMergeOptions()
        if Object.keys(mergeOptions).length is 0
            console.log "empty merge options"
            # go to merge directly
            @model.merge()
        else
            console.log "choices to be done !"

            MergeView = require 'views/contacts/merge'
            app = require 'application'

            app.layout.showChildView 'alerts', new MergeView model: @model
