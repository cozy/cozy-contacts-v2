americano = require 'americano-cozy'
ContactLog = require './contact_log'
VCardParser = require 'cozy-vcard'
fs = require 'fs'
log = require('printit')
    prefix: 'Contact Model'

module.exports = Contact = americano.getModel 'Contact',
    id            : String
    fn            : String # vCard FullName = display name
    # (Prefix Given Middle Familly Suffix), or something else.
    n             : String # vCard Name = splitted
    # (Familly;Given;Middle;Prefix;Suffix)
    datapoints    : (x) -> x
    note          : String
    tags          : (x) -> x # DAMN IT JUGGLING
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

# TODO: move the logic somewhere in cozy-vcard.
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
