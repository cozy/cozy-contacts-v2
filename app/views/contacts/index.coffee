ContactViewModel = require 'views/models/contact'
ContactRowView   = require 'views/contacts/row'
Slugifier = require 'lib/slugifier'

Indexes = Backbone.Collection

{indexes} = require 'config'

filtered = undefined


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


    buildChildView: (child) ->
        if @_hasContacts
            ChildView = ContactRowView
        else
            ChildView = @constructor

        new ChildView model: child


    showCollection: ->
        index = 0
        models = @_getModels()

        setTimeout _render = =>
            model = models[index]
            return @trigger 'show:collection' unless models.length and model

            view = @buildChildView model

            @_updateIndices view, true, index
            @children.add view
            @renderChildView view, index
            view._parent = @

            index++
            setTimeout _render


    _createBuffer: ->
        document.createDocumentFragment()


    # To prevents inconsistencies on filtered collection, we find the view to
    # remove base on its underlying model rather on its viewModel
    _onCollectionRemove: (vmodel) ->
        baseModel = vmodel.model
        view = @children.find (view) -> view.model.model is baseModel
        @removeChildView view
        @checkEmpty()
        @toggleEmpty()


    _onCollectionAdd: (child, collection, opts) ->
        @destroyEmptyView()
        ChildView = @getChildView child
        @addChild child, ChildView, opts.index
        @toggleEmpty()


    _getModels: ->
        # scored mode, render a filtered collection
        models = if @_mode is 'scored'
            filtered.get()
        # indexed mode, char chunk branch
        else if @_hasContacts
            filtered.get index: @model.get 'char'
        # indexed mode, root indexes collection
        else
            @collection.models


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
            index = @model.get 'char'
            @collection = Backbone.Radio.channel "idx.#{index}"
            @childViewContainer = 'ul'

        # We're in indexed mode and hadn't any contact > chunks char root
        else if @_mode is 'indexed' and not @_hasContacts
            @collection = new Indexes Array::map.call indexes, (char) -> {char}
            @once 'show:collection', ->
                require('application').channel.trigger 'busy:disable'

        # Add listener to update tags classes if view displays contacts
        if @_hasContacts
            @sort = true
            @listenTo @collection,
                'reset':       @updateTagClasses
                'update':      @updateTagClasses
                'change:tags': @updateTagClasses

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
            @stopListening @collection, 'sort' if @_hasContacts
        else
            setTimeout =>
                @_initialEvents()
                @updateTagClasses()


    toggleEmpty: ->
        @el.classList.toggle 'empty', not @_getModels().length


    updateTagClasses: ->
        tags = _.chain filtered.get index: @model?.get 'char'
            .invoke 'get', 'tags'
            .flatten()
            .compact()
            # See TagsRouter#filter and
            # https://github.com/cozy/cozy-contacts/issues/262
            .map Slugifier.slugify
            .map (slug) -> "tag_#{slug}"
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
