MergeView = require 'views/contacts/merge'
MergeModel = require 'views/models/merge'
request = require 'lib/request'

app = undefined

module.exports = class AppViewModel extends Backbone.ViewModel

    defaults:
        dialog: false
        filter: undefined
        scored: false
        errors: undefined


    viewEvents:
        'settings:sort':   'updateSortSetting'
        'settings:upload': 'onUploadFile'
        'select:all':      'selectAll'
        'select:none':     'unselectAll'
        'bulk:delete':     'bulkDelete'
        'bulk:export':     -> @bulkExport()
        'bulk:merge':      'bulkMerge'
        'bulk:tag':        'bulkTag'
        'contacts:export': -> @bulkExport true


    initialize: ->
        app = require 'application'

        @set 'selected', []
        @listenTo @, 'change:filter', (nil, value) ->
            @unselectAll()
            @set 'scored', require('config').search.pattern('text').test value


    select: (id) ->
        select = _.clone @get 'selected'
        @trigger 'select:start' if _.isEmpty select

        select.push id
        @set {selected: select}, {silent: true}
        @trigger 'change:selected', @, select


    unselect: (id) ->
        select = _.clone @get('selected')
        select = _.without select, id
        @set selected: select

        @trigger 'select:end' if _.isEmpty select


    selectAll: ->
        @trigger 'select:start' if _.isEmpty @get 'selected'

        select = app.filtered.get(tagged: true).map (contact) -> contact.id
        @set selected: select


    unselectAll: ->
        @set selected: []
        @trigger 'select:end'


    # Delete currently selected conctacts.
    # It fires a bulk:delete:done event when everything is done. That way
    # other components can be informed.
    bulkDelete: ->
        selected = @attributes.selected
        app.contacts.contactListener.disable()
        request.post 'contacts/bulk-delete', selected, (err, res) =>

            if err
                console.log err
                alert t 'contacts delete bulk error'

            else
                app.contacts.remove selected, sort: false
                @set selected: []
                setTimeout app.contacts.contactListener.enable, 1500
                @trigger 'bulk:delete:done'


    # TODO: probably need to be revamped when doing it for the whole merge
    # feature
    bulkMerge: ->
        candidates = app.contacts.filter (contact) =>
            contact.id in @attributes.selected

        toMerge = new MergeModel { candidates }
        mergeOptions = toMerge.buildMergeOptions()

        toMerge.on 'contacts:merge', (evt, state) =>
            @unselectAll()
            if state isnt 'abort'
                @select toMerge.get('result').id

        if Object.keys(mergeOptions).length is 0
            toMerge.merge()
        else
            app.layout.showChildView 'alerts', new MergeView model: toMerge


    bulkTag: (tagName, state) ->
        @get('selected').forEach (id) ->
            contact = app.contacts.get id
            tags    = _.clone contact.get 'tags'

            if state
                tags.push tagName
            else
                _.pull tags, tagName

            contact.save tags: tags


    bulkExport: (all) ->
        selected = @attributes.selected
        len      = if all then app.contacts.size() else selected.length
        toExport = []

        save = _.after len, ->
            date = moment().format('YYYYMMDD')
            blob = new Blob toExport, type: "text/plain;charset=utf-8"
            saveAs blob, "#{date}_cozy_contacts_#{toExport.length}.vcf"

        app.contacts.chain()
            .filter (contact) ->
                all or (contact.id in selected)
            .invoke 'toVCF', (card) ->
                toExport.push card
                save()
            .value()


    updateSortSetting: (value) ->
        @model.save 'sort', value


    onUploadFile: (file) ->
        if /.+\.(vcf|vcard)$/i.test file.name
            @trigger 'before:import'
            reader = new FileReader()
            reader.readAsText file
            reader.onloadend = =>
                res = reader.result
                isVCF = /^BEGIN:VCARD/
                if isVCF.test res
                    app.contacts.importFromVCF res
                else
                    @set 'errors', upload: 'error upload wrong filetype'
        else
            @set 'errors', upload: 'error upload wrong filetype'
