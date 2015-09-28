CompareContacts = require "lib/compare_contacts"


CHOICE_FIELDS =  ['fn', 'org', 'title', 'department', 'bday', 'nickname','note']
# , photo !

t = require 'lib/i18n'

CONFIG = require('config').contact


module.exports = class MergeView extends Mn.ItemView

    template: require 'views/templates/contacts/merge'

    tagName: 'section'

    className: 'card'

    attributes:
        role: 'dialog'




    behaviors: ->
    #     opts =
    #         name: @options.model.get 'fn'

    #     Navigator: {}
        Dialog:    {}
        Form:      {}
    #     Dropdown:  {}
    #     Confirm:
    #         triggers:
    #             'click @ui.delete':
    #                 event:      'delete'
    #                 title:      t 'card confirm delete title', opts
    #                 message:    t 'card confirm delete message', opts
    #                 btn_ok:     t 'card confirm delete ok'
    #                 btn_cancel: t 'card confirm delete cancel'

    ui:
    #     navigate: '[href^=contacts], [data-next]'
    #     edit:     '.edit'
    #     delete:   '.delete'
        submit:   '[type=submit]'
        cancel:   '.cancel'
        # inputs:   '.group:not([data-cid]) :input:not(button)'
        inputs:   'input'
    #     add:      '.add button'
    #     clear:    '.clear'


    # modelEvents:
    #     'change:edit':     'render'
    #     'change:initials': 'updateInitials'
    #     'change':          -> @render() unless @model.get 'edit'
    #     'before:save':     'syncDatapoints'
    #     'save':            'onSave'
    #     'destroy':         -> @triggerMethod 'dialog:close'

    events:
    #     'form:key:enter': 'onFormKeyEnter'
        'form:submit': 'merge'



    initialize: ->
        console.log 'initialize view merge'
        # STUB : take a to merge list automaticaly,
        # think about transmission later




        app = require 'application'

        # TODO : howto marionette fashion?
        @listenTo @, 'form:submit', @merge.bind @

        # Generate duplicates list.
        CompareContacts = require "lib/compare_contacts"

        MergeViewModel = require('views/models/merge')
        @model = new MergeViewModel()

        toMerge = CompareContacts.findSimilars(app.contacts.toJSON())[0]

        if toMerge?
            toMerge = toMerge.map (contact) ->
                console.log contact
                return app.contacts.get(contact.id)

            @model.set 'toMerge', toMerge
            Mn.bindEntityEvents @model, @, @model.viewEvents
        else
            return
        # @model.attributes.toMerge =

        # @duplicates = [app.contacts.toJSON()[1..5]]
        # return unless @toMerge
        # console.log @toMerge
        # # display it.
        @buildMergeChoices()


    buildMergeChoices: ->
        @mergeOptions = {}
        fields = CHOICE_FIELDS
        # _attachments  : Object

        toMerge = @model.get 'toMerge'
        toMerge = toMerge.map (contact) -> contact.toJSON()
        for field in fields
            options = []
            toMerge.forEach (contact, index) ->
                value = contact[field]
                # Remove useless values, and filter identical value.
                if value? and value isnt '' and not (options.some (option)->
                    option.value is value)
                        options.push
                            value: value
                            index: index
            # Ask for a choice if there is anything to choose.
            if options.length > 1
                @mergeOptions[field] = options

        # Photo :
        options = []
        toMerge.forEach (contact, index) ->
            if contact._attachments?
                options.push
                    value: "/contacts/#{contact.id}/picture.png"
                    index: index
        # Ask for a choice if there is anything to choose.
        if options.length > 1
            @mergeOptions['avatar'] = options

        console.log @mergeOptions
        # TODO : if @mergeOptions empty --> do merge whitout prompt !


    serializeData: ->
        return options: @mergeOptions
        # _.extend super, lists: CONFIG.datapoints.types

    merge: ->
        console.log 'merge'
        # get form data about merging

        # Do merge
        # merged = new Contact()
        toMerge = @model.get 'toMerge'
        toMerge = toMerge.map (contact) -> contact.toJSON()

        merged =
            datapoints: []
            tags: []
        # Merge DataPoints and not specific fields
        toMerge.forEach (contact) ->
            CompareContacts.mergeContacts merged, contact

        console.log @model

        # We rely on fn field to choose fn and n fields.
        fields = CHOICE_FIELDS
        if @model.has 'fn'
            @model.set 'n', @model.get('fn')
            fields = fields.concat 'n'

        for field in fields
            if @model.has field
                merged[field] = toMerge[@model.get field][field]
                # merged[field] = @model.get field

        # # Avatar picture
        # if @model.has 'avatar'


        console.log merged
        # Create new
        Contact = require 'models/contact'

        contact = new Contact()

        # Avatar picture
        if @model.has 'avatar'
            contact.setPicture toMerge[@model.get 'avatar']
        # contact.attributes = contact.parse merged
        console.log contact


        # TODO Deactivated!
        # contact.save contact.parse(merged),
        #     error: (model, response, options) ->
        #         console.log 'error'
        #         console.log response
        #     success: (model, response, options) =>
        #         console.log "Contact saved !"
        #         console.log model

        #         # Delete olds
        #         toMerge = @model.get 'toMerge'
        #         console.log toMerge

        #         async.each toMerge, (c, cb) ->
        #             c.destroy
        #                 success: (model, response, option) -> cb()
        #                 error: (model, response, option) -> cb response
        #         , (err) ->
        #             if err
        #                 console.log err
        #             else
        #                 console.log "deleted"


    # onRender: ->
    #     @$('.datapoints').each (index, el) =>
    #         name = el.dataset.type
    #         @addRegion name, "[data-type=#{name}]"
    #         @showChildView name, new DatapointsView
    #             collection:    @model[name]
    #             name:          name
    #             cardViewModel: @model

    #     @addRegion 'xtras-infos', '[data-type=xtras-infos]'
    #     @showChildView 'xtras-infos', new XtrasView model: @model

    #     return unless @model.get 'edit'

    #     @addRegion 'actions', '.actions'
    #     @showChildView 'actions', new EditActionsView model: @model


    # onDomRefresh: ->
    #     if @model.get('edit') then @ui.inputs.first().focus()
    #     else @ui.edit.focus()


    # onSave: ->
    #     return unless @model.get 'new'
    #     app  = require 'application'
    #     dest = "contacts/#{@model.get 'id'}"
    #     app.router.navigate dest, trigger: true


    # onEditCancel: ->
    #     @triggerMethod 'dialog:close' if @model.get 'new'


    # onFormKeyEnter: ->
    #     inputs = @$ ':input:not(button):not([type=hidden])'
    #     inputs.eq(inputs.index(document.activeElement) + 1).focus()


    # onFormFieldAdd: (type) ->
    #     return if type in CONFIG.xtras
    #     @getRegion('xtras').currentView.addEmptyField type


    # updateInitials: (model, value) ->
    #     @$('.initials').text value


    # syncDatapoints: ->
    #     @regionManager.each (region) =>
    #         return unless region.currentView?.getDatapoints
    #         name       = region.currentView.options.name
    #         datapoints = region.currentView.getDatapoints()
    #         @model.syncDatapoints name, datapoints
