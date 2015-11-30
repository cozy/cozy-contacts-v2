{Sorted} = BackboneProjections

ContactViewModel = require 'views/models/contact'

# CharIndex = require 'collections/charindex'


module.exports = class Contacts extends Mn.CompositeView

    tagName: ->
        if @model then 'dl' else 'div'

    attributes: ->
        role: 'rowgroup' if @model

    template: require 'views/templates/contacts'


    events: ->
        return false if @model
        'change [type="checkbox"]': 'updateBulkSelection'


    attachElContent: (html) ->
        @el.innerHTML = html
        return @


    attachBuffer: (compositeView, buffer) ->
        @toggleEmpty()
        if @hasContacts
            @el.querySelector('ul').appendChild buffer
        else
            @el.innerHTML = '' unless @model
            @el.appendChild buffer


    buildChildView: (child) ->
        if child instanceof ContactViewModel
            ChildView = require 'views/contacts/row'
        else
            ChildView = @constructor

        new ChildView model: child


    showCollection: ->
        @$el.removeClass 'empty'

        @_filteredSortedModels().map (model, index) =>
            view  = @buildChildView model

            @_updateIndices view, true, index
            @children.add view
            @renderChildView view, index
            view._parent = @


    _createBuffer: ->
        elBuffer = document.createDocumentFragment()
        @_bufferedChildren.map (buffer) ->
            elBuffer.appendChild buffer.el
        return elBuffer


    filter: (model, index, collection) ->
        return true unless model instanceof ContactViewModel

        app = require 'application'

        if @tag and @tag not in model.get('tags')
            return false

        if app.model.get 'scored'
            model.model.cid in Object.keys @collection.filtered
        else
            char    = @model.get 'name'
            idx     = if app.model.get('sort') is 'fn' then 0 else 1
            initial = model.get('initials')[idx]

            if char is '#' then (initial is null)
            else char is initial.toLowerCase()


    initialize: ->
        app = require 'application'

        if @model?._attachedCollection
            @collection = @model._attachedCollection

        else unless @model or app.model.get 'scored'
            collection = @collection
            groups = [].map.call 'abcdefghijklmnopqrstuvwxyz#', (char) ->
                group = new Backbone.Model name: char
                group._attachedCollection = collection
                return group
            @collection = new Backbone.Collection groups

        return unless @collection

        pattern = require('config').search.pattern 'tag'
        @tag = app.model.get('filter')?.match(pattern)?[1]

        @hasContacts = @collection.model is ContactViewModel

        if @hasContacts
            @listenTo @,
                'render': -> setTimeout => @children.call 'lazyLoadAvatar'

            @listenTo @collection,
                'update': @toggleEmpty

        @listenTo app.vent,
            'filter:tag': (value) ->
                @tag = value
                @render() if @hasContacts
                @triggerMethod 'filter'
            'filter:text': (value) ->
                @render() if app.model.get 'scored'
                @triggerMethod 'filter'


    toggleEmpty: ->
        @$el.toggleClass 'empty', not @children.length


    updateBulkSelection: (event) ->
        selected = event.currentTarget.checked
        id       = event.currentTarget.value
        method   = if selected then 'contacts:select' else 'contacts:unselect'

        @triggerMethod method, id
