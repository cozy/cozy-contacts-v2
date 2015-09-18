app              = require 'application'
ContactView      = require 'views/contact'
DocView          = require 'views/doc'
ImporterView     = require 'views/importer'
Contact          = require 'models/contact'

module.exports = class Router extends Backbone.Router
    routes:
        ''                    : 'list'
        'help'            : 'help'
        'import'              : 'import'
        'contact/new'         : 'newcontact'
        'contact/:id'         : 'showcontact'


    initialize: ->
        $('body').on 'keyup', (event) =>
            @navigate "", true if event.keyCode is 27 #ESC

        @isLargeScreen = $(window).width() > 900

        $(window).on 'resize', (event) =>
            if @isLargeScreen isnt $(window).width() > 900
                @isLargeScreen = $(window).width() > 900
                # force refresh to display the properview
                Backbone.history.loadUrl Backbone.history.fragment


    list: ->
        width = $(window).width()
        if width > 900 or not width then @help()
        else @displayView null
        $('#filterfied').focus()
        app.contactslist.activate null


    help: ->
        $(".toggled").removeClass 'toggled'
        $("#gohelp").addClass 'toggled'
        $(".activated").removeClass 'activated'
        @displayView new DocView()


    newcontact: ->
        $(".toggled").removeClass 'toggled'
        $("#new").addClass 'toggled'
        $(".activated").removeClass 'activated'
        contact = new Contact()
        contact.dataPoints.add name: 'tel', type: 'main', value: ''
        contact.dataPoints.add name: 'email', type: 'main', value: ''
        contact.once 'change:id', =>
            app.contacts.add contact
            @navigate "contact/#{contact.id}", false
        @displayViewFor contact, true
        $('#name').focus()


    showcontact: (id) ->
        $(".toggled").removeClass 'toggled'
        # may be wait for contacts to load
        if app.contacts.length is 0
            app.contacts.once 'sync', => @showcontact id
            return

        contact = app.contacts.get(id)

        if contact
            @displayViewFor contact
            app.contactslist.activate contact

        else
            alert t "this contact doesn't exist"
            @navigate '', true


    import: ->
        @help()
        setTimeout =>
            @importer = new ImporterView()
            if $('.modal').length is 0
                $('body').append @importer.render().$el
        , 1000


    # helpers
    displayView: (view, creation) ->
        @stopListening @currentContact if @currentContact

        if app.contactview?.needSaving and confirm t 'Save changes ?'
            app.contactview.save()
            app.contactview.model.once 'sync', => @displayView view
            return

        if @importer?
            @importer.close()
            @importer.$el.remove()
            @importer = null

        app.contactview.remove() if app.contactview
        app.contactview = view
        app.contactview?.$el.appendTo $('body')
        app.contactview?.render()

        if creation
            view?.$("#more-options").hide()
            view?.$("#adder").show()
            view?.$("#adder h2").show()


    displayViewFor: (contact, creation) ->
        @currentContact = contact
        @displayView new ContactView(model: contact), creation
        @listenTo contact, 'destroy', -> @navigate '', true

