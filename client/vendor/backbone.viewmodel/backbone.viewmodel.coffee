do (factory = (root, Backbone) ->
    Backbone.ViewModel = class ViewModel extends Backbone.Model
        sync: ->
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
