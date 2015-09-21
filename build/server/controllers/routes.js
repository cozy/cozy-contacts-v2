// Generated by CoffeeScript 1.10.0
var application, contact, tags;

tags = require('./tags');

contact = require('./contact');

application = require('./application');

module.exports = {
  '': {
    get: application.index
  },
  'config': {
    post: application.setConfig
  },
  'contactid': {
    param: contact.fetch
  },
  'contacts.vcf': {
    get: contact.vCard
  },
  'contacts/:contactid/:fn.vcf': {
    get: contact.vCardContact
  },
  'contacts': {
    get: contact.list,
    post: contact.create
  },
  'contacts/:contactid': {
    get: contact.read,
    put: contact.update,
    "delete": contact["delete"]
  },
  'contacts/:contactid/picture': {
    put: contact.updatePicture
  },
  'contacts/:contactid/picture.png': {
    get: contact.picture
  },
  'tags': {
    get: tags.all,
    post: tags.create
  },
  'tagid': {
    param: tags.fetch
  },
  'tags/:tagid': {
    get: tags.read,
    put: tags.update,
    "delete": tags["delete"]
  },
  'log': {
    post: application.logClient
  }
};
