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
            @listenTo @model, 'all', (args...) -> @trigger.apply @, args


        sync: ->


        reset: ->
            @unset attr for attr, value of @model?.attributes when @has attr
            @unset attr for attr, value of @attributes when value is ''
            @trigger 'reset'


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


        destroy: (options) ->
            destroy = =>
                @stopListening()
                @trigger 'destroy', @, @collection, options
            @model.destroy _.extend {}, options,
                wait:    true
                success: destroy


        _buildMappedAttributes: ->
            props = _.reduce @map, (memo, attrs, prop) =>
                method = "getMapped#{prop[0].toUpperCase()}#{prop[1..]}"
                return unless _.isFunction @[method]

                callback = (options) =>
                    opts = _.defaults {}, options,
                        immediate: true
                        reset:     true

                    args  = attrs.split(' ').map (attr) => @model.get attr
                    value = @[method].apply @, args

                    @set prop, value, reset: opts.reset if opts.immediate

                    return value

                @listenTo @, 'reset', callback
                _.each attrs.split(' '), (attr) =>
                    @listenTo @model, "change:#{attr}", callback

                memo[prop] = callback immediate: false
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

            unless options.reset
                for attr, value of attrs
                    if value and
                    typeof value is 'object' and
                    typeof @attributes[attr] is 'object'
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
