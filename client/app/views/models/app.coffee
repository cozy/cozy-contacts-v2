module.exports = class AppViewModel extends Backbone.ViewModel

    defaults: ->
        selected: []
        dialog:   false
        filter:   null
        errors:    null


    viewEvents:
        'settings:sort':   'updateSortSetting'
        'settings:upload': 'onUploadFile'


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
