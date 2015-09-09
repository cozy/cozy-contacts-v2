module.exports = class DrawerViewModel extends Backbone.ViewModel

    map:
        mode: 'selected'


    getMappedMode: (selected) ->
        if selected.length then 'select' else 'display'
