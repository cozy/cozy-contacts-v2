{settings} = require 'config'

t = require 'lib/i18n'


module.exports = class SettingsView extends Mn.ItemView

    template: require 'views/templates/settings'

    tagName: 'section'

    className: 'settings'

    attributes:
        role: 'dialog'


    behaviors:
        Dialog: {}

    ui:
        sort:     '[name="sort"]'
        import:   'button.import'
        upload:   '[type="file"]'
        export:   '[formaction="contacts/export"]'
        feedback: '.feedback'


    triggers:
        'click @ui.export': 'contacts:export'

    events:
        'change @ui.sort':   'updateSort'
        'click @ui.import':  'triggerUploader'
        'change @ui.upload': 'onUploadFile'

    modelEvents:
        'change:errors': 'render'
        'before:import': 'onBeforeImport'


    initialize: ->
        Mn.bindEntityEvents @model, @, @model.viewEvents
        @listenTo require('application').contacts,
            'before:import:progress': @onBeforeImportProgress
            'import:progress':        @onProgressImport
            'import':                 @onProgressEnd


    serializeData: ->
        _.extend {}, super, settings, locale: require('imports').locale


    updateSort: (event) ->
        event.preventDefault()
        event.stopPropagation()
        @triggerMethod 'settings:sort', event.currentTarget.value


    triggerUploader: (event) ->
        event.preventDefault()
        event.stopPropagation()
        @ui.upload.trigger 'click'


    onUploadFile: (event) ->
        event.preventDefault()
        event.stopPropagation()
        @triggerMethod 'settings:upload', event.currentTarget.files[0]


    onBeforeImport: ->
        @ui.import.prop 'disabled', true
        @ui.feedback.empty()


    onBeforeImportProgress: (total) ->
        @ui.progress = $ '<progress/>', max: total, value: 0
        @ui.counter = $ '<span/>', text: 0
        status = $('<div/>', text: "/#{total}").prepend @ui.counter

        @ui.progress.appendTo @ui.feedback
        status.appendTo @ui.feedback


    onProgressImport: (state) ->
        @ui.progress.val state
        @ui.counter.text state


    onProgressEnd: (total) ->
        @ui.feedback
            .empty()
            .text t 'settings in-out import result', smart_count: total
        @ui.import.prop 'disabled', false
