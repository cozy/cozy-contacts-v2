Duplicates = require 'collections/duplicates'

t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class DuplicatesView extends Mn.CompositeView

    template: require 'views/templates/duplicates'

    tagName: 'section'

    className: 'duplicates'

    attributes:
        role: 'dialog'

    childViewContainer: 'ul'

    childView: require 'views/mergerow'

    templateHelpers: ->
        return size: @collection.size()

    events:
        'click [type=submit]': 'mergeAll'

    # childViewOptions: (model) ->
    #     console.log "childViewOptions"
    #     model: model

    initialize: ->
        console.log 'initialize view'
        app = require 'application'
        # Mn.bindEntityEvents @model, @, @model.viewEvents

        # Generate duplicates list.

        # CompareContacts = require "lib/compare_contacts"

        # @duplicates = CompareContacts.findSimilars app.contacts.toJSON()
        @collection = new Duplicates()
        @collection.findDuplicates app.contacts


        # @duplicates = [app.contacts.toJSON()[1..5]]
        console.log @collection
        # display it.

    # serializeData: ->
    #     console.log @duplicates.toJSON()
    #     return duplicates: @duplicates.toJSON()

        # _.extend super, lists: CONFIG.datapoints.types

    behaviors: ->
    #     opts =
    #         name: @options.model.get 'fn'

    #     Navigator: {}
        Dialog:    {}
    #     Form:      {}
    #     Dropdown:  {}
    #     Confirm:
    #         triggers:
    #             'click @ui.delete':
    #                 event:      'delete'
    #                 title:      t 'card confirm delete title', opts
    #                 message:    t 'card confirm delete message', opts
    #                 btn_ok:     t 'card confirm delete ok'
    #                 btn_cancel: t 'card confirm delete cancel'

    # ui:
    #     navigate: '[href^=contacts], [data-next]'
    #     edit:     '.edit'
    #     delete:   '.delete'
    #     submit:   '[type=submit]'
    #     cancel:   '.cancel'
    #     inputs:   '.group:not([data-cid]) :input:not(button)'
    #     add:      '.add button'
    #     clear:    '.clear'


    # modelEvents:
    #     'change:edit':     'render'
    #     'change:initials': 'updateInitials'
    #     'change':          -> @render() unless @model.get 'edit'
    #     'before:save':     'syncDatapoints'
    #     'save':            'onSave'
    #     'destroy':         -> @triggerMethod 'dialog:close'

    # childEvents:
    #     'form:key:enter': 'onFormKeyEnter'


    mergeAll: ->
        console.log 'mergeAll'

        mergeStep = (model) =>
            console.log 'mergeStep'


            index = 1 + @collection.indexOf model
            if index < @collection.size()
                @listenTo model, 'merged', =>
                    mergeStep @collection.at index

            @children.findByModel(model).merge()

        mergeStep @collection.first()
