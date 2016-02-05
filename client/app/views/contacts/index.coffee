ContactViewModel = require 'views/models/contact'
ContactRowView   = require 'views/contacts/row'

Indexes = Backbone.Collection

{indexes} = require 'config'


module.exports = class Contacts extends Mn.CompositeView

    sort: false

    # backbone dom node dynamics are called before initialize, internal sets are
    # so unavailable, so fallback to root method for detection
    tagName: ->
        {model} = require 'application'
        if model.get('scored')
            'ul'
        else if @model?.has('char')
            'dl'
        else
            'div'

    attributes: ->
        {model} = require 'application'
        role: 'rowgroup' if model.get('scored') or @model?.has('char')

    template: require 'views/templates/contacts'


    events: ->
        # if there isn't any model, it's the root tree, so delegate list events
        'change [type="checkbox"]': 'updateBulkSelection' unless @model?


    attachElContent: (html) ->
        @el.innerHTML = html
        return @


    attachBuffer: (compositeView, buffer) ->
        selector = Mn._getValue @childViewContainer, @
        el  = if _.isString selector then @el.querySelector selector else @el
        el.appendChild buffer
        @toggleEmpty()


    buildChildView: (child) ->
        if @_hasContacts
            ChildView = ContactRowView
        else
            ChildView = @constructor

        new ChildView model: child


    showCollection: ->
        # scored mode, render a filtered collection
        models = if @_mode is 'scored'
            @collection.get()
        # indexed mode, char chunk branch
        else if @_hasContacts
            @collection.get index: @model.get 'char'
        # indexed mode, root indexes collection
        else
            @collection.models

        models.forEach (model, index) =>
            view  = @buildChildView model

            @_updateIndices view, true, index
            @children.add view
            @renderChildView view, index
            view._parent = @


    _createBuffer: ->
        elBuffer = document.createDocumentFragment()
        @_bufferedChildren.forEach (buffer) -> elBuffer.appendChild buffer.el
        return elBuffer


    # To prevents inconsistencies on filetered collection, we find the view to
    # remove base on its underlying model rather on its viewModel
    _onCollectionRemove: (vmodel) ->
        baseModel = vmodel.model
        view = @children.find (view) -> view.model.model is baseModel
        @removeChildView view
        @checkEmpty()


    # This CompositeView can be used in two different mode:
    # 1. an _indexed_ mode, in which the contacts' collection is splitted in
    # chunks of subcollection, one by `[a-z#]` chars
    # 2. a _scored_ mode, in which all the collection is rendered in one block
    # and sorted by a score instead of by initials
    #
    # Initialize detects the relevant mode and adapt its internal configuration.
    #
    # The mode is related to the part of the branch/leaf tree: if the rendered
    # leaf contains `ContactsViewModel`s, the actual view _must_ knows it for
    # internal purposes.
    #
    initialize: ->
        {model, filtered} = require 'application'

        @_mode = if model.get('scored') then 'scored' else 'indexed'
        # If we're on a branch (char chunk), or mode's `scored`, we assume we
        # render `ContactView` leafs
        @_hasContacts = (@model?.has('char') or @_mode is 'scored')


        # We've Contacts and we're in indexed mode > it's a chunk char branch
        if @_hasContacts and @_mode is 'indexed'
            @collection = filtered
            @childViewContainer = 'ul'
            @filter = (vmodel) =>
                _.includes @collection.get(index: @model.get 'char'), vmodel

        # We're in indexed mode and hadn't any contact > chunks char root
        else if @_mode is 'indexed' and not @_hasContacts
            @collection = new Indexes Array::map.call indexes, (char) -> {char}

        # Add listener to update tags classes if view displays contacts
        if @_hasContacts
            @sort = true
            @listenTo @collection, 'update': @updateTagClasses
            @listenTo @collection.underlying, 'change:tags': @updateTagClasses

        # Force highlight refresh when filter is updated
        if @_mode is 'scored'
            @listenTo model, 'change:filter': -> @children.invoke 'highlight'

        # Temporary disable events reacts when scored view is in front
        if @_mode is 'indexed'
            @listenTo model, 'change:scored': @toggleEvents


    toggleEvents: (nil, disable) ->
        # appViewModel.scored == disable filtered collection events
        if disable
            @stopListening @collection, 'add'
            @stopListening @collection, 'remove'
            @stopListening @collection, 'reset'
            @stopListening @collection, 'sort'
        else
            setTimeout =>
                @_initialEvents()
                @updateTagClasses()


    toggleEmpty: ->
        @el.classList.toggle 'empty', not @children.length


    updateTagClasses: ->
        tags = _.chain @collection.get index: @model?.get 'char'
            .invoke 'get', 'tags'
            .flatten()
            .compact()
            .map (tag) -> "tag_#{tag}"
            .join ' '
            .value()
        if tags.length
            @el.className = tags
        else
            @el.removeAttribute 'class'
        @toggleEmpty()


    updateBulkSelection: (event) ->
        selected = event.currentTarget.checked
        id       = event.currentTarget.value
        method   = if selected then 'contacts:select' else 'contacts:unselect'
        @triggerMethod method, id


    # methods aliases
    onRender: @::updateTagClasses
