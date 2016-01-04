module.exports = class AvatarView extends Mn.ItemView

    template: require 'views/templates/contacts/components/avatar'

    behaviors:
        PickAvatar: {}


    ui: ->
        if @options.model.get 'edit' then avatar: '.avatar'


    modelEvents:
        'change:n':      'updateInitials'
        'change:avatar': 'render'


    getInitialsColor: ->
        ColorHash.getColor @model.get('n'), 'cozy'


    serializeData: ->
        _.extend {}, super, bg: @getInitialsColor()


    updateInitials: (model, value) ->
        el = @el.querySelector '.initials'

        if el
            el.innerHTML = @model.get 'initials'
            el.style['background-color'] = @getInitialsColor()
