cozydb = require 'cozydb'
async = require 'async'
ContactLog = require './contact_log'
VCardParser = require 'cozy-vcard'
fs = require 'fs'
log = require('printit')
    prefix: 'Contact Model'


# Datapoints is an array of { name, type, value ...} objects,
# values are typically String. Particular case, adr :
# name: 'adr',
# type: 'home',
# value: ['','', '12, rue Basse', 'Paris','','75011', 'France']
class DataPoint extends cozydb.Model
    @schema:
        name: String
        value: String
        type: cozydb.NoSchema

module.exports = Contact = cozydb.getModel 'Contact',
    id            : String
    # vCard FullName = display name
    # (Prefix Given Middle Familly Suffix), or something else.
    fn            : String
    # vCard Name = splitted
    # (Familly;Given;Middle;Prefix;Suffix)
    n             : String
    datapoints    : [DataPoint]
    note          : String
    tags          : [String]
    _attachments  : Object

Contact.afterInitialize = ->
    # Cleanup the model,
    # Defensive against data from DataSystem

    # n and fn MUST be valid.
    if not @n? or @n is ''
        if not @fn?
            @fn = ''

        @n = @getComputedN()

    else if not @fn? or @fn is ''
        @fn = @getComputedFN()

    return @

Contact::remoteKeys = ->
    model = @toJSON()
    out = [@id]
    for dp in model.datapoints
        if dp.name is 'tel'
            out.push ContactLog.normalizeNumber dp.value
        else if dp.name is 'email'
            out.push dp.value?.toLowerCase()
    return out

# Save given file as contact picture then delete given file from disk.
Contact::savePicture = (path, callback) ->
    data = name: 'picture'
    log.debug path
    @attachFile path, data, (err) ->
        if err
            callback err
        else
            fs.unlink path, (err) ->
                log.error "failed to purge #{file.path}" if err
                callback()

Contact::getComputedFN = ->
    return VCardParser.nToFN @n.split ';'

# Parse n field (splitted) from fn (display).
Contact::getComputedN = ->
    return VCardParser.fnToN @fn
            .join ';'

Contact::toVCF = (callback) ->
    if @_attachments?.picture?
        # we get a stream that we need to convert into a buffer
        # so we can output a base64 version of the picture
        stream = @getFile 'picture', ->
        buffers = []
        stream.on 'data', buffers.push.bind(buffers)
        stream.on 'end', =>
            picture = Buffer.concat(buffers).toString 'base64'
            callback null, VCardParser.toVCF(@, picture)
    else
        callback null, VCardParser.toVCF(@)


# Migration 2015-01 : datapoints.where 'name' is 'adr':
# Simple string is replaced by an String[7] .
Contact::migrateAdr = (callback) ->
    hasMigrate = false
    @?.datapoints?.forEach (dp) ->
        if dp.name is 'adr'
            if typeof dp.value is 'string' or dp.value instanceof String
                dp.value = VCardParser.adrStringToArray dp.value
                hasMigrate = true

    if hasMigrate
        @updateAttributes {}, callback
    else
        callback()


Contact.migrateAll = (callback) ->
    Contact.all {}, (err, contacts) ->
        if err?
            console.log err
            callback()
        else
            async.eachLimit contacts, 10, (contact, done) ->
                contact.migrateAdr done
            , callback
