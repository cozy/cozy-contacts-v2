module.exports = class MergeRow extends Mn.ItemView

    template: require 'views/templates/mergerow'

    tagName: 'li'

    attributes:
        role: 'listitem'

    ui:
        submit:   '[type=submit]'


    modelEvents:
        'change': 'render'


    events:
        'click @ui.submit': 'merge'
        'click [type=checkbox]': 'check'


    check: (ev) ->
        elem = $(ev.target)
        @model.selectCandidate elem.val(), elem.is ':checked'


    merge: ->
        console.log 'run merge'
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
