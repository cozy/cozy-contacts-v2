module.exports = class DrawerViewModel extends Backbone.ViewModel

    map:
        mode: 'getDisplayMode'


    getDisplayMode: ->
        if @model.get('selected').length then 'select' else 'display'
