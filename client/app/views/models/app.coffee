MergeView = require 'views/contacts/merge'
MergeModel = require 'views/models/merge'

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
        'contacts:export': -> @bulkExport true


    initialize: ->
        app = require 'application'

        @set 'selected', []
        @listenTo @, 'change:filter', (nil, value) ->
            @unselectAll()
            @set 'scored', require('config').search.pattern('text').test value


    select: (id) ->
        select = @attributes.selected.slice(0)
        select.push id
        @set selected: select


    unselect: (id) ->
        select = _.without @attributes.selected, id
        @set selected: select


    selectAll: ->
        select = app.filtered.get(tagged: true).map (contact) -> contact.id
        @set selected: select


    unselectAll: ->
        @set selected: []


    bulkDelete: ->
        selected = @attributes.selected

        success = (model) => @unselect model.id

        app.contacts.chain()
            .filter (contact) ->
                contact.id in selected
            .invoke 'destroy', {wait:true, success: success}
            .value()


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
