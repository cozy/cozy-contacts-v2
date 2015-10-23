module.exports = class AppViewModel extends Backbone.ViewModel

    defaults:
        dialog: false
        filter: null
        errors: null


    viewEvents:
        'settings:sort':   'updateSortSetting'
        'settings:upload': 'onUploadFile'
        'select:all':      'selectAll'
        'select:none':     'unselectAll'
        'bulk:delete':     'bulkDelete'


    initialize: ->
        @set 'selected', []


    select: (id) ->
        select = @attributes.selected.slice(0)
        select.push id
        @set selected: select


    unselect: (id) ->
        select = _.without @attributes.selected, id
        @set selected: select


    selectAll: ->
        app = require 'application'
        select = app.contacts.map (contact) -> contact.id
        @set selected: select


    unselectAll: ->
        @set selected: []


    bulkDelete: ->
        app = require 'application'

        _.each @attributes.selected, (id) =>
            _.defer => app.contacts.get(id).destroy
                wait: true
                success: => @unselect id


    updateSortSetting: (value) ->
        @model.save 'sort', value


    onUploadFile: (file) ->
        if /.+\.(vcf|vcard)$/i.test file.name
            @trigger 'before:import'
            reader = new FileReader()
            reader.readAsText file
            reader.onloadend = =>
                res = reader.result
                validVCF = ///
                    ^BEGIN:VCARD[\r\n]{1,2}
                    (?:.+[\r\n]{1,2})+
                    END:VCARD[\r\n]{0,2}$
                ///
                if validVCF.test res
                    app = require 'application'
                    app.contacts.importFromVCF res
                else
                    @set 'errors', upload: 'error upload wrong filetype'
        else
            @set 'errors', upload: 'error upload wrong filetype'
