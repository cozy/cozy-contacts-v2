module.exports = class Navigator extends Mn.Behavior

    events:
        'click @ui.navigate': 'navigate'


    navigate: (event) ->
        event.preventDefault()
        el = event.currentTarget
        dest = el.dataset.next or el.getAttribute 'href'
        require('application').router.navigate dest, trigger: true
