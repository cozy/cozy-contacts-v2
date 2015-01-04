class Modal extends Backbone.View

    id:'modal-dialog'
    className:'modalCY fade'
    attributes:
        'data-backdrop': "static" #prevent bs closing by backdrop
        'data-keyboard': "false"  #prevent bs closing by esc

    initialize: (options) ->
        @title ?= options.title
        @content ?= options.content
        @yes ?= options.yes or 'ok'
        @no ?= options.no or 'cancel'
        @cb ?= options.cb or ->
        @render()
        if options.cssSpaceName?
            @el.classList.add(options.cssSpaceName)
        @saving = false
        @$el.modal 'show'
        @el.tabIndex = 0
        @el.focus()

        # cut default bootstrap behaviour. Done here rather than in
        # delegateEvents to be run before bootstrap callback.
        @$('button.close').click (event) =>
            event.stopPropagation()
            @onNo()

        @$el.on 'keyup', @onKeyStroke

    events: ->
        "click #modal-dialog-no"  : 'onNo'
        "click #modal-dialog-yes" : 'onYes'
        'click'                   : 'onClickAnywhere'

    onNo: ->
        @close()
        @cb false

    onYes: ->
        @close()
        @cb true

    close: ->
        return if @closing
        @closing = true
        @$el.modal 'hide'
        setTimeout (=> @remove()), 500

    onKeyStroke: (e) =>
        e.stopPropagation()
        if e.which is 27
            @onNo()
            return false

    remove: ->
        @$el.off 'keyup', @onKeyStroke
        super

    render: ->
        close = $('<button class="close" type="button" data-dismiss="modal">×</button>')
        title = $('<p>').text @title
        head  = $('<div class="modalCY-header">').append close, title
        body  = $('<div class="modalCY-body"></div>').append @renderContent()
        yesBtn= $('<button id="modal-dialog-yes" class="btn btn-cozy">').text @yes
        foot  = $('<div class="modalCY-footer">').append yesBtn
        foot.prepend $('<button id="modal-dialog-no" class="btn btn-link">').text(@no) if @no

        # container = $('<div class="modalCY-content">').append head, body, foot
        # container = $('<div class="modal-dialog">').append container
        $("body").append @$el.append head, body, foot

    renderContent: -> @content

    # if the target is not a child element, the click targets the backdrop
    onClickAnywhere: (event) -> @onNo() if event.target.id is @id

Modal.alert = (title, content, cb) ->
    new Modal {title, content, yes: 'ok', no: null, cb}

Modal.confirm = (title, content, yesMsg, noMsg, cb) ->
    new Modal {title, content, yes: yesMsg, no:noMsg, cb}

Modal.error = (text, cb) ->
    new Modal
        title: t 'modal error'
        content: text
        yes: t 'modal ok'
        no: false
        cb: cb

module.exports = Modal
