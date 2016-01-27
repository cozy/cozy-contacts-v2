path       = require 'path'
multiparty = require 'multiparty'
async      = require 'async'
americano  = require 'cozydb'
log        = require('printit')
    prefix: 'Contact controller'

Contact    = require '../models/contact'
helpers    = require '../helpers/helpers'

baseController = new americano.SimpleController
    model      : Contact
    reqParamID : 'contactid'
    reqProp    : 'contact'


module.exports =
    fetch: baseController.fetch
    list: baseController.listAll
    read: baseController.send
    delete: baseController.destroy
    picture: baseController.sendAttachment
        filename: 'picture'
        default: path.resolve __dirname, '../assets/defaultpicture.png'


    create: (req, res, next) ->

        # support both JSON and multipart for upload
        model = if req.body.contact then JSON.parse req.body.contact
        else req.body

        isImport = model.import
        delete model.import
        toCreate = new Contact model

        create = ->
            toCreate.revision = new Date().toISOString()
            Contact.create toCreate, (err, contact) ->
                if err
                    next err
                else
                    res.status(201).send contact

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
                    res.status(201).send contacts[0]
        else
            create()


    update: (req, res) ->
        model = if req.body.contact then JSON.parse req.body.contact
        else req.body

        req.contact.updateAttributes model, (err) ->
            if err
                return res.error 500, "Update failed.", err
            else
                res.status(201).send req.contact


    # Extract and save picture in a temporary folder, then save it to data
    # system and delete it from disk.
    updatePicture: (req, res, next) ->
        form = new multiparty.Form()

        form.parse req, (err, fields, files) ->
            if err
                next err
            else if files? and files.picture? and files.picture.length > 0
                file = files.picture[0]

                req.contact.savePicture file.path, (err) ->
                    if err
                        next err
                    else
                        res.status(201).send req.contact
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
            txt = req.params.fn.replace(new RegExp(' ','g'), '-')
            res.attachment "#{date}-#{txt}.vcf"
            res.set 'Content-Type', 'text/x-vcard'
            res.send vCardOutput


    # Delete a bunch of contacts. It expects to have an array of contact ids
    # as request body.
    # This function is here to avoid many requests while deleting several
    # contacts.
    bulkDelete: (req, res, next) ->
        ids = req.body
        log.info "Starting bulk delete of #{ids.length} contacts"
        log.debug ids
        Contact.requestDestroy 'all', keys: ids, (err) ->
            return next err if err
            res.status(200).send success: 'Deletion succeeded'
            log.info "Deletion of #{ids.length} contacts done."

