###
ViewModel (Backbone.ViewModel)
------------------------------

ViewModel is a smart ViewModel pattern implementation for Backbone.

Backbone.ViewModel may be freely distributed under the AGPL v3 licence.
For documentation and examples, see:
https://github.com/m4dz/backbone.viewmodel/#readme

###


do (factory = (root, Backbone) ->
    # Object.__proto__.setValueOf
    # ---------------------------
    #
    # Add a smart way to define any object property using a JSON like path
    # notation. Particularly useful when dealing with named forms inputs.
    #
    # ```
    # (var attrs = {}).setValueOf('phone.0.label', 'foobar');
    # // output:
    # // attrs = {
    # //   'phone': [{
    # //     'label': 'foobar'
    # //   }]
    # // }
    # ```
    #
    Object.defineProperty Object.prototype, 'setValueOf',
        __proto__: null,
        value : (path, value) ->
            path.split('.').reduce (obj, key, index, arr) ->
                val = if index is arr.length - 1 then value
                else if obj[key]? then obj[key]
                else if +key is 'number' then []
                else {}
                obj[key] = val
            , @


    # ViewModel
    # ---------
    #
    # The heart of the beast.
    #
    Backbone.ViewModel = class ViewModel extends Backbone.Model

        # ViewModel can has `model` passed at construct to refers to an
        # underlying data model set.
        #
        # Extend the givem attributes (like ay Backbone.Model) with the mapped
        # attributes onto the underlying model.
        #
        # Proxying any underlying model events to keep the events cascade safe.
        constructor: (attributes, options) ->
            @model               = options?.model or null
            mappedAttrs          = @_buildMappedAttributes()
            super _.extend({}, attributes, mappedAttrs), options

            @listenTo @model, 'all', (args...) -> @trigger.apply @, args
            @proxyMethods()
            @bindEntityEvents()


        # Proxy a a simpler way to declare which model methods should be
        # proxified through the ViewModel instance. Just add a `proxy` class
        # property as an array (or a function tht returns an array) containing
        # names of the methods to proxify.
        proxyMethods: ->
            return unless @model
            proxy = _.result @, 'proxy', {}
            @[method] = @model[method].bind @model for method in proxy


        # Simple and convenient wrapper inspired by Marionette to bind `events`
        # property to the ViewModel itself, making the ViewModel listening to
        # its events and react to them.
        bindEntityEvents: ->
            events = _.result @, 'events', {}
            for event, methods of events
                if _.isFunction methods
                    @listenTo @, event, methods
                else
                    methodNames = methods.split /\s+/
                    for method in methodNames
                        @listenTo @, event, @[method] if @[method]


        # Disable syncing.
        # Feel free to overrides this one in your ViewModels objects to
        # implement view states persistence if needed.
        sync: ->


        # Reset the current state-machine properties by resyncing the underlying
        # model on it, and removing empty state properties.
        reset: ->
            defaults = _.result @, 'defaults', {}
            map      = _.result @, 'map', {}

            ownAttrs = _.union _.keys(defaults), _.keys(map)
            @unset attr for attr of @attributes when attr not in ownAttrs
            @trigger 'reset'


        # Save wrapper will set new attributes to the model if given, then
        # compute a diff between itself and the underlying model by calling
        # all `saveMapped*` methods.
        #
        # Performs a save on the underlying model and dispatch two events:
        # - `before:save` that is triggered when diff is complete and ready to
        # be applied onto the model
        # - `save` that is triggered when server sync ends
        save: (key, val, options) ->
            if !key? or typeof key is 'object'
                attrs   = key
                options = val
            else
                (attrs = {})[key] = val

            options ||= {}

            @set attrs if attrs

            diff = _.reduce @attributes, (memo, value, key) =>
                method = "saveMapped#{key[0].toUpperCase()}#{key[1..]}"
                if @map[key]? and _.isFunction @[method]
                    _.extend memo, @[method]()

                else if not @defaults[key]? and not @map[key]?
                    memo[key] = value

                return memo
            , {}

            options.wait = true
            options.success = => @trigger 'save'

            @trigger 'before:save'
            @model.save diff, options


        # Destroy first destroy the underlying model, then destroy the viewModel
        # itself when server confirms the model deletion.
        #
        # Stop evemts listening and trigger a destroy event on itself for its
        # related collection.
        destroy: (options) ->
            destroy = =>
                @stopListening()
                @trigger 'destroy', @, @collection, options
            @model.destroy _.extend {}, options,
                wait:    true
                success: destroy


        # BuildMappedAttributes
        # ---------------------
        #
        # Mapped attributes are state-machine properties that depends on
        # underlying model data. They're sometimes called _decorators_.
        #
        # When declaring a new mapped property, you must defines on which
        # model properties it is based, on give a method to decorate those
        # properties.
        #
        # Return a hash of properties name/value, ready to be set on
        # ViewModel itself.
        #
        # For each mapped attribute, attach the compute callback to the model
        # properties `change:property` event to ensure mapped values are
        # automatically updated when the properties it depends on updates.
        _buildMappedAttributes: ->
            return {} unless @map

            Object.keys(@map).reduce (memo, prop) =>
                method = "getMapped#{prop[0].toUpperCase()}#{prop[1..]}"
                return memo unless _.isFunction @[method]

                attrs = @map[prop].split ' '

                callback = (options) =>
                    opts  = _.defaults {}, options,
                        immediate: true
                        reset:     true
                    args  = attrs.map (attr) => @model.get attr
                    value = @[method].apply @, args

                    @set prop, value, reset: opts.reset if opts.immediate
                    return value

                @listenTo @, 'reset', callback
                attrs.map (attr) =>
                    @listenTo @model, "change:#{attr}", callback

                memo[prop] = callback immediate: false
                return memo
            , {}


        # Extend the underlying model `toJSON` output with the state-machine
        # JSON-like representation.
        toJSON: ->
            if @model
                _.extend @model.toJSON(), _.clone @attributes
            else
                _.clone @attributes


        # Return a state-machine attribute if available or fallback to the
        # underlying model directly.
        get: (attr) ->
            if @attributes[attr]? then @attributes[attr] else @model?.get attr


        # When setting a property, extends the property itself with the given
        # value, so you can partially update an object value, until
        # `option.reset = true` is passed.
        #
        # ```
        # viewModel.get('name');
        # // output:
        # // {
        # //   'firstname': 'foo'
        # //   'lastname': 'bar'
        # // }
        #
        # viewModel.set('name', {lastname: 'qux'});
        # viewModel.get('name');
        # // output:
        # // {
        # //   'firstname': 'foo'
        # //   'lastname': 'qux'
        # // }
        # ```
        #
        # viewModel.set('name', {lastname: 'BAR'}, {reset: true});
        # viewModel.get('name');
        # // output:
        # // {
        # //   'lastname': 'BAR'
        # // }
        # ```
        set: (key, val, options) ->
            return @ unless key?

            if typeof key is 'object'
                attrs   = key
                options = val
            else
                (attrs = {})[key] = val

            options ||= {}

            unless options.reset
                for attr, value of attrs
                    toExt = value and _.isObject(value) and not _.isArray(value)
                    if  toExt and _.isObject(@attributes[attr])
                        attrs[attr] = _.extend {}, @attributes[attr], value

            super(attrs, options)


) ->
    root = (typeof self is 'object' and self.self is self and self) or
           (typeof global is 'object' and global.global is global and global)

    if typeof define is 'function' and define.amd
        define ['backbone'], (Backbone) -> factory root, Backbone
    else if typeof exports isnt 'undefined'
        Backbone = require 'backbone'
        module.exports = factory root, Backbone
    else
        factory root, root.Backbone
