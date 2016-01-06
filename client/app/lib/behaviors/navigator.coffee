module.exports = class Navigator extends Mn.Behavior

    behaviors:
        Confirm: {}


    events:
        'click @ui.navigate': 'navigate'


    navigate: (event) ->
        event.preventDefault()

        callback = ->
            el = event.currentTarget
            dest = el.dataset.next or el.getAttribute 'href'
            require('application').router.navigate dest, trigger: true

        if event.currentTarget.dataset.confirm
            Mn.bindEntityEvents @, @view,
                'confirm:true':  callback
                'confirm:close': -> Mn.unbindEntityEvents @, @view
        else
            callback()

