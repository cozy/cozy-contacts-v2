module.exports = class AvatarView extends Mn.ItemView

    template: require 'views/templates/contacts/components/avatar'


    modelEvents:
        'change:initials': 'updateInitials'


    updateInitials: (model, value) ->
        @$('.initials').text value
