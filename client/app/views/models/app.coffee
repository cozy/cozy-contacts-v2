module.exports = class AppViewModel extends Backbone.ViewModel

    defaults: ->
        selected: []
        dialog:   false
        filter:   null


    viewEvents:
        'settings:sort': 'updateSortSetting'


    updateSortSetting: (value) ->
        @model.save 'sort', value
