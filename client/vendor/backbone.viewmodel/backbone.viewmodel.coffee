do (factory = (root, Backbone) ->
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


    Backbone.ViewModel = class ViewModel extends Backbone.Model

        constructor: (attributes, options) ->
            @model               = options?.model or null
            @compositeCollection = options?.compositeCollection or null
            mappedAttrs          = @_buildMappedAttributes()
            super _.extend({}, attributes, mappedAttrs), options


        sync: ->


        save: (key, val, options) ->
            if !key? or typeof key is 'object'
                attrs   = key
                options = val
            else
                (attrs = {})[key] = val

            @set attrs if attrs

            diff = _.reduce @attributes, (memo, value, key) =>
                method = "saveMapped#{key[0].toUpperCase()}#{key[1..]}"
                if @map[key]? and _.isFunction @[method]
                    _.extend memo, @[method]()

                else if not @defaults[key]? and not @map[key]?
                    memo[key] = value

                return memo
            , {}
            @model.save diff, options


        _buildMappedAttributes: ->
            props = _.reduce @map, (memo, attrs, prop) =>
                method = "getMapped#{prop[0].toUpperCase()}#{prop[1..]}"
                return unless _.isFunction @[method]

                callback = =>
                    args = attrs.split(' ').map (attr) => @model.get attr
                    @[method].apply @, args

                events = attrs.split(' ').reduce( (memo, attr) ->
                    memo += "change:#{attr} "
                , '').trim()
                @model.on events, => @set prop, callback()

                memo[prop] = callback()
                return memo
            , {}


        toJSON: ->
            if @model
                _.extend @model.toJSON(), _.clone @attributes
            else
                _.clone @attributes


        get: (attr) ->
            if @attributes[attr]? then @attributes[attr] else @model.get attr


        set: (key, val, options) ->
            return @ unless key?

            if typeof key is 'object'
                attrs   = key
                options = val
            else
                (attrs = {})[key] = val

            options ||= {}

            for attr, value of attrs
                if typeof value is 'object' and
                typeof @attributes[attr] is 'object'
                    attrs[attr] = _.extend {}, @attributes[attr], value

            super(attrs, options)


        attachViewEvents: (view) ->
            events = _.result @, 'viewEvents'
            return unless events

            _.each events, (actions, event) =>
                if _.isFunction actions
                    @listenTo view, event, actions
                else
                    actionNames = actions.split /\s+/
                    _.each actionNames, (actionName) =>
                        return unless @[actionName]
                        @listenTo view, event, @[actionName]


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
