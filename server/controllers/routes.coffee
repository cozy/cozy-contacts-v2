contact = require './contact'
contactLog = require './contact_log'
application = require './application'
file = require './file'

module.exports =

    '':
        get: application.index

     'fileid':
        param: file.fetch

    'widget':
        get: application.widget

    'config':
        post: application.setConfig

    'contactid':
        param: contact.fetch

    'logid':
        param: contactLog.fetch

    'contacts.vcf':
        get: contact.vCard
    'contacts/:contactid/:fn.vcf':
        get: contact.vCardContact

    'contacts':
        get: contact.list
        post: contact.create

    'contacts/:contactid':
        get: contact.read
        put: contact.update
        delete: contact.delete

    'contacts/:contactid/picture':
        put: contact.updatePicture

    'contacts/:contactid/picture.png':
        get: contact.picture

    'contacts/:contactid/logs':
        get:  contactLog.byContact
        post: contactLog.create

    # do not fetch contact when we work only on a log
    'contacts/:contactnotfetched/logs/:logid':
        put:  contactLog.update
        delete:  contactLog.delete

    #
    'files/':
        get: file.list
    'files/:page':
        get: file.list
    'files/thumbs/:fileid':
        get: file.thumb
    'files/screens/:fileid':
        get: file.screen
    'files/:fileid/toPhoto':
        post: file.createPhoto


    'logs':
        post: contactLog.merge
