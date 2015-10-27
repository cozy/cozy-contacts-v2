module.exports = class AvatarView extends Mn.ItemView

    template: require 'views/templates/contacts/components/avatar'

    behaviors:
        PickAvatar: {}


    ui: ->
        if @options.model.get 'edit' then avatar: '.avatar'


    modelEvents:
        'change:initials': 'updateInitials'
        'change:avatar':   'render'


    getInitialsColor: ->
        ColorHash.getColor @model.get('n'), 'cozy'


    serializeData: ->
        _.extend {}, super, bg: @getInitialsColor()


    updateInitials: (model, value) ->
        @$('.initials')
            .text value
            .css 'background-color', @getInitialsColor()
