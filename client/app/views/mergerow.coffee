ContactViewModel = require 'views/models/contact'


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


    serializeData: ->
        return _.extend super,
            candidates: @model.get('candidates').map (contact) ->
                new ContactViewModel { new: false }, { model: contact}
            selected: @model.get('candidates').map (contact) =>
                contact in @model.get('toMerge')
            isMergeable: @model.isMergeable()


    check: (ev) ->
        elem = $(ev.target)
        @model.selectCandidate elem.val(), elem.is ':checked'


    dismiss: ->
        @model.collection.remove @model


    merge: ->
        mergeOptions = @model.buildMergeOptions()
        if Object.keys(mergeOptions).length is 0
            # No question to the user, go to merge directly
            @model.merge()
        else
            MergeView = require 'views/contacts/merge'
            app = require 'application'
            app.layout.showChildView 'alerts', new MergeView model: @model
