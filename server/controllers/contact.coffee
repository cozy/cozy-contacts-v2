path    = require 'path'
multiparty = require 'multiparty'
async = require 'async'
Contact = require '../models/contact'
helpers = require '../helpers/helpers'
americano = require 'cozydb'


baseController = new americano.SimpleController
    model: Contact
    reqParamID: 'contactid'
    reqProp: 'contact'

module.exports =
    fetch: baseController.fetch
    list: baseController.listAll
    read: baseController.send
    delete: baseController.destroy
    picture: baseController.sendAttachment
        filename: 'picture'
        default: path.resolve __dirname, '../assets/defaultpicture.png'


    create: (req, res) ->

        # support both JSON and multipart for upload
        model = if req.body.contact then JSON.parse req.body.contact
        else req.body

        isImport = model.import
        delete model.import
        toCreate = new Contact model

        create = ->
            toCreate.rev = Date.now().toISOString()
            Contact.create toCreate, (err, contact) ->
                if err
                    next err
                else
                    res.send contact, 201

        if isImport
            # If creation is related to an import, it checks first if the
            # contact doesn't exist already by comparing the names
            # or emails if name is not specified.
            name = ''
            if toCreate.fn? and toCreate.fn.length > 0
                name = toCreate.fn
            else if toCreate.n and toCreate.n.length > 0
                name = toCreate.n.split(';').join(' ').trim()
            else
                for dp in toCreate.datapoints
                    if dp.name is 'email'
                        name = dp.value

            Contact.request 'byName', key: name, (err, contacts) ->
                if contacts.length is 0
                    create()
                else
                    res.send contacts[0], 201
        else
            create()


    update: (req, res) ->
        model = if req.body.contact then JSON.parse req.body.contact
        else req.body

        req.contact.updateAttributes model, (err) ->
            if err
                return res.error 500, "Update failed.", err
            else
                res.send req.contact, 201

    # Extract and save picture in a temporary folder, then save it to data
    # system and delete it from disk.
    updatePicture: (req, res, next) ->
        form = new multiparty.Form()

        res.on 'close', -> req.abort()

        form.parse req, (err, fields, files) ->
            if err
                next err
            else if files? and files.picture? and files.picture.length > 0
                file = files.picture[0]

                req.contact.savePicture file.path, (err) ->
                    if err
                        next err
                    else
                        res.send req.contact, 201
            else
                next new Error 'Can\'t change picture, no file is attached.'

    # Export contacts to a vcard file.
    vCard: (req, res, next) ->
        Contact.request 'all', (err, contacts) ->
            async.mapSeries contacts, (contact, done) ->
                contact.toVCF done
            , (err, outputs) ->
                return next err if err?

                vCardOutput = outputs.join ''
                date = helpers.makeDateStamp()
                res.attachment "#{date}-cozy-contacts.vcf"
                res.set 'Content-Type', 'text/x-vcard'
                res.send vCardOutput

    # Export a single contact to a VCard file.
    vCardContact: (req, res, next) ->
        req.contact.toVCF (err, vCardOutput) ->
            return next err if err?

            date = helpers.makeDateStamp()
            res.attachment "#{date}-#{req.params.fn.replace(/ /g, '-')}.vcf"
            res.set 'Content-Type', 'text/x-vcard'
            res.send vCardOutput
