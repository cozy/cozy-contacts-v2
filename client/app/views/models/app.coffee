module.exports = class AppViewModel extends Backbone.ViewModel

    defaults:
        # the app rendering context. Can be:
        # - `display`: render contacts' related direct actions
        # - `select`: render contacts' contextual actions
        mode: 'display'
