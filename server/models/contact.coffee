cozydb = require 'cozydb'
async = require 'async'
VCardParser = require 'cozy-vcard'
fs = require 'fs'
log = require('printit')
    prefix: 'Contact Model'


# Datapoints is an array of { name, type, value ...} objects,
# values are typically String. Name and mediatype are the only values that
# cannot be modified by the user.
#
# Particular case, adr :
# name: 'adr',
# type: 'home',
# value: ['','', '12, rue Basse', 'Paris','','75011', 'France']
#
# Mediatype was required in order to be able to share files between clouds: its
# role is to provide a hint on how to interprete the name that it is linked to.
# For instance if the name is 'url' and mediatype is 'cozy' then we can
# categorize the value as being the url address of a cozy cloud.
class DataPoint extends cozydb.Model
    @schema:
        name: String
        value: cozydb.NoSchema
        type: String
        mediatype: String

# A contact account in an external service (typically google contact).
# An account is uniquely identified by the couple of its type and name.
class Account extends cozydb.Model
    @schema:
        type: String
        name: String
        # Id of this contact in this service.
        id: String
        # Last update of this contact in this service.
        lastUpdate: String


module.exports = class Contact extends cozydb.CozyModel
    @docType: 'contact'
    @schema:
        # vCard FullName = display name
        # (Prefix Given Middle Familly Suffix), or something else.
        fn            : String
        # vCard Name = splitted
        # (Familly;Given;Middle;Prefix;Suffix)
        n             : String
        org           : String
        title         : String
        department    : String
        bday          : String
        nickname      : String
        url           : String
        revision      : Date
        datapoints    : [DataPoint]
        note          : String
        tags          : [String]
        _attachments  : Object
        accounts      : [Account]

    @cast: (attributes, target) ->
        target = super attributes, target
        # Cleanup the model,
        # Defensive against data from DataSystem

        # n and fn MUST be valid.
        if not target.n? or target.n is ''
            if not target.fn?
                target.fn = ''

            if target instanceof Contact
                target.n = target.getComputedN()
            else
                target.n = VCardParser.fnToN(target.fn).join ';'

        else if not target.fn? or target.fn is ''
            if target instanceof Contact
                target.fn = target.getComputedFN()
            else
                target.fn = VCardParser.nToFN target.n.split ';'

        return target

# Update revision each time a change occurs
Contact::updateAttributes = (changes, callback) ->
    changes.revision = new Date().toISOString()
    super


# Update revision each time a change occurs
Contact::save = (changes, callback) ->
    changes.revision = new Date().toISOString()
    super


# Save given file as contact picture then delete given file from disk.
Contact::savePicture = (path, callback) ->
    data = name: 'picture'
    log.debug path
    @attachFile path, data, (err) ->
        if err
            callback err
        else
            fs.unlink path, (err) ->
                log.error "failed to purge #{path}" if err
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
        laterStream = @getFile 'picture', ->
        laterStream.on 'ready', (stream) =>
            buffers = []
            stream.on 'data', buffers.push.bind(buffers)
            stream.on 'end', =>
                picture = Buffer.concat(buffers).toString 'base64'
                callback null, VCardParser.toVCF(@, picture)
    else
        callback null, VCardParser.toVCF(@)
