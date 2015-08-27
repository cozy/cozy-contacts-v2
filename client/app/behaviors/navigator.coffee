module.exports = class Navigator extends Mn.Behavior

    events:
        'click @ui.navigate': 'navigate'


    navigate: (event) ->
        event.preventDefault()
        dest = event.currentTarget.getAttribute 'href'
        require('application').router.navigate dest, trigger: true
