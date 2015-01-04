File = require '../models/file'
Photo = require '../models/photo'
async = require 'async'
fs = require 'fs'
im = require 'imagemagick'
onThumbCreation = require('../../init').onThumbCreation
# fileByPage = 7
fileByPage = 5 * 12

# Get given file, returns 404 if photo is not found.
module.exports.fetch = (req, res, next, id) ->
    id = id.substring 0, id.length - 4 if id.indexOf('.jpg') > 0
    File.find id, (err, file) =>
        return res.error 500, 'An error occured', err if err
        return res.error 404, 'File not found' if not file

        req.file = file
        next()

# Returns a list of n photo (from newest to oldest )
# skip : the number of the first photo of the view not to be returned
# limit : the max number of photo to return
module.exports.list = (req, res, next) ->
    if req.params.skip?
        skip = parseInt(req.params.skip) # * fileByPage
    else
        skip = 0
    if req.params.limit?
        limit = parseInt(req.params.limit)
    else
        limit = 100

    [onCreation, percent] = onThumbCreation()

    if onCreation
        res.send "percent": percent

    else

        dates = {}
        options =
            limit      : limit
            skip       : skip
            descending : true
        File.imageByDate options, (err, photos) =>
            if err
                return res.error 500, 'An error occured', err
            else
                if photos.length == limit
                    hasNext = true
                else
                    hasNext = false
                res.send {files: photos, hasNext: hasNext}, 200


# Return thumb for given file.
module.exports.thumb = (req, res, next) ->
    which = if req.file.binary.thumb then 'thumb' else 'file'
    stream = req.file.getBinary which, (err) ->
        return next err if err
    stream.pipe res


# Return screen for given file.
module.exports.screen = (req, res, next) ->
    which = if req.file.binary.screen then 'screen' else 'file'
    stream = req.file.getBinary which, (err) ->
        return next err if err
    stream.pipe res


# Resize picture
resize = (raw, photo, name, callback) ->
    options = if name is 'thumb'
        mode: 'crop'
        width: 300
        height: 300

    else #screen
        mode: 'resize'
        width: 1200
        height: 800

    options.srcPath = raw
    options.dstPath = "/tmp/#{photo.id}2"

    # create files
    fs.open options.dstPath, 'w', (err) ->
        if err
            callback err
        else
            # create a resized file and push it to db
            im[options.mode] options, (err, stdout, stderr) ->
                return callback err if err
                photo.attachBinary options.dstPath, {name}, (err) ->
                    fs.unlink options.dstPath, ->
                        callback err


module.exports.createPhoto = (req, res, next) ->
    file = req.file

    return next new Error('no binary') unless file.binary?

    photo =
        date         : file.lastModification
        title        : ""
        description  : ""
        orientation  : 1
        albumid      : "#{req.body.albumid}"
        binary       : file.binary

    Photo.create photo, (err, photo) ->
        return next err if err

        rawFile = "/tmp/#{photo.id}"
        fs.openSync rawFile, 'w'
        stream = file.getBinary 'file', (err) ->
            return next err if err
        stream.pipe fs.createWriteStream rawFile
        stream.on 'error', next

        stream.on 'end', =>
            if not photo.binary.thumb?
                resize rawFile, photo, 'thumb', (err) ->
                    return next err if err
                    resize rawFile, photo, 'screen', (err) ->
                        fs.unlink rawFile, ->
                            res.send 201, photo
            else
                resize rawFile, photo, 'screen', (err) ->
                    fs.unlink rawFile, ->
                        res.send 201, photo
