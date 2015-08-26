do (factory = (root, Backbone) ->
    Backbone.ViewModel = class ViewModel extends Backbone.Model

        sync: ->


        constructor: (attributes, options) ->
            @model               = options?.model or null
            @compositeCollection = options?.compositeCollection or null
            @_attachEvents()

            super

            @updateMap()


        _attachEvents: ->
            @model?.on 'all', =>
                args = Array.prototype.slice.call arguments
                @trigger.apply @, args
            @model?.on 'change', @updateMap


        _getMappedValues: ->
            map = _.result @, 'map'
            return null unless _.isObject map

            attrs = {}
            for attr, action of map
                do (attr, action) =>
                    value = if _.isString action
                        if @[action]
                            _.result @, action
                        else if @model.has action
                            @model.get action
                    else if _.isFunction action
                        action.call @

                    attrs[attr] = value

            return attrs


        updateMap: ->
            attributes = @_getMappedValues()
            @set attributes if attributes


        toJSON: ->
            if @model
                _.extend @model.toJSON(), _.clone @attributes
            else
                _.clone @attributes


        get: (attr) ->
            if @attributes[attr]?
                @attributes[attr]
            else
                @model.get attr

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
