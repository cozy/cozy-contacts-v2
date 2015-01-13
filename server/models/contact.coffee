americano = require 'americano-cozy'
ContactLog = require './contact_log'
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

        @n = @getParsedN()

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
    [familly, given, middle, prefix, suffix] = @n.split ';'
    # order parts of name.
    parts = [prefix, given, middle, familly, suffix]
    # remove empty parts
    parts = parts.filter (part) -> part? and part isnt ''

    return parts.join ' '

# Parse n field (splitted) from fn (display).
Contact::getParsedN = ->
    return ";#{@fn};;;"

Contact::toVCF = (callback) ->

    model = @toJSON()

    getVCardOutput = (picture = null) =>
        out = "BEGIN:VCARD\n"
        out += "VERSION:3.0\n"
        out += "NOTE:#{model.note}\n" if model.note

        if model.n
            out += "N:#{model.n}\n"
            out += "FN:#{@getComputedFN()}\n"
        else if model.fn
            out += "N:#{@getParsedN()}\n"
            out += "FN:#{model.fn}\n"
        else
            out += "N:;;;;\n"
            out += "FN:\n"

        for i, dp of model.datapoints

            value = dp.value

            key = dp.name.toUpperCase()
            switch key

                when 'ABOUT'
                    if dp.type is 'org' or dp.type is 'title'
                        out += "#{dp.type.toUpperCase()}:#{value}\n"
                    else
                        out += "X-#{dp.type.toUpperCase()}:#{value}\n"

                when 'OTHER'
                    out += "X-#{dp.type.toUpperCase()}:#{value}\n"

                when 'ADR'
                    # since a proper address management would be very
                    # complicated we trick it a bit so it matched the standard
                    value = value.replace /(\r\n|\n\r|\r|\n)/g, ";"
                    content = "TYPE=home,postal:;;#{value};;;;"
                    out += "ADR;#{content}\n"
                else
                    if dp.type?
                        type = ";TYPE=#{dp.type.toUpperCase()}"
                    else
                        type = ""
                    out += "#{key}#{type}:#{value}\n"

        if picture?
            # vCard 3.0 specifies that lines must be folded at 75 characters
            # with "\n " as a delimiter
            folded = picture.match(/.{1,75}/g).join '\n '
            out += "PHOTO;ENCODING=B;TYPE=JPEG;VALUE=BINARY:\n #{folded}\n"


        return out += "END:VCARD\n"

    if model._attachments?.picture?
        buffers = []
        stream = @getFile 'picture', ->
        stream.on 'data', buffers.push.bind(buffers)
        stream.on 'end', ->
            picture = Buffer.concat(buffers).toString 'base64'
            callback null, getVCardOutput picture
    else
        callback null, getVCardOutput()
