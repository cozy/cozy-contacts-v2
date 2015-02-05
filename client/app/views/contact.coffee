ViewCollection = require 'lib/view_collection'
TagsView = require 'widgets/tags'
ContactName = require 'views/contact_name'
Datapoint = require 'models/datapoint'
request = require '../lib/request'


module.exports = class ContactView extends ViewCollection

    id: 'contact'
    template: require 'templates/contact'
    itemView: require 'views/datapoint'

    events: ->
        'click .addbirthday': @addClicked 'about', 'birthday'
        'click .addorg'     : @addClicked 'about', 'company'
        'click .addtitle'   : @addClicked 'about', 'title'
        'click .addcozy'    : @addClicked 'about', 'cozy'
        'click .addtwitter' : @addClicked 'about', 'twitter'
        'click .addabout'   : @addClicked 'about'
        'click .addtel'     : @addClicked 'tel'
        'click .addemail'   : @addClicked 'email'
        'click .addadr'     : @addClicked 'adr'
        'click .addother'   : @addClicked 'other'
        'click .addurl'     : @addClicked 'url'
        'click .addskype'   : @addClicked 'other', 'skype'
        'click #more-options': 'onMoreOptionsClicked'
        'click #name'       : 'toggleContactName'
        'click #undo'       : 'undo'
        'click #delete'     : 'delete'
        'change #uploader'  : 'photoChanged'

        'keyup input.value'    : 'addBelowIfEnter'
        'keydown #notes'       : 'resizeNote'
        'keypress #notes'      : 'resizeNote'

        'keyup #notes'     : 'doNeedSaving'
        'keydown #name'   : 'onNameKeyPress'
        'keydown textarea#notes': 'onNoteKeyPress'
        'keydown .ui-widget-content': 'onTagInputKeyPress'

        'blur #notes'     : 'changeOccured'

    constructor: (options) ->
        options.collection = options.model.dataPoints
        super

    initialize: ->
        super
        @listenTo @model     , 'change' , @modelChanged
        @listenTo @model     , 'sync'   , @onSuccess
        @listenTo @collection, 'change' , =>
            @needSaving = true
            @changeOccured()
        @listenTo @collection, 'remove' , =>
            @needSaving = true
            @changeOccured()

        # if the contact is open when it's removed, we redirect the user to
        # the main page
        @listenTo @model, 'remove', -> window.app.router.navigate '', true

    getRenderData: ->
        _.extend {}, @model.toJSON(),
            hasPicture: not not @model.get('pictureRev')
            fn: @model.get 'fn'
            timestamp: Date.now()

    afterRender: ->
        @contactName = new ContactName
            model: @model
            onKeyup: (ev) =>
                @doNeedSaving ev

            onBlur: (ev) =>
                @changeOccured()
                @needSaving = true
            contactWidget: @
        @contactName.render()

        @zones = {}
        for type in ['about', 'email', 'adr', 'tel', 'url', 'other']
            @zones[type] = @$('#' + type + 's ul')

        @hideEmptyZones()
        @savedInfo = @$('#save-info').hide()
        @needSaving = false
        @notesfield = @$('#notes')
        @uploader = @$('#uploader')[0]
        @picture  = @$('#picture .picture')
        @tags = new TagsView
            el: @$ '.tags'
            model: @model

        @tags.render()
        @tags.on 'tagClicked', (tag) =>
            $("#filterfield").val tag
            $("#filterfield").trigger 'keyup'
            $(".dropdown-menu").hide()

        super
        @$el.niceScroll()
        @resizeNote()
        @currentState = @model.toJSON()

        @$('a#infotab').tab('show') if $(window).width() < 900
        # resize nice scroll when we switch to note tab
        @$('a[data-toggle="tab"]').on 'shown', =>
            @$('#left').hide() if $(window).width() < 900
            @resizeNiceScroll()
        @$('a#infotab').on 'shown', =>
            @$('#left').show()
            @resizeNiceScroll()

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

        for name in ['birthday', 'org', 'title', 'cozy']
            hasOne = @model.dataPoints.hasOne 'about', name
            @$("#adder .add#{name}").toggle not hasOne

        # hide the adder if it is empty
        @$('#adder h2').toggle @$('#adder a:visible').length isnt 0
        @resizeNiceScroll()

    appendView: (dataPointView) ->
        return unless @zones
        type = dataPointView.model.get 'name'
        @zones[type].append dataPointView.el
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

            # no need to save in this case
            if _.isEqual @currentState, @model.toJSON()
                @needSaving = false
            else
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

    photoChanged: =>
        file = @uploader.files[0]

        unless file.type.match /image\/.*/
            return alert t 'This is not an image'

        reader = new FileReader()
        img = new Image()
        reader.readAsDataURL file
        reader.onloadend = =>
            img.src = reader.result
            img.onload = =>
                IMAGE_DIMENSION = 600
                ratiodim = if img.width > img.height then 'height' else 'width'
                ratio = IMAGE_DIMENSION / img[ratiodim]

                # use canvas to resize the image
                canvas = document.createElement 'canvas'
                canvas.height = canvas.width = IMAGE_DIMENSION
                ctx = canvas.getContext '2d'
                ctx.drawImage img, 0, 0, ratio*img.width, ratio*img.height
                dataUrl =  canvas.toDataURL 'image/jpeg'

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
