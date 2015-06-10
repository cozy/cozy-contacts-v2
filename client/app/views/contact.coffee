TagsView       = require 'widgets/tags'
ContactName    = require 'views/contact_name'
Contact        = require 'models/contact'
ViewCollection = require 'lib/view_collection'
Datapoint      = require 'models/datapoint'
request        = require '../lib/request'

module.exports = class ContactView extends ViewCollection

    id: 'contact'
    template: require 'templates/contact'
    itemView: require 'views/datapoint'

    events: ->
        'click .addcozy'      : @addClicked 'about', 'cozy'
        'click .addtwitter'   : @addClicked 'social', 'twitter'
        'click .addabout'     : @addClicked 'about'
        'click .addtel'       : @addClicked 'tel'
        'click .addemail'     : @addClicked 'email'
        'click .addadr'       : @addClicked 'adr'
        'click .addother'     : @addClicked 'other'
        'click .addurl'       : @addClicked 'url'
        'click .addrelation'  : @addClicked 'relation'
        'click .addchat'      : @addClicked 'chat'
        'click .addskype'     : @addClicked 'chat', 'skype'
        'click #more-options' : 'onMoreOptionsClicked'
        'click #name'         : 'toggleContactName'
        'click #undo'         : 'undo'
        'click #delete'       : 'delete'

        'keyup input.value' : 'addBelowIfEnter'
        'keydown #notes'    : 'resizeNote'
        'keypress #notes'   : 'resizeNote'

        'keyup #notes'               : 'doNeedSaving'
        'keydown #name'              : 'onNameKeyPress'
        'keydown textarea#notes'     : 'onNoteKeyPress'
        'keydown .ui-widget-content' : 'onTagInputKeyPress'

        'blur #notes'                 : 'changeOccured'
        'blur .datapoint input.value' : 'changeOccured'
        'click #picture'              : 'choosePhoto'

    constructor: (options) ->
        options.collection = options.model.dataPoints
        super

    initialize: ->
        super
        @listenTo @model         , 'change' , @modelChanged
        @listenTo @model         , 'sync'   , @onSuccess
        @listenTo @collection    , 'change' , =>
            @needSaving = true
            @changeOccured()
        @listenTo @collection    , 'remove' , =>
            @needSaving = true
            @changeOccured()

        # if the contact is open when it's removed, we redirect the user to
        # the main page
        @listenTo @model, 'remove', -> window.app.router.navigate '', true

    # Generate some metadata for template: say if a picture is set, look
    # for the full name, and set a first timestamp (useful to detect changes).
    getRenderData: ->
        templateData = _.extend {}, @model.toJSON(),
            hasPicture: not not @model.get('pictureRev')
            fn: @model.get 'fn'
            timestamp: Date.now()
        return templateData

    afterRender: ->
        @contactName = new ContactName
            model: @model
            onKeyup: (ev) =>
                @doNeedSaving ev

            onBlur: (ev) =>
                @needSaving = true
                @changeOccured()

            contactWidget: @

        @contactName.render()

        @zones = {}
        for type in Contact.DATAPOINT_TYPES
            @zones[type] = @$ "##{type}s ul"

        @hideEmptyZones()
        @savedInfo = @$('#save-info').hide()
        @needSaving = false
        @notesfield = @$('#notes')
        @picture  = @$('#picture .picture')
        @tags = new TagsView
            el: @$ '.tags'
            model: @model
            onBlur: (ev) =>
                @needSaving = true
                @changeOccured true


        @tags.render()
        @tags.on 'tagClicked', (tag) =>
            $("#filterfield").val tag
            $("#filterfield").trigger 'keyup'
            $(".dropdown-menu").hide()

        super
        @$el.niceScroll()
        @resizeNote()
        @currentState = @model.toJSON()

        @bindTabs()
        @bindMenus()

        if @model.isNew()
            @toggleContactName()

    remove: ->
        @$el.getNiceScroll().remove()
        super

    hideEmptyZones: ->
        for type, zone of @zones
            hasOne = @model.dataPoints.hasOne type
            zone.parent().toggle hasOne
            @$("#adder .add#{type}").toggle not hasOne

        # hide the adder if it is empty
        @$('#adder h2').toggle @$('#adder a:visible').length isnt 0
        @resizeNiceScroll()

    appendView: (dataPointView) ->
        return unless @zones
        type = dataPointView.model.get 'name'
        @zones[type]?.append dataPointView.el
        @hideEmptyZones()

    addClicked: (name, type) -> (event) ->
        event.preventDefault()
        point = new Datapoint name: name
        point.set 'type', type if type?
        point.set 'value', '@' if type is 'twitter'
        @model.dataPoints.add point
        toFocus = if type? then '.value' else '.type'
        typeField = @zones[name].children().last().find(toFocus)
        typeField.focus()
        typeField.select()

    doNeedSaving: (event) =>
        isEnter = event.keyCode is 13 or event.which is 13
        @changeOccured true if isEnter and event.target.id is 'name'
        @needSaving = true
        return true

    changeOccured: (forceImmediate) =>
        # wait 10 ms, for newly focused to be focused
        setTimeout =>
            # there is still something focused
            # we wait for it to lose focus, changeOccured will be called again
            # when the newly focused blur
            if @$('input:focus, textarea:focus').length and not forceImmediate
                return true

            @model.setN @contactName.getStructuredName()
            @model.set note: @notesfield.val()
            @model.set 'bday', @$('.bday-input').val()
            @model.set 'org', @$('.org-input').val()
            @model.set 'title', @$('.title-input').val()
            @model.set 'department', @$('.department-input').val()
            @model.set 'url', @$('.url-input').val()

            # no need to save in this case
            if _.isEqual @currentState, @model.toJSON()
                @needSaving = false
            else
                @needSaving = true
                @savedInfo.hide()
                @save()
        , 10


    delete: ->
        @model.destroy() if @model.isNew() or confirm t 'are you sure'

    save: =>
        return unless @needSaving
        @needSaving = false
        @savedInfo.show().text 'saving changes'

        @model.save
            success: =>
                @collection.trigger 'change', @model

    toggleContactName: ->
        if @$('#name').is ':visible'
            @$('#name').hide()
            @$('#contact-name').show()
            @$('#first').focus()
        else
            @$('#name').show()
            @$('#contact-name').hide()
            @$('#name').blur()


    choosePhoto: =>
        intent =
            type  : 'pickObject'
            params:
                objectType : 'singlePhoto'
                isCropped  : true
                proportion : 1
                maxWidth   : 10
                minWidth   : 10
        timeout = 10800000 # 3 hours
        that = this
        choosePhoto_answer = @choosePhoto_answer
        window.app.intentManager.send('nameSpace',intent, timeout)
        .then( choosePhoto_answer
            ,
            (error) ->
                console.error 'contact : response in error : ', error
        )


    choosePhoto_answer : (message) =>
        answer = message.data
        if answer.newPhotoChosen
            @changePhoto(answer.dataUrl)

    intentHandler: (intentID, cb)->
        @castIntent[intentID] = cb


    onMoreOptionsClicked: =>
        @$("#more-options").fadeOut =>
            @$("#adder h2").show()
            @$("#adder").fadeIn()
            @resizeNiceScroll()

    undo: =>
        return unless @lastState
        @model.set @lastState, parse: true
        @model.save null, undo: true
        @resizeNote()

    onSuccess: (model, result, options) ->
        if options.undo
            @savedInfo.text t('undone') + ' '
            @lastState = null
            setTimeout =>
                @savedInfo.fadeOut()
            , 1000
        else
            @savedInfo.text t('changes saved') + ' '
            undo = $("<a id='undo'>#{t('undo')}</a>")
            @savedInfo.append undo
            @lastState = @currentState

        @currentState = @model.toJSON()

    modelChanged: =>
        @$('#name').text @model.get 'fn'
        @notesfield.val @model.get 'note'
        @tags?.refresh()
        id = @model.get 'id'
        if id and @model.get('pictureRev')
            timestamp = Date.now()
            @$('.picture').prop 'src', "contacts/#{id}/picture.png?#{timestamp}"
        else
            @$('.picture').prop 'src', "img/defaultpicture.png"
        @resizeNote()

    addBelowIfEnter: (event) ->
        # only enters
        return true unless (event.which or event.keyCode) is 13
        zone = $(event.target).parents('.zone')[0].id
        name = zone.substring 0, zone.length-1
        point = new Datapoint name: name
        @model.dataPoints.add point
        typeField = @zones[name].children().last().find('.type')
        typeField.focus()
        typeField.select()
        return false

    resizeNote: (event) ->
        notes = @notesfield.val()
        rows = loc = 0
        # count occurences of \n in notes
        rows++ while loc = notes.indexOf("\n", loc) + 1

        @notesfield.prop 'rows', rows + 2
        @resizeNiceScroll()


    resizeNiceScroll: (event) =>
        @$el.getNiceScroll().resize()


    bindTabs: ->
        @$('[role=tablist]').on 'click', '[role=tab]', (event) =>
            $panel = @$ "##{event.target.getAttribute 'aria-controls'}"

            @$('[role=tabpanel]').not($panel).attr 'aria-hidden', true
            $panel.attr 'aria-hidden', false

            @$('nav [role=tab]').attr 'aria-selected', false
            $(event.target).attr 'aria-selected', true

    bindMenus: ->
        toggleMenu = (event) =>
            if event?.delegateTarget.getAttribute('role') is 'menu'
                event.stopPropagation()
                menu = event.delegateTarget
                expanded = menu.getAttribute('aria-expanded') is 'true'
                menu.setAttribute 'aria-expanded', !expanded
            else
                @$('[role=menu]').attr 'aria-expanded', false

        @$ '[role=menu]'
            .on 'click', '[aria-controls]', toggleMenu
        @$el
            .on 'click', toggleMenu


    changePhoto:(dataUrl)->
        @picture.attr 'src', dataUrl
        @model.photo = dataUrl.split(',')[1]
        @model.savePicture()


    onTagInputKeyPress: (event) ->
        keyCode = event.keyCode || event.which
        if keyCode is 9
            if event.shiftKey
                @$('#name').focus()
            else
                @$('.type:visible').first().focus()
            event.preventDefault()
            false

    onNameKeyPress: (event) ->
        keyCode = event.keyCode || event.which
        if keyCode is 9
            if event.shiftKey
                @$('textarea#notes').focus()
            else
                @$('input.ui-widget-content').focus()
            event.preventDefault()
            false

    onNoteKeyPress: (event) ->
        keyCode = event.keyCode || event.which
        if keyCode is 9
            if event.shiftKey
                @$('.value:visible').last().focus()
            else
                @$('#name').focus()
            Event.preventDefault()
            false
