module.exports = class ContactViewModel extends Backbone.ViewModel

    map:
        avatar:        'getPictureSrc'
        initials:      'getInitials'
        formattedName: 'getFormattedName'


    getPictureSrc: ->
        if @model.get('_attachments')?.picture
            "/contacts/#{@model.get '_id'}/picture.png"
        else
            null


    getInitials: ->
        [fn, gn, ...] = @model.get('n').split ';'
        "#{gn[0]}#{fn[0]}".toUpperCase()


    getFormattedName: ->
        [fn, gn, ...] = @model.get('n').split ';'
        "#{gn} <b>#{fn}</b>"
