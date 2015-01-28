contact = require './contact'
application = require './application'

module.exports =

    '':
        get: application.index

    'config':
        post: application.setConfig

    'contactid':
        param: contact.fetch

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