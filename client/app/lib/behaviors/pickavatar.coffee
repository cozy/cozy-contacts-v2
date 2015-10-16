module.exports = class PickAvatar extends Mn.Behavior

    events: ->
        'click @ui.avatar': 'choosePhoto'


    choosePhoto: =>
        app  = require 'application'
        intent =
            type  : 'pickObject'
            params:
                objectType : 'singlePhoto'
                isCropped  : true
                proportion : 1
                maxWidth   : 10
                minWidth   : 10
        timeout = 10800000 # 3 hours

        app.intentManager
        .send 'nameSpace', intent, timeout
        .then @choosePhoto_answer, (error) ->
            console.error 'contact : response in error : ', error


    choosePhoto_answer : (message) =>
        answer = message.data
        if answer.newPhotoChosen
            @view.model?.set 'avatar', answer.dataUrl
