(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute, path);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    cache[name] = module;
    definition(module.exports, localRequire(name), module);
    return module.exports;
  };

  var require = function(name, loaderPath) {
    var path = expand(name, '.');
    if (loaderPath == null) loaderPath = '/';

    if (has(cache, path)) return cache[path].exports;
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex].exports;
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '" from '+ '"' + loaderPath + '"');
  };

  var define = function(bundle, fn) {
    if (typeof bundle === 'object') {
      for (var key in bundle) {
        if (has(bundle, key)) {
          modules[key] = bundle[key];
        }
      }
    } else {
      modules[bundle] = fn;
    }
  };

  var list = function() {
    var result = [];
    for (var item in modules) {
      if (has(modules, item)) {
        result.push(item);
      }
    }
    return result;
  };

  globals.require = require;
  globals.require.define = define;
  globals.require.register = define;
  globals.require.list = list;
  globals.require.brunch = true;
})();
require.register("application", function(exports, require, module) {
var ContactListener;

ContactListener = require('./lib/contact_listener');

module.exports = {
  initialize: function() {
    var Config, ContactsCollection, ContactsList, Router, TagCollection, e, locales;
    window.app = this;
    this.locale = window.locale;
    delete window.locale;
    this.polyglot = new Polyglot();
    try {
      locales = require('locales/' + this.locale);
    } catch (_error) {
      e = _error;
      locales = require('locales/en');
    }
    this.polyglot.extend(locales);
    window.t = this.polyglot.t.bind(this.polyglot);
    ContactsCollection = require('collections/contact');
    TagCollection = require('collections/tags');
    ContactsList = require('views/contactslist');
    Config = require('models/config');
    Router = require('router');
    this.contacts = new ContactsCollection();
    this.tags = new TagCollection();
    this.contactslist = new ContactsList({
      collection: this.contacts
    });
    this.contactslist.$el.appendTo($('body'));
    this.contactslist.render();
    this.watcher = new ContactListener();
    this.watcher.watch(this.contacts);
    this.config = new Config(window.config || {});
    delete window.config;
    if (window.initcontacts != null) {
      this.contacts.reset(window.initcontacts, {
        parse: true
      });
      delete window.initcontacts;
    } else {
      this.contacts.fetch();
    }
    if (window.inittags != null) {
      this.tags.reset(window.inittags, {
        parse: true
      });
    } else {
      this.tags.fetch();
    }
    this.router = new Router();
    return Backbone.history.start();
  }
};
});

;require.register("collections/contact", function(exports, require, module) {
var ContactCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = ContactCollection = (function(_super) {
  __extends(ContactCollection, _super);

  function ContactCollection() {
    return ContactCollection.__super__.constructor.apply(this, arguments);
  }

  ContactCollection.prototype.model = require('models/contact');

  ContactCollection.prototype.url = 'contacts';

  ContactCollection.prototype.comparator = function(a, b) {
    var compare, nameA, nameB, out;
    nameA = a.getDisplayName().toLowerCase();
    nameB = b.getDisplayName().toLowerCase();
    compare = nameA.localeCompare(nameB);
    return out = compare > 0 ? 1 : compare < 0 ? -1 : 0;
  };

  ContactCollection.prototype.initialize = function() {
    ContactCollection.__super__.initialize.apply(this, arguments);
    this.on('change:fn', (function(_this) {
      return function() {
        return _this.sort();
      };
    })(this));
    return this.on('change:n', (function(_this) {
      return function() {
        return _this.sort();
      };
    })(this));
  };

  ContactCollection.prototype.getTags = function() {
    var out;
    out = window.tags || [];
    this.each(function(contact) {
      return out = out.concat(contact.get('tags'));
    });
    return _.unique(out);
  };

  return ContactCollection;

})(Backbone.Collection);
});

;require.register("collections/datapoint", function(exports, require, module) {
var DataPointCollection,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = DataPointCollection = (function(_super) {
  __extends(DataPointCollection, _super);

  function DataPointCollection() {
    return DataPointCollection.__super__.constructor.apply(this, arguments);
  }

  DataPointCollection.prototype.model = require('models/datapoint');

  DataPointCollection.prototype.hasOne = function(name, type) {
    var query;
    query = {
      name: name
    };
    if (type) {
      query.type = type;
    }
    return this.where(query).length > 0;
  };

  DataPointCollection.prototype.toJSON = function() {
    var truedps;
    truedps = this.filter(function(model) {
      var value;
      value = model.get('value');
      return (value !== null) && (value !== '') && (value !== ' ');
    });
    return truedps.map(function(model) {
      return model.toJSON();
    });
  };

  DataPointCollection.prototype.prune = function() {
    var toDelete;
    toDelete = [];
    this.each((function(_this) {
      return function(datapoint) {
        var value;
        value = datapoint.get('value');
        if ((value === null) || (value === '') || (value === ' ')) {
          return toDelete.push(datapoint);
        }
      };
    })(this));
    return this.remove(toDelete);
  };

  DataPointCollection.prototype.match = function(filter) {
    return this.any(function(datapoint) {
      return filter.test(datapoint.get('value'));
    });
  };

  return DataPointCollection;

})(Backbone.Collection);
});

;require.register("collections/tags", function(exports, require, module) {
var Tag, TagCollection, colorhash,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tag = require('../models/tag');

colorhash = require('lib/colorhash');

module.exports = TagCollection = (function(_super) {
  __extends(TagCollection, _super);

  function TagCollection() {
    return TagCollection.__super__.constructor.apply(this, arguments);
  }

  TagCollection.prototype.model = Tag;

  TagCollection.prototype.url = 'tags';

  TagCollection.prototype.add = function(models, options) {
    if (_.isArray(models)) {
      models = _.clone(models);
    } else {
      models = models ? [models] : [];
    }
    models = models.filter((function(_this) {
      return function(model) {
        return !_this.some(function(collectionModel) {
          var name;
          name = (model != null ? model.name : void 0) ? model.name : model.get('name');
          return collectionModel.get('name') === name;
        });
      };
    })(this));
    return TagCollection.__super__.add.call(this, models, options);
  };

  TagCollection.prototype.getByName = function(name) {
    return this.find(function(item) {
      return item.get('name') === name;
    });
  };

  TagCollection.prototype.getOrCreateByName = function(name) {
    var tag;
    tag = this.getByName(name);
    if (!tag) {
      tag = new Tag({
        name: name,
        color: colorhash(name)
      });
      tag.save();
    }
    return tag;
  };

  return TagCollection;

})(Backbone.Collection);
});

;require.register("initialize", function(exports, require, module) {
var app;

app = require('application');

$(function() {
  jQuery.event.props.push('dataTransfer');
  return app.initialize();
});
});

;require.register("initializewidget", function(exports, require, module) {
var app;

app = require('widget');

$(function() {
  jQuery.event.props.push('dataTransfer');
  return app.initialize();
});
});

;require.register("lib/base_view", function(exports, require, module) {
var BaseView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = BaseView = (function(_super) {
  __extends(BaseView, _super);

  function BaseView() {
    this.render = __bind(this.render, this);
    return BaseView.__super__.constructor.apply(this, arguments);
  }

  BaseView.prototype.initialize = function(options) {
    return this.options = options;
  };

  BaseView.prototype.template = function() {};

  BaseView.prototype.getRenderData = function() {};

  BaseView.prototype.render = function() {
    var data;
    data = _.extend({}, this.options, this.getRenderData());
    this.$el.html(this.template(data));
    this.afterRender();
    return this;
  };

  BaseView.prototype.afterRender = function() {};

  return BaseView;

})(Backbone.View);
});

;require.register("lib/colorhash", function(exports, require, module) {
var hslToRgb, hue2rgb;

hue2rgb = function(p, q, t) {
  if (t < 0) {
    t += 1;
  }
  if (t > 1) {
    t -= 1;
  }
  if (t < 1 / 6) {
    return p + (q - p) * 6 * t;
  }
  if (t < 1 / 2) {
    return q;
  }
  if (t < 2 / 3) {
    return p + (q - p) * (2 / 3 - t) * 6;
  }
  return p;
};

hslToRgb = function(h, s, l) {
  var b, color, g, p, q, r;
  if (s === 0) {
    r = g = b = l;
  } else {
    q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    p = 2 * l - q;
    r = hue2rgb(p, q, h + 1 / 3);
    g = hue2rgb(p, q, h);
    b = hue2rgb(p, q, h - 1 / 3);
  }
  color = (1 << 24) + (r * 255 << 16) + (g * 255 << 8) + parseInt(b * 255);
  return "#" + (color.toString(16).slice(1));
};

module.exports = function(tag) {
  var colour, h, hash, i, l, s, _i, _ref;
  if (tag !== "my calendar") {
    hash = 0;
    for (i = _i = 0, _ref = tag.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      hash = tag.charCodeAt(i) + (hash << 5) - hash;
    }
    h = (hash % 100) / 100;
    s = (hash % 1000) / 1000;
    l = 0.5 + 0.2 * (hash % 2) / 2;
    colour = hslToRgb(h, s, l);
    return colour;
  } else {
    return '#008AF6';
  }
};
});

;require.register("lib/contact_listener", function(exports, require, module) {
var Contact, ContactListener,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Contact = require('../models/contact');

module.exports = ContactListener = (function(_super) {
  __extends(ContactListener, _super);

  function ContactListener() {
    return ContactListener.__super__.constructor.apply(this, arguments);
  }

  ContactListener.prototype.models = {
    'contact': Contact
  };

  ContactListener.prototype.events = ['contact.create', 'contact.update', 'contact.delete'];

  ContactListener.prototype.onRemoteCreate = function(model) {
    return this.collection.add(model, {
      merge: true
    });
  };

  ContactListener.prototype.onRemoteUpdate = function(model, collection) {
    return this.collection.add(model, {
      merge: true
    });
  };

  ContactListener.prototype.onRemoteDelete = function(model) {
    return this.collection.remove(model);
  };

  return ContactListener;

})(CozySocketListener);
});

;require.register("lib/request", function(exports, require, module) {
exports.request = function(type, url, data, callback, json) {
  var options;
  if (json == null) {
    json = true;
  }
  if ((data != null) && json) {
    data = JSON.stringify(data);
  }
  options = {
    type: type,
    url: url,
    data: data != null ? data : null,
    contentType: json ? "application/json" : false,
    dataType: json ? "json" : null,
    processData: json,
    success: function(data) {
      if (callback != null) {
        return callback(null, data);
      }
    },
    error: function(data) {
      if ((data != null) && (data.msg != null) && (callback != null)) {
        return callback(new Error(data.msg));
      } else if (callback != null) {
        return callback(new Error("Server error occured"));
      }
    }
  };
  return $.ajax(options);
};

exports.get = function(url, callback, json) {
  return exports.request("GET", url, null, callback, json);
};

exports.post = function(url, data, callback, json) {
  return exports.request("POST", url, data, callback, json);
};

exports.put = function(url, data, callback, json) {
  return exports.request("PUT", url, data, callback, json);
};

exports.del = function(url, callback, json) {
  return exports.request("DELETE", url, null, callback, json);
};
});

;require.register("lib/vcard_helper", function(exports, require, module) {
exports.nToFN = function(n) {
  var familly, given, middle, parts, prefix, suffix;
  if (!n) {
    n = [];
  }
  familly = n[0], given = n[1], middle = n[2], prefix = n[3], suffix = n[4];
  parts = [prefix, given, middle, familly, suffix];
  parts = parts.filter(function(part) {
    return (part != null) && part !== '';
  });
  return parts.join(' ');
};

exports.fnToN = function(fn) {
  if (fn == null) {
    fn = '';
  }
  return ['', fn, '', '', ''];
};

exports.escapeText = function(s) {
  var t;
  if (s == null) {
    return s;
  }
  t = s.replace(/([,;\\])/ig, "\\$1");
  t = t.replace(/\n/g, '\\n');
  return t;
};

exports.unescapeText = function(t) {
  var s;
  if (t == null) {
    return t;
  }
  s = t.replace(/\\n/ig, '\n');
  s = s.replace(/\\([,;\\])/ig, "$1");
  return s;
};

exports.unquotePrintable = function(s) {
  if (s == null) {
    s = '';
  }
  return utf8.decode(quotedPrintable.decode(s));
};
});

;require.register("lib/view_collection", function(exports, require, module) {
var BaseView, ViewCollection,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('lib/base_view');

module.exports = ViewCollection = (function(_super) {
  __extends(ViewCollection, _super);

  function ViewCollection() {
    this.removeItem = __bind(this.removeItem, this);
    this.addItem = __bind(this.addItem, this);
    return ViewCollection.__super__.constructor.apply(this, arguments);
  }

  ViewCollection.prototype.views = {};

  ViewCollection.prototype.itemView = null;

  ViewCollection.prototype.itemViewOptions = function() {};

  ViewCollection.prototype.checkIfEmpty = function() {
    return this.$el.toggleClass('empty', _.size(this.views) === 0);
  };

  ViewCollection.prototype.appendView = function(view) {
    return this.$el.append(view.el);
  };

  ViewCollection.prototype.initialize = function() {
    ViewCollection.__super__.initialize.apply(this, arguments);
    this.views = {};
    this.listenTo(this.collection, "reset", this.onReset);
    this.listenTo(this.collection, "add", this.addItem);
    this.listenTo(this.collection, "remove", this.removeItem);
    this.listenTo(this.collection, "sort", this.onReset);
    return this.onReset(this.collection);
  };

  ViewCollection.prototype.render = function() {
    var id, view, _ref;
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      view.$el.detach();
    }
    return ViewCollection.__super__.render.apply(this, arguments);
  };

  ViewCollection.prototype.afterRender = function() {
    var id, view, _ref;
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      this.appendView(view);
    }
    return this.checkIfEmpty(this.views);
  };

  ViewCollection.prototype.remove = function() {
    this.onReset([]);
    return ViewCollection.__super__.remove.apply(this, arguments);
  };

  ViewCollection.prototype.onReset = function(newcollection) {
    var id, view, _ref;
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      view.remove();
    }
    return newcollection.forEach(this.addItem);
  };

  ViewCollection.prototype.addItem = function(model) {
    var options, view;
    options = _.extend({}, {
      model: model
    }, this.itemViewOptions(model));
    view = new this.itemView(options);
    this.views[model.cid] = view.render();
    this.appendView(view);
    return this.checkIfEmpty(this.views);
  };

  ViewCollection.prototype.removeItem = function(model) {
    this.views[model.cid].remove();
    delete this.views[model.cid];
    return this.checkIfEmpty(this.views);
  };

  return ViewCollection;

})(BaseView);
});

;require.register("locales/en", function(exports, require, module) {
module.exports = {
  "saving": "Saving…",
  "saved": "Saved",
  "delete": "Delete",
  "delete contact": "Delete the contact permanently",
  "add contact": "Create a new contact",
  "show": "Show",
  "hide": "Hide",
  "contact name expand": "Show contact name details",
  "contact name check": "Close contact name edition",
  "company": "Company",
  "title": "Title",
  "birthday": "Birthday",
  "phone": "Phone",
  "skype": "Skype",
  "email": "Email",
  "postal": "Postal",
  "url": "Url",
  "other": "Other",
  "add": "Add",
  "notes": "Notes",
  "about": "About",
  "name": "Name",
  "firstname lastname": "Firstname Lastname",
  "change": "Change",
  "notes placeholder": "Take notes here",
  "type here": "Type here",
  "phones": "Phones",
  "emails": "Emails",
  "postal": "Postal",
  "links": "Links",
  "others": "Others",
  "actions": "Actions",
  "add fields": "Add fields",
  "more options": "More options",
  "save changes alert": "Save changes?",
  "not an image": "This is not an image",
  "remove datapoint": "Remove",
  "changes saved": "Changes saved",
  "undo": "Undo",
  "undone": "Undone",
  "history": "History",
  "info": "Info",
  "cozy url": "Cozy",
  "twitter": "Twitter",
  "add tags": "add tags",
  "add note": "Add a note",
  "create call task": "Create contact task",
  "creating...": "creating…",
  "edit name": "Edit Name",
  "name editor": "Name Editor",
  "prefix": "Prefix",
  "placeholder prefix": "Sir",
  "first name": "Given Name",
  "placeholder first": "John",
  "middle name": "Middle Name",
  "placeholder middle": "D.",
  "last name": "Family Name",
  "placeholder last": "Doe",
  "suffix": "Suffix",
  "placeholder suffix": "III",
  "full name": "Full name",
  "save": "Save",
  "search placeholder": "Search…",
  "new contact": "New Contact",
  "go to settings": "Settings",
  "choose vcard file": "Choose a vCard file",
  "is not a vcard": "is not a vCard",
  "cancel": "Cancel",
  "import": "Import",
  "import.ready-msg": "Ready to import %{smart_count} contact ||||\nReady to import %{smart_count} contacts",
  "dont close navigator import": "Do not close the navigator while importing contacts.",
  "choose phone country": "Choose the country of the phone",
  "ready to import": "Ready to import",
  "importing this file": "We are importing this file",
  "may take a while": "It may take a while",
  "progress": "Progress",
  "loading import preview": "loading import preview…",
  "import succeeded": "Your contact import succeeded.",
  "import progress": "Import progress",
  "fail to import": "Import failed",
  "click left to display": "Browse: Click on a contact in the left panel to display it.",
  "import export": "Import / Export",
  "vcard import info": "Click here to import a vCard file:",
  "import vcard": "Import vCard",
  "export all vcard": "Export vCard file",
  "export vcard": "Export vCard file",
  "settings": "Settings",
  "help": "Help",
  "name format info": "Select display name format",
  "format given familly": "Given Family (John Johnson)",
  "format familly given": "Name First name (Johnson John)",
  "format given mid familly": "Full (John J. Johnson)",
  "vcard export info": "Click here to export all your contacts as a vCard file:",
  "sync title": "Mobile Synchronization (CardDav)",
  "sync headline no data": "To synchronize your calendar with your devices, you must follow two steps",
  "sync headline with data": "To synchronize your calendar, use the following information:",
  "sync url": "URL:",
  "sync login": "Username:",
  "sync password": "Password: ",
  "sync help": "Are you lost? Follow the ",
  "sync help link": "step-by-step guide!",
  "install the sync module": "Install the Sync module from the Cozy App Store",
  "connect to it and follow": "Connect to it and follow the instructions related to CalDAV.",
  "search info": "Search: Use the search field located on the top left\ncorner to perform a search on all the fields of your contacts. If you\ntype a tag name, results will contain all people tagged with it.",
  "creation info": "Creation: Click on the '+' button located beside the search field to\ndisplay a new contact page. Fill the name field and your contact will\nbe created.",
  "export": "Export",
  "export contact": "Export contact",
  "are you sure": "Are you sure?"
};
});

;require.register("locales/fr", function(exports, require, module) {
module.exports = {
  "saving": "Sauvegarde…",
  "saved": "Sauvegardé",
  "delete": "Supprimer",
  "delete contact": "Supprimer le contact",
  "add contact": "Créer un contact",
  "show": "Montrer",
  "hide": "Cacher",
  "contact name expand": "Afficher les détails sur le nom",
  "contact name check": "Fermet l'édition du nom",
  "company": "Société",
  "title": "Titre",
  "birthday": "Anniversaire",
  "phone": "Téléphone",
  "skype": "Skype",
  "email": "Email",
  "postal": "Adresse",
  "url": "Url",
  "other": "Autre",
  "add": "Ajouter",
  "notes": "Notes",
  "about": "À propos",
  "name": "Nom",
  "firstname lastname": "Prénom Nom",
  "change": "Changer",
  "notes placeholder": "Prenez des notes ici",
  "type here": "Écrivez ici",
  "phones": "Téléphones",
  "emails": "Emails",
  "postal": "Adresses",
  "links": "Liens",
  "others": "Autres",
  "actions": "Actions",
  "add fields": "Ajouter des champs",
  "more options": "Plus d'options",
  "save changes alert": "Sauvegarder ?",
  "not an image": "Ceci n'est pas une image",
  "remove datapoint": "Enlever",
  "changes saved": "Changements enregistrés",
  "undo": "Annuler",
  "undone": "Annulé",
  "history": "Historique",
  "info": "Info",
  "cozy url": "Cozy",
  "twitter": "Twitter",
  "add tags": "Ajouter des tags",
  "add note": "Ajouter une note",
  "create call task": "Créer une tâche de contact",
  "creating...": "création en cours…",
  "edit name": "Modifier le nom",
  "name editor": "Éditeur de nom",
  "prefix": "Préfixe",
  "placeholder prefix": "M.",
  "first name": "Prénom courant",
  "placeholder first": "Pierre",
  "middle name": "Autres prénoms",
  "placeholder middle": "Marie Jacques",
  "last name": "Nom",
  "placeholder last": "Dupont",
  "suffix": "Suffixe",
  "placeholder suffix": "III",
  "full name": "Nom complet",
  "save": "Enregister",
  "search placeholder": "Recherche…",
  "new contact": "Nouveau Contact",
  "go to settings": "Paramètres",
  "choose vcard file": "Choisissez un fichier vCard",
  "is not a vcard": "n'est pas un fichier vCard",
  "cancel": "Annuler",
  "import": "Importer",
  "import.ready-msg": "Prêt à importer %{smart_count} contact ||||\nPrêt à importer %{smart_count} contacts",
  "dont close navigator import": "Ne fermez pas le navigateur durant l'importation des contacts.",
  "choose phone country": "Choisissez le pays de ce téléphone",
  "ready to import": "Prêt à l'importation",
  "importing this file": "Nous importons ce fichier",
  "may take a while": "Cela peut prendre quelques minutes",
  "progress": "Progression",
  "loading import preview": "chargement de l'aperçu de l'importation…",
  "import succeeded": "Votre importation de contact a réussi.",
  "import progress": "Progression de l'importation : ",
  "fail to import": "Échec de l'importation",
  "click left to display": "Navigation : cliquez sur un contact dans le panneau de gauche pour l'afficher",
  "import export": "Importer / Exporter",
  "vcard import info": "Cliquez ici pour importer vos contacts :",
  "import vcard": "Importer vCard",
  "export all vcard": "Exporter un fichier vCard",
  "export vcard": "Exporter un fichier vCard",
  "settings": "Paramètres",
  "help": "Aide",
  "name format info": "Sélectionnez le format d'affichage des noms.",
  "format given familly": "Prénom Nom (Pierre Dupont)",
  "format familly given": "Nom Prénom (Dupont Pierre)",
  "format given mid familly": "Format américain (John J. Johnson)",
  "vcard export info": "Cliquez ici pour exporter tous vos contacts dans un fichier vCard :",
  "sync title": "Synchronisation mobile (CardDav)",
  "sync headline no data": "Pour synchroniser votre agenda avec votre mobile vous devez :",
  "sync headline with data": "Pour synchroniser votre agenda, utilisez les identifiants suivant :",
  "sync url": "URL :",
  "sync login": "Nom d'utilisateur :",
  "sync password": "Mot de passe : ",
  "sync help": "Vous êtes perdu(e) ? Suivez le ",
  "sync help link": "guide pas à pas !",
  "install the sync module": "Installer le module Sync depuis l'applithèque.",
  "connect to it and follow": "Vous connecter et suivre les instructions relatives à CalDAV.",
  "search info": "Recherche : utilisez le champ situé en haut à gauche pour effectuer\nune recherche sur tous les champs de contacts. Si vous saisissez un nom de tag,\nil affichera tous les contacts tagués avec celui-ci.",
  "creation info": "Création : cliquez sur le bouton « + » situé à côté du champ de recherche\npour afficher une nouvelle page de contact. Donnez un nom au contact pour\nqu'il soit sauvegardé.",
  "export": "Exporter",
  "export contact": "Exporter contact",
  "are you sure": "Le voulez-vous vraiment ?"
};
});

;require.register("models/config", function(exports, require, module) {
var Config,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = Config = (function(_super) {
  __extends(Config, _super);

  function Config() {
    return Config.__super__.constructor.apply(this, arguments);
  }

  Config.prototype.url = 'config';

  Config.prototype.isNew = function() {
    return true;
  };

  Config.prototype.defaults = {
    'nameOrder': 'given-familly'
  };

  return Config;

})(Backbone.Model);
});

;require.register("models/contact", function(exports, require, module) {
var ANDROID_RELATION_TYPES, Contact, DataPoint, DataPointCollection, VCard, request,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

request = require('lib/request');

DataPoint = require('models/datapoint');

DataPointCollection = require('collections/datapoint');

VCard = require('lib/vcard_helper');

ANDROID_RELATION_TYPES = ['custom', 'assistant', 'brother', 'child', 'domestic partner', 'father', 'friend', 'manager', 'mother', 'parent', 'partner', 'referred by', 'relative', 'sister', 'spouse'];

module.exports = Contact = (function(_super) {
  var initial;

  __extends(Contact, _super);

  Contact.prototype.urlRoot = 'contacts';

  function Contact() {
    this.match = __bind(this.match, this);
    this.addDP = __bind(this.addDP, this);
    this.dataPoints = new DataPointCollection();
    Contact.__super__.constructor.apply(this, arguments);
  }

  Contact.prototype.initialize = function() {
    return this.on('change:datapoints', (function(_this) {
      return function() {
        var dps;
        dps = _this.get('datapoints');
        if (dps) {
          _this.dataPoints.reset(dps);
          return _this.set('datapoints', null);
        }
      };
    })(this));
  };

  Contact.prototype.defaults = function() {
    return {
      n: [],
      fn: '',
      note: '',
      tags: []
    };
  };

  Contact.prototype.fetch = function(options) {
    if (options == null) {
      options = {};
    }
    options.parse = true;
    return Contact.__super__.fetch.call(this, options);
  };

  Contact.prototype.parse = function(attrs) {
    var _ref, _ref1, _ref2;
    if (_.where(attrs != null ? attrs.datapoints : void 0, {
      name: 'tel'
    }).length === 0) {
      if (attrs != null) {
        if ((_ref = attrs.datapoints) != null) {
          _ref.push({
            name: 'tel',
            type: 'main',
            value: ''
          });
        }
      }
    }
    if (_.where(attrs != null ? attrs.datapoints : void 0, {
      name: 'email'
    }).length === 0) {
      if (attrs != null) {
        if ((_ref1 = attrs.datapoints) != null) {
          _ref1.push({
            name: 'email',
            type: 'main',
            value: ''
          });
        }
      }
    }
    if (attrs.datapoints) {
      this.dataPoints.reset(attrs.datapoints);
      delete attrs.datapoints;
    }
    if ((_ref2 = attrs._attachments) != null ? _ref2.picture : void 0) {
      attrs.pictureRev = attrs._attachments.picture.revpos;
      delete attrs._attachments;
    } else {
      attrs.pictureRev = false;
    }
    if (attrs.photo) {
      attrs.pictureRev = true;
      this.photo = attrs.photo;
      delete attrs.photo;
    }
    if (typeof attrs.n === 'string') {
      attrs.n = attrs.n.split(';');
    }
    if (!Array.isArray(attrs.n)) {
      attrs.n = this.getComputedN(attrs.fn);
    }
    return attrs;
  };

  Contact.prototype.savePicture = function(callback) {
    var array, binary, blob, data, i, markChanged, path, _i, _ref;
    callback = callback || function() {};
    if (!this.photo) {
      return callback();
    } else if (this.get('id') == null) {
      return this.save({}, {
        success: (function(_this) {
          return function() {
            return _this.savePicture(callback);
          };
        })(this)
      });
    } else {
      binary = atob(this.photo);
      array = [];
      for (i = _i = 0, _ref = binary.length; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        array.push(binary.charCodeAt(i));
      }
      blob = new Blob([new Uint8Array(array)], {
        type: 'image/jpeg'
      });
      data = new FormData();
      data.append('picture', blob);
      data.append('contact', JSON.stringify(this.toJSON()));
      markChanged = (function(_this) {
        return function(err, body) {
          if (err) {
            return console.log(err);
          } else {
            _this.set('pictureRev', true);
            return delete _this.photo;
          }
        };
      })(this);
      path = "contacts/" + (this.get('id')) + "/picture";
      request.put(path, data, markChanged, false);
      return callback();
    }
  };

  Contact.prototype.getBest = function(name) {
    var result;
    result = null;
    this.dataPoints.each(function(dp) {
      if (dp.get('name') === name) {
        if (dp.get('pref')) {
          return result = dp.get('value');
        } else {
          return result != null ? result : result = dp.get('value');
        }
      }
    });
    return result;
  };

  Contact.prototype.addDP = function(name, type, value) {
    return this.dataPoints.add({
      type: type,
      name: name,
      value: value
    });
  };

  Contact.prototype.match = function(filter) {
    return filter.test(this.get('n')) || filter.test(this.get('fn')) || filter.test(this.get('note')) || filter.test(this.get('tags').join(' ')) || this.dataPoints.match(filter);
  };

  Contact.prototype.toJSON = function() {
    var json;
    json = Contact.__super__.toJSON.apply(this, arguments);
    json.datapoints = this.dataPoints.toJSON();
    if (Array.isArray(json.n)) {
      json.n = json.n.join(';');
    }
    if (!json.n) {
      delete json.n;
    }
    delete json.photo;
    delete json.pictureRev;
    return json;
  };

  Contact.prototype.setFN = function(value) {
    this.set('fn', value);
    return this.set('n', this.getComputedN(value));
  };

  Contact.prototype.setN = function(value) {
    this.set('n', value);
    return this.set('fn', this.getComputedFN(value));
  };

  Contact.prototype.getDisplayName = function() {
    var familly, given, middle, n, prefix, suffix;
    n = this.get('n');
    if (!(n && n.length > 0)) {
      return '';
    }
    familly = n[0], given = n[1], middle = n[2], prefix = n[3], suffix = n[4];
    switch (app.config.get('nameOrder')) {
      case 'given-familly':
        return "" + given + " " + middle + " " + familly;
      case 'given-middleinitial-familly':
        return "" + given + " " + (initial(middle)) + " " + familly;
      default:
        return "" + familly + " " + given + " " + middle;
    }
  };

  initial = function(middle) {
    var i, _ref;
    if (i = (_ref = middle.split(/[ \,]/)[0][0]) != null ? _ref.toUpperCase() : void 0) {
      return i + '.';
    } else {
      return '';
    }
  };

  Contact.prototype.getComputedFN = function(n) {
    if (n == null) {
      n = this.get('n');
    }
    if (!(n && n.length > 0)) {
      return '';
    }
    return VCardParser.nToFN(n);
  };

  Contact.prototype.getComputedN = function(fn) {
    if (fn == null) {
      fn = this.get('fn');
    }
    return VCardParser.fnToN(fn);
  };

  Contact.prototype.getTags = function() {
    return this.get('tags').map(function(tagName) {
      return app.tags.getOrCreateByName(tagName);
    });
  };

  Contact.prototype.createTask = function(callback) {
    return request.post("contacts/" + this.id + "/new-call-task", {}, callback);
  };

  return Contact;

})(Backbone.Model);

Contact.fromVCF = function(vcf) {
  var ContactCollection, imported, parser;
  ContactCollection = require('collections/contact');
  parser = new VCardParser();
  parser.read(vcf);
  imported = new ContactCollection(parser.contacts, {
    parse: true
  });
  return imported;
};
});

;require.register("models/datapoint", function(exports, require, module) {
var DataPoint,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

module.exports = DataPoint = (function(_super) {
  __extends(DataPoint, _super);

  function DataPoint() {
    return DataPoint.__super__.constructor.apply(this, arguments);
  }

  DataPoint.prototype.defaults = {
    type: 'main',
    name: 'other',
    value: ''
  };

  DataPoint.prototype.toDisplayJSON = function() {
    var json;
    json = this.toJSON();
    if (this.attributes.name === 'adr') {
      json.value = VCardParser.adrArrayToString(this.attributes.value);
    }
    return json;
  };

  DataPoint.prototype.setTypeNValue = function(type, value) {
    if (this.attributes.name === 'adr') {
      value = VCardParser.adrStringToArray(value);
    }
    return this.set({
      type: type,
      value: value
    });
  };

  return DataPoint;

})(Backbone.Model);
});

;require.register("models/tag", function(exports, require, module) {
var Tag, colorhash,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

colorhash = require('lib/colorhash');

module.exports = Tag = (function(_super) {
  __extends(Tag, _super);

  function Tag() {
    return Tag.__super__.constructor.apply(this, arguments);
  }

  Tag.prototype.urlRoot = 'tags';

  Tag.prototype.toString = function() {
    return this.get('name');
  };

  return Tag;

})(Backbone.Model);
});

;require.register("router", function(exports, require, module) {
var Contact, ContactView, DocView, ImporterView, Router, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

app = require('application');

ContactView = require('views/contact');

DocView = require('views/doc');

ImporterView = require('views/importer');

Contact = require('models/contact');

module.exports = Router = (function(_super) {
  __extends(Router, _super);

  function Router() {
    return Router.__super__.constructor.apply(this, arguments);
  }

  Router.prototype.routes = {
    '': 'list',
    'help': 'help',
    'import': 'import',
    'contact/new': 'newcontact',
    'contact/:id': 'showcontact'
  };

  Router.prototype.initialize = function() {
    return $('body').on('keyup', (function(_this) {
      return function(event) {
        if (event.keyCode === 27) {
          return _this.navigate("", true);
        }
      };
    })(this));
  };

  Router.prototype.list = function() {
    if ($(window).width() > 900) {
      this.help();
    } else {
      this.displayView(null);
    }
    $('#filterfied').focus();
    return app.contactslist.activate(null);
  };

  Router.prototype.help = function() {
    $(".toggled").removeClass('toggled');
    $("#gohelp").addClass('toggled');
    $(".activated").removeClass('activated');
    return this.displayView(new DocView());
  };

  Router.prototype["import"] = function() {
    this.help();
    this.importer = new ImporterView();
    return $('body').append(this.importer.render().$el);
  };

  Router.prototype.newcontact = function() {
    var contact;
    $(".toggled").removeClass('toggled');
    $("#new").addClass('toggled');
    $(".activated").removeClass('activated');
    contact = new Contact();
    contact.dataPoints.add({
      name: 'tel',
      type: 'main',
      value: ''
    });
    contact.dataPoints.add({
      name: 'email',
      type: 'main',
      value: ''
    });
    contact.once('change:id', (function(_this) {
      return function() {
        app.contacts.add(contact);
        return _this.navigate("contact/" + contact.id, false);
      };
    })(this));
    this.displayViewFor(contact, true);
    return $('#name').focus();
  };

  Router.prototype.showcontact = function(id) {
    var contact;
    $(".toggled").removeClass('toggled');
    if (app.contacts.length === 0) {
      app.contacts.once('sync', (function(_this) {
        return function() {
          return _this.showcontact(id);
        };
      })(this));
      return;
    }
    contact = app.contacts.get(id);
    if (contact) {
      this.displayViewFor(contact);
      return app.contactslist.activate(contact);
    } else {
      alert(t("this contact doesn't exist"));
      return this.navigate('', true);
    }
  };

  Router.prototype.displayView = function(view, creation) {
    var _ref, _ref1, _ref2;
    if (this.currentContact) {
      this.stopListening(this.currentContact);
    }
    if (((_ref = app.contactview) != null ? _ref.needSaving : void 0) && confirm(t('Save changes ?'))) {
      app.contactview.save();
      app.contactview.model.once('sync', (function(_this) {
        return function() {
          return _this.displayView(view);
        };
      })(this));
      return;
    }
    if (this.importer) {
      this.importer.close();
    }
    this.importer = null;
    if (app.contactview) {
      app.contactview.remove();
    }
    app.contactview = view;
    if ((_ref1 = app.contactview) != null) {
      _ref1.$el.appendTo($('body'));
    }
    if ((_ref2 = app.contactview) != null) {
      _ref2.render();
    }
    if (creation) {
      if (view != null) {
        view.$("#more-options").hide();
      }
      if (view != null) {
        view.$("#adder").show();
      }
      return view != null ? view.$("#adder h2").show() : void 0;
    }
  };

  Router.prototype.displayViewFor = function(contact, creation) {
    this.currentContact = contact;
    this.displayView(new ContactView({
      model: contact
    }), creation);
    return this.listenTo(contact, 'destroy', function() {
      return this.navigate('', true);
    });
  };

  return Router;

})(Backbone.Router);
});

;require.register("templates/contact", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),hasPicture = locals_.hasPicture,id = locals_.id,fn = locals_.fn,note = locals_.note;
buf.push("<div id=\"contact-container\"><div id=\"top\"><div id=\"picture\">");
if ( hasPicture)
{
buf.push("<img" + (jade.attr("src", "contacts/" + (id) + "/picture.png", true, false)) + " class=\"picture\"/>");
}
else
{
buf.push("<img src=\"img/defaultpicture.png\" class=\"picture\"/>");
}
buf.push("<input id=\"uploader\" type=\"file\"/><div id=\"uploadnotice\">" + (jade.escape(null == (jade_interp = t("change")) ? "" : jade_interp)) + "</div></div><div id=\"wrap-name-notes\"><div id=\"contact-name\" style=\"display: none;\"></div><input id=\"name\"" + (jade.attr("placeholder", t("firstname lastname"), true, false)) + (jade.attr("value", "" + (fn) + "", true, false)) + "/><ul class=\"tags\"></ul><span id=\"save-info\">" + (jade.escape(null == (jade_interp = t('changes saved') + ' ') ? "" : jade_interp)) + "<a id=\"undo\">" + (jade.escape(null == (jade_interp = t('undo')) ? "" : jade_interp)) + "</a></span></div><a id=\"close\" href=\"#\">&lt;</a></div><div id=\"right\"><ul class=\"nav nav-tabs\"><li><a id=\"infotab\" href=\"#info\" data-toggle=\"tab\">" + (jade.escape(null == (jade_interp = t('info')) ? "" : jade_interp)) + "</a></li><li class=\"active\"><a href=\"#notes-zone\" data-toggle=\"tab\">" + (jade.escape(null == (jade_interp = t('notes')) ? "" : jade_interp)) + "</a></li></ul><div class=\"tab-content\"><div id=\"notes-zone\" class=\"tab-pane active\"><textarea rows=\"3\"" + (jade.attr("placeholder", t('notes placeholder'), true, false)) + " id=\"notes\">" + (jade.escape((jade_interp = note) == null ? '' : jade_interp)) + "</textarea></div><div id=\"info\" class=\"tab-pane\"></div></div></div><div id=\"left\"><div id=\"abouts\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("about")) ? "" : jade_interp)) + "</h2><ul></ul><a class=\"btn add addabout\">" + (jade.escape(null == (jade_interp = t('add')) ? "" : jade_interp)) + "</a></div><div id=\"tels\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("phones")) ? "" : jade_interp)) + "</h2><ul></ul><a class=\"btn add addtel\">" + (jade.escape(null == (jade_interp = t('add')) ? "" : jade_interp)) + "</a></div><div id=\"emails\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("emails")) ? "" : jade_interp)) + "</h2><ul></ul><a class=\"btn add addemail\">" + (jade.escape(null == (jade_interp = t('add')) ? "" : jade_interp)) + "</a></div><div id=\"adrs\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("postal")) ? "" : jade_interp)) + "</h2><ul></ul><a class=\"btn add addadr\">" + (jade.escape(null == (jade_interp = t('add')) ? "" : jade_interp)) + "</a></div><div id=\"urls\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("links")) ? "" : jade_interp)) + "</h2><ul></ul><a class=\"btn add addurl\">" + (jade.escape(null == (jade_interp = t('add')) ? "" : jade_interp)) + "</a></div><div id=\"others\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("others")) ? "" : jade_interp)) + "</h2><ul></ul><a class=\"btn add addother\">" + (jade.escape(null == (jade_interp = t('add')) ? "" : jade_interp)) + "</a></div><div class=\"zone clearfix\">&nbsp;</div><div class=\"zone\"><a id=\"more-options\" class=\"button\">" + (jade.escape(null == (jade_interp = t('more options')) ? "" : jade_interp)) + "</a></div><div id=\"adder\" class=\"zone\"><h2>" + (jade.escape(null == (jade_interp = t("actions")) ? "" : jade_interp)) + "</h2><h3>" + (jade.escape(null == (jade_interp = t("add fields")) ? "" : jade_interp)) + "</h3><a class=\"button addbirthday\">" + (jade.escape(null == (jade_interp = t("birthday") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addorg\">" + (jade.escape(null == (jade_interp = t("company") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addtitle\">" + (jade.escape(null == (jade_interp = t("title") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addcozy\">" + (jade.escape(null == (jade_interp = t("cozy url") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addtwitter\">" + (jade.escape(null == (jade_interp = t("twitter") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addtel\">" + (jade.escape(null == (jade_interp = t("phone") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addemail\">" + (jade.escape(null == (jade_interp = t("email") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addadr\">" + (jade.escape(null == (jade_interp = t("postal") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addurl\">" + (jade.escape(null == (jade_interp = t("url") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addskype\">" + (jade.escape(null == (jade_interp = t("skype") + ' ') ? "" : jade_interp)) + "</a><a class=\"button addother\">" + (jade.escape(null == (jade_interp = t("other")) ? "" : jade_interp)) + "</a><h3>" + (jade.escape(null == (jade_interp = t("export")) ? "" : jade_interp)) + "</h3><a id=\"export\"" + (jade.attr("href", 'contacts/' + (id) + '/' + (fn) + '.vcf', true, false)) + (jade.attr("title", t("export contact"), true, false)) + " class=\"button\">" + (jade.escape(null == (jade_interp = t('export contact')) ? "" : jade_interp)) + "</a><h3>" + (jade.escape(null == (jade_interp = t("delete")) ? "" : jade_interp)) + "</h3><a id=\"delete\"" + (jade.attr("title", t("delete contact"), true, false)) + " class=\"button\">" + (jade.escape(null == (jade_interp = t('delete contact')) ? "" : jade_interp)) + "</a></div></div></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("templates/contact_name", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),n = locals_.n;
buf.push("<form class=\"form-horizontal\"><div class=\"control-group prefix\"><label for=\"prefix\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t("prefix")) ? "" : jade_interp)) + "</label><div class=\"controls\"><input id=\"prefix\" type=\"text\"" + (jade.attr("value", n[3], true, false)) + (jade.attr("placeholder", t("placeholder prefix"), true, false)) + "/></div></div><div class=\"control-group first\"><label for=\"first\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t("first name")) ? "" : jade_interp)) + "</label><div class=\"controls\"><input id=\"first\" type=\"text\"" + (jade.attr("value", n[1], true, false)) + (jade.attr("placeholder", t("placeholder first"), true, false)) + "/></div></div><div class=\"control-group middle\"><label for=\"middle\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t("middle name")) ? "" : jade_interp)) + "</label><div class=\"controls\"><input id=\"middle\" type=\"text\"" + (jade.attr("value", n[2], true, false)) + (jade.attr("placeholder", t("placeholder middle"), true, false)) + "/></div></div><div class=\"control-group last\"><label for=\"last\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t("last name")) ? "" : jade_interp)) + "</label><div class=\"controls\"><input id=\"last\" type=\"text\"" + (jade.attr("value", n[0], true, false)) + (jade.attr("placeholder", t("placeholder last"), true, false)) + "/></div></div><div class=\"control-group suffix\"><label for=\"suffix\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t("suffix")) ? "" : jade_interp)) + "</label><div class=\"controls\"><input id=\"suffix\" type=\"text\"" + (jade.attr("value", n[4], true, false)) + (jade.attr("placeholder", t("placeholder suffix"), true, false)) + "/></div></div></form><div class=\"button-wrapper\"><a id=\"toggle-name-fields\"" + (jade.attr("title", t("contact name expand"), true, false)) + " class=\"icon-black icon-minus\"></a><a id=\"toggle-name\"" + (jade.attr("title", t("contact name check"), true, false)) + " class=\"icon-black icon-check\"></a></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("templates/contactslist", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<form id=\"toolbar\" class=\"form-search\"><div class=\"input-append input-prepend\"><span class=\"add-on\"><i class=\"fa fa-search\"></i></span><input id=\"filterfield\" type=\"text\"" + (jade.attr("placeholder", t("search placeholder"), true, false)) + " class=\"search-query input-large\"/><a id=\"filterClean\" class=\"button\"><i class=\"fa fa-remove\"></i></a></div><a id=\"new\" href=\"#contact/new\"" + (jade.attr("title", t("add contact"), true, false)) + " class=\"button\"><i class=\"fa fa-plus\"></i></a><a id=\"gohelp\" href=\"#help\"" + (jade.attr("title", t("go to settings"), true, false)) + " class=\"button\"><i class=\"fa fa-cog\"></i></a></form><div id=\"contacts\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("templates/contactslist_item", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),hasPicture = locals_.hasPicture,id = locals_.id,timestamp = locals_.timestamp,displayName = locals_.displayName,bestmail = locals_.bestmail,besttel = locals_.besttel;
if ( hasPicture)
{
buf.push("<img" + (jade.attr("src", "contacts/" + (id) + "/picture.png?" + (timestamp) + "", true, false)) + "/>");
}
else
{
buf.push("<img src=\"img/defaultpicture.png\"/>");
}
buf.push("<h2>" + (jade.escape((jade_interp = displayName) == null ? '' : jade_interp)) + "</h2><div class=\"infos\"><span class=\"email\">" + (jade.escape((jade_interp = bestmail) == null ? '' : jade_interp)) + "</span><span class=\"tel\">  " + (jade.escape((jade_interp = besttel) == null ? '' : jade_interp)) + "</span></div><div class=\"clearfix\"></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("templates/datapoint", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),type = locals_.type,name = locals_.name,placeholder = locals_.placeholder,value = locals_.value;
buf.push("<input type=\"text\" data-provide=\"typeahead\"" + (jade.attr("value", "" + (type) + "", true, false)) + " class=\"type\"/>");
if ( name == 'adr')
{
buf.push("<textarea rows=\"4\"" + (jade.attr("placeholder", "" + (placeholder) + "", true, false)) + " class=\"value\">" + (jade.escape((jade_interp = value) == null ? '' : jade_interp)) + "</textarea>");
}
else
{
buf.push("<input type=\"text\"" + (jade.attr("placeholder", "" + (placeholder) + "", true, false)) + (jade.attr("value", "" + (value) + "", true, false)) + " class=\"value\"/>");
}
buf.push("<a class=\"dpaction\"><i class=\"fa\"></i></a><a" + (jade.attr("title", t('remove datapoint'), true, false)) + " class=\"dpremove\"><i class=\"fa fa-trash\"></i></a>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("templates/doc", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),account = locals_.account;
buf.push("<a id=\"close\" href=\"#\">&lt;</a><h2>" + (jade.escape(null == (jade_interp = t('help')) ? "" : jade_interp)) + "</h2><p>" + (jade.escape(null == (jade_interp = t("search info")) ? "" : jade_interp)) + "</p><p>" + (jade.escape(null == (jade_interp = t("click left to display")) ? "" : jade_interp)) + "</p><p>" + (jade.escape(null == (jade_interp = t("creation info")) ? "" : jade_interp)) + "</p><h2>" + (jade.escape(null == (jade_interp = t('sync title')) ? "" : jade_interp)) + "</h2>");
if ( account == null)
{
buf.push("<p>" + (jade.escape(null == (jade_interp = t('sync headline no data')) ? "" : jade_interp)) + "</p><ol><li>" + (jade.escape(null == (jade_interp = t('install the sync module')) ? "" : jade_interp)) + "</li><li>" + (jade.escape(null == (jade_interp = t('connect to it and follow')) ? "" : jade_interp)) + "</li></ol>");
}
else
{
buf.push("<p>" + (jade.escape(null == (jade_interp = t('sync headline with data')) ? "" : jade_interp)) + "</p><ul><li>" + (jade.escape((jade_interp = t('sync url')) == null ? '' : jade_interp)) + " https://" + (jade.escape((jade_interp = account.domain) == null ? '' : jade_interp)) + "/public/sync/principals/me</li><li>" + (jade.escape((jade_interp = t('sync login')) == null ? '' : jade_interp)) + " " + (jade.escape((jade_interp = account.login) == null ? '' : jade_interp)) + "</li><li>" + (jade.escape((jade_interp = t('sync password')) == null ? '' : jade_interp)) + "<span id=\"placeholder\">" + (jade.escape(null == (jade_interp = account.placeholder) ? "" : jade_interp)) + "</span><button id=\"show-password\" class=\"button\">" + (jade.escape(null == (jade_interp = t('show')) ? "" : jade_interp)) + "</button><button id=\"hide-password\" class=\"button\">" + (jade.escape(null == (jade_interp = t('hide')) ? "" : jade_interp)) + "</button></li></ul>");
}
buf.push("<p>" + (jade.escape(null == (jade_interp = t('sync help')) ? "" : jade_interp)) + "<a href=\"https://cozy.io/mobile/contacts.html\" target=\"_blank\">" + (jade.escape(null == (jade_interp = t('sync help link')) ? "" : jade_interp)) + "</a></p><h2>" + (jade.escape(null == (jade_interp = t('settings')) ? "" : jade_interp)) + "</h2><label for=\"nameFormat\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t('name format info')) ? "" : jade_interp)) + "</label><div class=\"control\"><select id=\"nameFormat\" class=\"span5 large\"><option value=\"\">" + (jade.escape(null == (jade_interp = t('name format info')) ? "" : jade_interp)) + "</option><option value=\"given-familly\">" + (jade.escape(null == (jade_interp = t('format given familly')) ? "" : jade_interp)) + "</option><option value=\"familly-given\">" + (jade.escape(null == (jade_interp = t('format familly given')) ? "" : jade_interp)) + "</option><option value=\"given-middleinitial-familly\">" + (jade.escape(null == (jade_interp = t('format given mid familly')) ? "" : jade_interp)) + "</option></select><span class=\"help-inline\"></span></div><p>" + (jade.escape(null == (jade_interp = t('vcard export info') + ' ') ? "" : jade_interp)) + "<a href=\"contacts.vcf\" download=\"contacts.vcf\"" + (jade.attr("title", t("export vcard"), true, false)) + ">" + (jade.escape(null == (jade_interp = t('export all vcard')) ? "" : jade_interp)) + "</a></p><p>" + (jade.escape(null == (jade_interp = t("vcard import info") + ' ') ? "" : jade_interp)) + "<a href=\"#import\">" + (jade.escape(null == (jade_interp = t('import vcard')) ? "" : jade_interp)) + "</a></p>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("templates/importer", function(exports, require, module) {
var __templateData = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

buf.push("<div class=\"modal-header\">" + (jade.escape(null == (jade_interp = t("import vcard")) ? "" : jade_interp)) + "</div><div class=\"modal-body\"><div class=\"control-group\"><label for=\"vcfupload\" class=\"control-label\">" + (jade.escape(null == (jade_interp = t("choose vcard file")) ? "" : jade_interp)) + "</label><div class=\"controls\"><input id=\"vcfupload\" type=\"file\"/><span class=\"help-inline\"></span></div><div class=\"infos\"><span class=\"loading\">" + (jade.escape(null == (jade_interp = t("loading import preview")) ? "" : jade_interp)) + "</span><span class=\"progress\"></span></div></div></div><div class=\"modal-footer\"><a id=\"cancel-btn\" href=\"#\" class=\"minor-button\">" + (jade.escape(null == (jade_interp = t("cancel")) ? "" : jade_interp)) + "</a><a id=\"confirm-btn\" class=\"button disabled\">" + (jade.escape(null == (jade_interp = t("import")) ? "" : jade_interp)) + "</a></div>");;return buf.join("");
};
if (typeof define === 'function' && define.amd) {
  define([], function() {
    return __templateData;
  });
} else if (typeof module === 'object' && module && module.exports) {
  module.exports = __templateData;
} else {
  __templateData;
}
});

;require.register("views/contact", function(exports, require, module) {
var ContactName, ContactView, Datapoint, TagsView, ViewCollection, request,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('lib/view_collection');

TagsView = require('widgets/tags');

ContactName = require('views/contact_name');

Datapoint = require('models/datapoint');

request = require('../lib/request');

module.exports = ContactView = (function(_super) {
  __extends(ContactView, _super);

  ContactView.prototype.id = 'contact';

  ContactView.prototype.template = require('templates/contact');

  ContactView.prototype.itemView = require('views/datapoint');

  ContactView.prototype.events = function() {
    return {
      'click .addbirthday': this.addClicked('about', 'birthday'),
      'click .addorg': this.addClicked('about', 'company'),
      'click .addtitle': this.addClicked('about', 'title'),
      'click .addcozy': this.addClicked('about', 'cozy'),
      'click .addtwitter': this.addClicked('about', 'twitter'),
      'click .addabout': this.addClicked('about'),
      'click .addtel': this.addClicked('tel'),
      'click .addemail': this.addClicked('email'),
      'click .addadr': this.addClicked('adr'),
      'click .addother': this.addClicked('other'),
      'click .addurl': this.addClicked('url'),
      'click .addskype': this.addClicked('other', 'skype'),
      'click #more-options': 'onMoreOptionsClicked',
      'click #name': 'toggleContactName',
      'click #undo': 'undo',
      'click #delete': 'delete',
      'change #uploader': 'photoChanged',
      'keyup input.value': 'addBelowIfEnter',
      'keydown #notes': 'resizeNote',
      'keypress #notes': 'resizeNote',
      'keyup #notes': 'doNeedSaving',
      'keydown #name': 'onNameKeyPress',
      'keydown textarea#notes': 'onNoteKeyPress',
      'keydown .ui-widget-content': 'onTagInputKeyPress',
      'blur #notes': 'changeOccured'
    };
  };

  function ContactView(options) {
    this.photoChanged = __bind(this.photoChanged, this);
    this.resizeNiceScroll = __bind(this.resizeNiceScroll, this);
    this.modelChanged = __bind(this.modelChanged, this);
    this.undo = __bind(this.undo, this);
    this.onMoreOptionsClicked = __bind(this.onMoreOptionsClicked, this);
    this.save = __bind(this.save, this);
    this.changeOccured = __bind(this.changeOccured, this);
    this.doNeedSaving = __bind(this.doNeedSaving, this);
    options.collection = options.model.dataPoints;
    ContactView.__super__.constructor.apply(this, arguments);
  }

  ContactView.prototype.initialize = function() {
    ContactView.__super__.initialize.apply(this, arguments);
    this.listenTo(this.model, 'change', this.modelChanged);
    this.listenTo(this.model, 'sync', this.onSuccess);
    this.listenTo(this.collection, 'change', (function(_this) {
      return function() {
        _this.needSaving = true;
        return _this.changeOccured();
      };
    })(this));
    this.listenTo(this.collection, 'remove', (function(_this) {
      return function() {
        _this.needSaving = true;
        return _this.changeOccured();
      };
    })(this));
    return this.listenTo(this.model, 'remove', function() {
      return window.app.router.navigate('', true);
    });
  };

  ContactView.prototype.getRenderData = function() {
    return _.extend({}, this.model.toJSON(), {
      hasPicture: !!this.model.get('pictureRev'),
      fn: this.model.get('fn'),
      timestamp: Date.now()
    });
  };

  ContactView.prototype.afterRender = function() {
    var type, _i, _len, _ref;
    this.contactName = new ContactName({
      model: this.model,
      onKeyup: (function(_this) {
        return function(ev) {
          return _this.doNeedSaving(ev);
        };
      })(this),
      onBlur: (function(_this) {
        return function(ev) {
          _this.needSaving = true;
          return _this.changeOccured();
        };
      })(this),
      contactWidget: this
    });
    this.contactName.render();
    this.zones = {};
    _ref = ['about', 'email', 'adr', 'tel', 'url', 'other'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      type = _ref[_i];
      this.zones[type] = this.$('#' + type + 's ul');
    }
    this.hideEmptyZones();
    this.savedInfo = this.$('#save-info').hide();
    this.needSaving = false;
    this.notesfield = this.$('#notes');
    this.uploader = this.$('#uploader')[0];
    this.picture = this.$('#picture .picture');
    this.tags = new TagsView({
      el: this.$('.tags'),
      model: this.model,
      onBlur: (function(_this) {
        return function(ev) {
          _this.needSaving = true;
          return _this.changeOccured(true);
        };
      })(this)
    });
    this.tags.render();
    this.tags.on('tagClicked', (function(_this) {
      return function(tag) {
        $("#filterfield").val(tag);
        $("#filterfield").trigger('keyup');
        return $(".dropdown-menu").hide();
      };
    })(this));
    ContactView.__super__.afterRender.apply(this, arguments);
    this.$el.niceScroll();
    this.resizeNote();
    this.currentState = this.model.toJSON();
    if ($(window).width() < 900) {
      this.$('a#infotab').tab('show');
    }
    this.$('a[data-toggle="tab"]').on('shown', (function(_this) {
      return function() {
        if ($(window).width() < 900) {
          _this.$('#left').hide();
        }
        return _this.resizeNiceScroll();
      };
    })(this));
    this.$('a#infotab').on('shown', (function(_this) {
      return function() {
        _this.$('#left').show();
        return _this.resizeNiceScroll();
      };
    })(this));
    if (this.model.isNew()) {
      return this.toggleContactName();
    }
  };

  ContactView.prototype.remove = function() {
    this.$el.getNiceScroll().remove();
    return ContactView.__super__.remove.apply(this, arguments);
  };

  ContactView.prototype.hideEmptyZones = function() {
    var hasOne, name, type, zone, _i, _len, _ref, _ref1;
    _ref = this.zones;
    for (type in _ref) {
      zone = _ref[type];
      hasOne = this.model.dataPoints.hasOne(type);
      zone.parent().toggle(hasOne);
      this.$("#adder .add" + type).toggle(!hasOne);
    }
    _ref1 = ['birthday', 'org', 'title', 'cozy'];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      name = _ref1[_i];
      hasOne = this.model.dataPoints.hasOne('about', name);
      this.$("#adder .add" + name).toggle(!hasOne);
    }
    this.$('#adder h2').toggle(this.$('#adder a:visible').length !== 0);
    return this.resizeNiceScroll();
  };

  ContactView.prototype.appendView = function(dataPointView) {
    var type;
    if (!this.zones) {
      return;
    }
    type = dataPointView.model.get('name');
    this.zones[type].append(dataPointView.el);
    return this.hideEmptyZones();
  };

  ContactView.prototype.addClicked = function(name, type) {
    return function(event) {
      var point, toFocus, typeField;
      event.preventDefault();
      point = new Datapoint({
        name: name
      });
      if (type != null) {
        point.set('type', type);
      }
      if (type === 'twitter') {
        point.set('value', '@');
      }
      this.model.dataPoints.add(point);
      toFocus = type != null ? '.value' : '.type';
      typeField = this.zones[name].children().last().find(toFocus);
      typeField.focus();
      return typeField.select();
    };
  };

  ContactView.prototype.doNeedSaving = function(event) {
    var isEnter;
    isEnter = event.keyCode === 13 || event.which === 13;
    if (isEnter && event.target.id === 'name') {
      this.changeOccured(true);
    }
    this.needSaving = true;
    return true;
  };

  ContactView.prototype.changeOccured = function(forceImmediate) {
    return setTimeout((function(_this) {
      return function() {
        if (_this.$('input:focus, textarea:focus').length && !forceImmediate) {
          return true;
        }
        _this.model.setN(_this.contactName.getStructuredName());
        _this.model.set({
          note: _this.notesfield.val()
        });
        if (_.isEqual(_this.currentState, _this.model.toJSON())) {
          return _this.needSaving = false;
        } else {
          _this.savedInfo.hide();
          return _this.save();
        }
      };
    })(this), 10);
  };

  ContactView.prototype["delete"] = function() {
    if (this.model.isNew() || confirm(t('are you sure'))) {
      return this.model.destroy();
    }
  };

  ContactView.prototype.save = function() {
    if (!this.needSaving) {
      return;
    }
    this.needSaving = false;
    this.savedInfo.show().text('saving changes');
    return this.model.save({
      success: (function(_this) {
        return function() {
          return _this.collection.trigger('change', _this.model);
        };
      })(this)
    });
  };

  ContactView.prototype.toggleContactName = function() {
    if (this.$('#name').is(':visible')) {
      this.$('#name').hide();
      this.$('#contact-name').show();
      return this.$('#first').focus();
    } else {
      this.$('#name').show();
      this.$('#contact-name').hide();
      return this.$('#name').blur();
    }
  };

  ContactView.prototype.onMoreOptionsClicked = function() {
    return this.$("#more-options").fadeOut((function(_this) {
      return function() {
        _this.$("#adder h2").show();
        _this.$("#adder").fadeIn();
        return _this.resizeNiceScroll();
      };
    })(this));
  };

  ContactView.prototype.undo = function() {
    if (!this.lastState) {
      return;
    }
    this.model.set(this.lastState, {
      parse: true
    });
    this.model.save(null, {
      undo: true
    });
    return this.resizeNote();
  };

  ContactView.prototype.onSuccess = function(model, result, options) {
    var undo;
    if (options.undo) {
      this.savedInfo.text(t('undone') + ' ');
      this.lastState = null;
      setTimeout((function(_this) {
        return function() {
          return _this.savedInfo.fadeOut();
        };
      })(this), 1000);
    } else {
      this.savedInfo.text(t('changes saved') + ' ');
      undo = $("<a id='undo'>" + (t('undo')) + "</a>");
      this.savedInfo.append(undo);
      this.lastState = this.currentState;
    }
    return this.currentState = this.model.toJSON();
  };

  ContactView.prototype.modelChanged = function() {
    var id, timestamp, _ref;
    this.notesfield.val(this.model.get('note'));
    if ((_ref = this.tags) != null) {
      _ref.refresh();
    }
    id = this.model.get('id');
    if (id && this.model.get('pictureRev')) {
      timestamp = Date.now();
      this.$('.picture').prop('src', "contacts/" + id + "/picture.png?" + timestamp);
    } else {
      this.$('.picture').prop('src', "img/defaultpicture.png");
    }
    return this.resizeNote();
  };

  ContactView.prototype.addBelowIfEnter = function(event) {
    var name, point, typeField, zone;
    if ((event.which || event.keyCode) !== 13) {
      return true;
    }
    zone = $(event.target).parents('.zone')[0].id;
    name = zone.substring(0, zone.length - 1);
    point = new Datapoint({
      name: name
    });
    this.model.dataPoints.add(point);
    typeField = this.zones[name].children().last().find('.type');
    typeField.focus();
    typeField.select();
    return false;
  };

  ContactView.prototype.resizeNote = function(event) {
    var loc, notes, rows;
    notes = this.notesfield.val();
    rows = loc = 0;
    while (loc = notes.indexOf("\n", loc) + 1) {
      rows++;
    }
    this.notesfield.prop('rows', rows + 2);
    return this.resizeNiceScroll();
  };

  ContactView.prototype.resizeNiceScroll = function(event) {
    return this.$el.getNiceScroll().resize();
  };

  ContactView.prototype.photoChanged = function() {
    var file, img, reader;
    file = this.uploader.files[0];
    if (!file.type.match(/image\/.*/)) {
      return alert(t('This is not an image'));
    }
    reader = new FileReader();
    img = new Image();
    reader.readAsDataURL(file);
    return reader.onloadend = (function(_this) {
      return function() {
        img.src = reader.result;
        return img.onload = function() {
          var IMAGE_DIMENSION, canvas, ctx, dataUrl, ratio, ratiodim;
          IMAGE_DIMENSION = 600;
          ratiodim = img.width > img.height ? 'height' : 'width';
          ratio = IMAGE_DIMENSION / img[ratiodim];
          canvas = document.createElement('canvas');
          canvas.height = canvas.width = IMAGE_DIMENSION;
          ctx = canvas.getContext('2d');
          ctx.drawImage(img, 0, 0, ratio * img.width, ratio * img.height);
          dataUrl = canvas.toDataURL('image/jpeg');
          _this.picture.attr('src', dataUrl);
          _this.model.photo = dataUrl.split(',')[1];
          return _this.model.savePicture();
        };
      };
    })(this);
  };

  ContactView.prototype.onTagInputKeyPress = function(event) {
    var keyCode;
    keyCode = event.keyCode || event.which;
    if (keyCode === 9) {
      if (event.shiftKey) {
        this.$('#name').focus();
      } else {
        this.$('.type:visible').first().focus();
      }
      event.preventDefault();
      return false;
    }
  };

  ContactView.prototype.onNameKeyPress = function(event) {
    var keyCode;
    keyCode = event.keyCode || event.which;
    if (keyCode === 9) {
      if (event.shiftKey) {
        this.$('textarea#notes').focus();
      } else {
        this.$('input.ui-widget-content').focus();
      }
      event.preventDefault();
      return false;
    }
  };

  ContactView.prototype.onNoteKeyPress = function(event) {
    var keyCode;
    keyCode = event.keyCode || event.which;
    if (keyCode === 9) {
      if (event.shiftKey) {
        this.$('.value:visible').last().focus();
      } else {
        this.$('#name').focus();
      }
      Event.preventDefault();
      return false;
    }
  };

  return ContactView;

})(ViewCollection);
});

;require.register("views/contact_name", function(exports, require, module) {
var BaseView, ContactName, app,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('lib/base_view');

app = require('application');

module.exports = ContactName = (function(_super) {
  __extends(ContactName, _super);

  ContactName.prototype.template = require('templates/contact_name');

  ContactName.prototype.el = '#contact-name';

  ContactName.prototype.events = {
    'keyup input': 'onKeyup',
    'blur input': 'onBlur',
    'click #toggle-name-fields': 'toggleFields',
    'click #toggle-name': 'toggleName'
  };

  function ContactName(options) {
    this.setName = __bind(this.setName, this);
    ContactName.__super__.constructor.call(this, options);
    this.contactWidget = options.contactWidget;
  }

  ContactName.prototype.afterRender = function() {
    return this.toggleFields();
  };

  ContactName.prototype.toggleFields = function() {
    var toggleButton;
    toggleButton = this.$('#toggle-name-fields');
    if (toggleButton.hasClass('icon-minus')) {
      this.showFew();
    } else {
      this.showAll();
    }
    return toggleButton.toggleClass('icon-plus icon-minus');
  };

  ContactName.prototype.showFew = function() {
    var elem, field, nameParts, value, _results;
    nameParts = _.object(['last', 'first', 'middle', 'prefix', 'suffix'], this.model.get('n'));
    _results = [];
    for (field in nameParts) {
      value = nameParts[field];
      elem = this.$('.control-group.' + field);
      if ((field === 'last' || field === 'first') || ((value != null) && value !== '')) {
        _results.push(elem.show());
      } else {
        _results.push(elem.hide());
      }
    }
    return _results;
  };

  ContactName.prototype.showAll = function() {
    var fields;
    fields = ['last', 'first', 'middle', 'prefix', 'suffix'];
    return fields.forEach((function(_this) {
      return function(field) {
        return _this.$('.control-group.' + field).show();
      };
    })(this));
  };

  ContactName.prototype.setName = function() {
    var field, nameParts, value, _results;
    nameParts = _.object(['last', 'first', 'middle', 'prefix', 'suffix'], this.model.get('n'));
    _results = [];
    for (field in nameParts) {
      value = nameParts[field];
      _results.push(this.$('input#' + field).val(value));
    }
    return _results;
  };

  ContactName.prototype.getRenderData = function() {
    return _.extend({}, this.model.attributes, {
      fn: this.model.get('fn'),
      n: this.model.get('n')
    });
  };

  ContactName.prototype.getStructuredName = function() {
    var fields;
    fields = ['last', 'first', 'middle', 'prefix', 'suffix'];
    return fields.map(function(field) {
      return $('#' + field).val();
    });
  };

  ContactName.prototype.onKeyup = function(ev) {
    return this.options.onKeyup(ev);
  };

  ContactName.prototype.onBlur = function(ev) {
    return this.options.onBlur(ev);
  };

  ContactName.prototype.toggleName = function() {
    return this.contactWidget.toggleContactName();
  };

  return ContactName;

})(BaseView);
});

;require.register("views/contactslist", function(exports, require, module) {
var App, Contact, ContactsList, ViewCollection,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

ViewCollection = require('lib/view_collection');

App = require('application');

Contact = require('models/contact');

module.exports = ContactsList = (function(_super) {
  __extends(ContactsList, _super);

  function ContactsList() {
    this.onKeyUp = __bind(this.onKeyUp, this);
    this.keyUpCallback = __bind(this.keyUpCallback, this);
    this.onContactChanged = __bind(this.onContactChanged, this);
    this.getTags = __bind(this.getTags, this);
    return ContactsList.__super__.constructor.apply(this, arguments);
  }

  ContactsList.prototype.id = 'contacts-list';

  ContactsList.prototype.itemView = require('views/contactslist_item');

  ContactsList.prototype.template = require('templates/contactslist');

  ContactsList.prototype.events = {
    'change #filterfield': 'keyUpCallback',
    'click #filterClean': 'cleanFilter',
    "keyup": "onKeyUp"
  };

  ContactsList.prototype.initialize = function() {
    ContactsList.__super__.initialize.apply(this, arguments);
    this.listenTo(this.collection, 'change', this.onContactChanged);
    this.listenTo(this.collection, 'sync', this.onContactChanged);
    return this.listenTo(this.collection, 'add', this.onContactChanged);
  };

  ContactsList.prototype.afterRender = function() {
    ContactsList.__super__.afterRender.apply(this, arguments);
    this.list = this.$('#contacts');
    this.filterfield = this.$('#filterfield');
    this.filterClean = this.$('#filterClean');
    this.filterClean.hide();
    if ($(window).width() > 900) {
      this.filterfield.focus();
    }
    this.list.niceScroll();
    this.filterfield.keyup(this.keyUpCallback);
    return this.filterfield.typeahead({
      source: this.getTags
    });
  };

  ContactsList.prototype.remove = function() {
    ContactsList.__super__.remove.apply(this, arguments);
    return this.list.getNiceScroll().remove();
  };

  ContactsList.prototype.appendView = function(view) {
    return this.list.append(view.$el);
  };

  ContactsList.prototype.activate = function(model) {
    var line, outofview, position;
    this.$('.activated').removeClass('activated');
    if (!model) {
      return;
    }
    line = this.views[model.cid].$el;
    line.addClass('activated');
    position = line.position().top;
    outofview = position < 0 || position > this.list.height();
    if (outofview) {
      this.list.scrollTop(this.list.scrollTop() + position);
    }
    return this.activatedModel = model;
  };

  ContactsList.prototype.cleanFilter = function(event) {
    var id, view, _ref, _results;
    event.preventDefault();
    this.filterfield.val('');
    this.filterClean.hide();
    _ref = this.views;
    _results = [];
    for (id in _ref) {
      view = _ref[id];
      _results.push(view.$el.show());
    }
    return _results;
  };

  ContactsList.prototype.getTags = function() {
    return this.collection.getTags();
  };

  ContactsList.prototype.onContactChanged = function(model) {
    if (model instanceof Contact) {
      this.views[model.cid].render();
      return this.activate(model);
    }
  };

  ContactsList.prototype.keyUpCallback = function(event) {
    var filtertxt, firstmodel, id, match, view, _ref;
    if (event.keyCode === 27) {
      this.filterfield.val('');
      this.filterClean.hide();
      App.router.navigate("", true);
    }
    filtertxt = this.filterfield.val();
    this.filterClean.show();
    if (!(filtertxt.length > 1 || filtertxt.length === 0)) {
      return;
    }
    this.filterClean.toggle(filtertxt.length !== 0);
    filtertxt = filtertxt.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
    this.filter = new RegExp(filtertxt, 'i');
    firstmodel = null;
    _ref = this.views;
    for (id in _ref) {
      view = _ref[id];
      match = (filtertxt === '0') || view.model.match(this.filter);
      view.$el.toggle(match);
      if (match && !firstmodel) {
        firstmodel = view.model;
      }
    }
    if (firstmodel && event.keyCode === 13) {
      return App.router.navigate("contact/" + firstmodel.id, true);
    }
  };

  ContactsList.prototype.onKeyUp = function(event) {
    var keyCode;
    if (this.activatedModel != null) {
      keyCode = event.keyCode;
      if (keyCode == null) {
        keyCode = event.which;
      }
      if (keyCode === 38) {
        this.onArrowUp(this.activatedModel);
      } else if (keyCode === 40) {
        this.onArrowDown(this.activatedModel);
      }
      event.preventDefault();
      return false;
    }
  };

  ContactsList.prototype.onArrowUp = function(contact) {
    var prevLine;
    prevLine = this.views[contact.cid].$el.prev();
    while (prevLine.length && prevLine.is(':hidden')) {
      prevLine = prevLine.prev();
    }
    if (prevLine.length) {
      return App.router.navigate(prevLine.attr('href'), true);
    }
  };

  ContactsList.prototype.onArrowDown = function(contact) {
    var nextLine;
    nextLine = this.views[contact.cid].$el.next();
    while (nextLine.length && nextLine.is(':hidden')) {
      nextLine = nextLine.next();
    }
    if (nextLine.length) {
      return App.router.navigate(nextLine.attr('href'), true);
    }
  };

  return ContactsList;

})(ViewCollection);
});

;require.register("views/contactslist_item", function(exports, require, module) {
var BaseView, ContactsListItemView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('lib/base_view');

module.exports = ContactsListItemView = (function(_super) {
  __extends(ContactsListItemView, _super);

  function ContactsListItemView() {
    return ContactsListItemView.__super__.constructor.apply(this, arguments);
  }

  ContactsListItemView.prototype.tagName = 'a';

  ContactsListItemView.prototype.className = 'contact-thumb';

  ContactsListItemView.prototype.attributes = function() {
    return {
      'href': "#contact/" + this.model.id
    };
  };

  ContactsListItemView.prototype.initialize = function() {
    return this.listenTo(this.model, 'change', this.render);
  };

  ContactsListItemView.prototype.getRenderData = function() {
    return _.extend({}, this.model.toJSON(), {
      hasPicture: !!this.model.get('pictureRev'),
      bestmail: this.model.getBest('email'),
      besttel: this.model.getBest('tel'),
      displayName: this.model.getDisplayName(),
      timestamp: Date.now()
    });
  };

  ContactsListItemView.prototype.template = require('templates/contactslist_item');

  return ContactsListItemView;

})(BaseView);
});

;require.register("views/datapoint", function(exports, require, module) {
var BaseView, DataPointView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('lib/base_view');

module.exports = DataPointView = (function(_super) {
  __extends(DataPointView, _super);

  function DataPointView() {
    this.onKeyup = __bind(this.onKeyup, this);
    this.getPossibleTypes = __bind(this.getPossibleTypes, this);
    return DataPointView.__super__.constructor.apply(this, arguments);
  }

  DataPointView.prototype.template = require('templates/datapoint');

  DataPointView.prototype.tagName = 'li';

  DataPointView.prototype.className = 'datapoint';

  DataPointView.prototype.events = function() {
    return {
      'blur .type': 'store',
      'blur .value': 'store',
      'keyup .type': 'onKeyup',
      'keyup .value': 'onKeyup',
      'keydown .value': 'onValueKeyPress',
      'keydown .type': 'onTypeKeyPress',
      'click .dpremove': 'removeModel'
    };
  };

  DataPointView.prototype.getRenderData = function() {
    return _.extend(this.model.toDisplayJSON(), {
      placeholder: this.getPlaceHolder()
    });
  };

  DataPointView.prototype.afterRender = function() {
    this.valuefield = this.$('.value');
    this.typefield = this.$('input.type');
    this.actionLink = this.$('.dpaction');
    this.typefield.typeahead({
      source: this.getPossibleTypes
    });
    return this.makeActionLink();
  };

  DataPointView.prototype.getPossibleTypes = function() {
    switch (this.model.get('name')) {
      case 'about':
        return ['org', 'birthday', 'title'];
      case 'other':
        return ['skype', 'jabber', 'irc'];
      case 'url':
        return ['facebook', 'google', 'website'];
      default:
        return ['main', 'home', 'work', 'assistant'];
    }
  };

  DataPointView.prototype.getPlaceHolder = function() {
    switch (this.model.get('name')) {
      case 'email':
        return 'john.smith@example.com';
      case 'adr':
        return '42 main street ...';
      case 'tel':
        return '+33 1 23 45 67 89';
      case 'url':
        return 'http://example.com/john-smith';
      case 'about':
      case 'other':
        return t('type here');
    }
  };

  DataPointView.prototype.makeActionLink = function() {
    var action, href, value;
    action = (function(_this) {
      return function(icon, title, href, noblank) {
        if (!_this.actionLink.parent()) {
          _this.$el.append(_this.actionLink);
        }
        _this.actionLink.attr({
          title: title,
          href: href
        });
        if (noblank) {
          _this.actionLink.removeAttr('target');
        } else {
          _this.actionLink.attr('target', '_blank');
        }
        return _this.actionLink.find('i').addClass('fa-' + icon);
      };
    })(this);
    value = this.model.get('value');
    switch (this.model.get('name')) {
      case 'email':
        return action('envelope-o', 'send mail', "mailto:" + value, true);
      case 'tel':
        href = this.callProtocol() + ':+' + value;
        return action('phone', 'call', href, true);
      case 'url':
        return action('link', 'go to this url', "" + value, false);
      case 'other':
        if (this.model.get('type') === 'skype') {
          return action('skype', 'call', "callto:" + value);
        }
        break;
      default:
        return this.actionLink.detach();
    }
  };

  DataPointView.prototype.callProtocol = function() {
    if (navigator.userAgent.match(/(mobile)/gi)) {
      return 'tel';
    } else {
      return 'callto';
    }
  };

  DataPointView.prototype.onKeyup = function(event) {
    var backspace, empty;
    empty = $(event.target).val().length === 0;
    backspace = (event.which || event.keyCode) === 8;
    if (!backspace) {
      this.secondBack = false;
      return true;
    }
    if (!empty) {
      return true;
    }
    if (this.secondBack) {
      return (function(_this) {
        return function() {
          var prev;
          prev = _this.$el.prev('li').find('.value');
          _this.removeModel();
          if (prev) {
            return prev.focus().select();
          }
        };
      })(this);
    } else {
      return this.secondBack = true;
    }
  };

  DataPointView.prototype.removeModel = function() {
    return this.model.collection.remove(this.model);
  };

  DataPointView.prototype.store = function() {
    return this.model.setTypeNValue(this.typefield.val(), this.valuefield.val());
  };

  DataPointView.prototype.onTypeKeyPress = function(event) {
    var keyCode, prev;
    keyCode = event.keyCode;
    if (keyCode == null) {
      keyCode = event.which;
    }
    if (keyCode === 9) {
      if (event.shiftKey) {
        prev = this.$el.prev();
        if (prev.length === 0) {
          prev = this.$el.parent().parent();
          prev = prev.prev();
          while (!prev.is(':visible') && prev.length > 0) {
            prev = prev.prev();
          }
          if (prev.length === 0) {
            prev = $(".ui-widget-content");
          } else {
            prev = prev.find('.value');
          }
        } else {
          prev = prev.find('.value');
        }
        prev.focus();
        prev.select();
      } else {
        $(event.target).next().focus();
      }
      event.preventDefault();
      return false;
    } else {
      return true;
    }
  };

  DataPointView.prototype.onValueKeyPress = function(event) {
    var keyCode, next;
    keyCode = event.keyCode;
    if (keyCode == null) {
      keyCode = event.which;
    }
    if (keyCode === 9) {
      if (event.shiftKey) {
        $(event.target).prev().focus();
      } else {
        next = this.$el.next();
        if (next.length === 0) {
          next = this.$el.parent().parent();
          next = next.next();
          while (!next.is(':visible') && (next.attr('id') != null)) {
            next = next.next();
          }
          if (next.attr('id') == null) {
            next = $("textarea#notes");
          } else {
            next = next.find('.type');
          }
        } else {
          next = next.find('.type');
        }
        next.focus();
        next.select();
      }
      event.preventDefault();
      return false;
    } else {
      return true;
    }
  };

  return DataPointView;

})(BaseView);
});

;require.register("views/doc", function(exports, require, module) {
var BaseView, DocView,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

BaseView = require('lib/base_view');

module.exports = DocView = (function(_super) {
  __extends(DocView, _super);

  function DocView() {
    return DocView.__super__.constructor.apply(this, arguments);
  }

  DocView.prototype.id = 'doc';

  DocView.prototype.template = require('templates/doc');

  DocView.prototype.events = {
    'change #nameFormat': 'saveNameFormat',
    'click #show-password': 'showPassword',
    'click #hide-password': 'hidePassword'
  };

  DocView.prototype.getRenderData = function() {
    return {
      account: this.model
    };
  };

  DocView.prototype.initialize = function() {
    this.model = window.webDavAccount;
    if (this.model != null) {
      return this.model.placeholder = this.getPlaceholder(this.model.token);
    }
  };

  DocView.prototype.afterRender = function() {
    if (app.config.get('nameOrder') !== 'not-set') {
      return this.$('#nameFormat').val(app.config.get('nameOrder'));
    }
  };

  DocView.prototype.saveNameFormat = function() {
    var help;
    help = this.$('.help-inline').show().text(t('saving'));
    return app.config.save({
      nameOrder: this.$('#nameFormat').val()
    }, {
      wait: true,
      success: function() {
        help.text(t('saved')).fadeOut();
        return window.location.reload();
      },
      error: function() {
        return help.addClass('error').text(t('server error occured'));
      }
    });
  };

  DocView.prototype.getPlaceholder = function(password) {
    var i, placeholder, _i, _ref;
    placeholder = [];
    for (i = _i = 1, _ref = password.length; _i <= _ref; i = _i += 1) {
      placeholder.push('*');
    }
    return placeholder.join('');
  };

  DocView.prototype.showPassword = function() {
    this.$('#placeholder').html(this.model.token);
    this.$('#show-password').hide();
    return this.$('#hide-password').show();
  };

  DocView.prototype.hidePassword = function() {
    this.$('#placeholder').html(this.model.placeholder);
    this.$('#hide-password').hide();
    return this.$('#show-password').show();
  };

  return DocView;

})(BaseView);
});

;require.register("views/importer", function(exports, require, module) {
var BaseView, Contact, ImporterView, app,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseView = require('lib/base_view');

Contact = require('models/contact');

app = require('application');

module.exports = ImporterView = (function(_super) {
  __extends(ImporterView, _super);

  function ImporterView() {
    return ImporterView.__super__.constructor.apply(this, arguments);
  }

  ImporterView.prototype.template = require('templates/importer');

  ImporterView.prototype.id = 'importer';

  ImporterView.prototype.tagName = 'div';

  ImporterView.prototype.className = 'modal';

  ImporterView.prototype.events = function() {
    return {
      'change #vcfupload': 'onupload',
      'click  #confirm-btn': 'addcontacts'
    };
  };

  ImporterView.prototype.afterRender = function() {
    this.$el.modal();
    this.upload = this.$('#vcfupload')[0];
    this.content = this.$('.modal-body');
    return this.confirmBtn = this.$('#confirm-btn');
  };

  ImporterView.prototype.onupload = function() {
    var file, reader, validMimeTypes, _ref;
    $(".loading").show();
    file = this.upload.files[0];
    validMimeTypes = ['text/vcard', 'text/x-vcard', 'text/directory', 'text/directory;profile=vcard'];
    if (_ref = file.type.toLowerCase(), __indexOf.call(validMimeTypes, _ref) < 0) {
      this.$('.control-group').addClass('error');
      this.$('.help-inline').text(t('is not a vCard'));
      return;
    }
    reader = new FileReader();
    reader.readAsText(file);
    return reader.onloadend = (function(_this) {
      return function() {
        var txt;
        _this.toImport = Contact.fromVCF(reader.result);
        txt = t('import.ready-msg', {
          smart_count: _this.toImport
        });
        txt = "<p>" + txt + " :</p><ul>";
        _this.toImport.each(function(contact) {
          var name;
          name = contact.get('fn') || contact.getComputedFN();
          if ((name == null) || name.trim() === '') {
            name = contact.getBest('email');
          }
          if ((name == null) || name.trim() === '') {
            name = contact.getBest('tel');
          }
          return txt += "<li>" + name + "</li>";
        });
        txt += '</ul>';
        _this.content.html(txt);
        return _this.confirmBtn.removeClass('disabled');
      };
    })(this);
  };

  ImporterView.prototype.updateProgress = function(number, total) {
    return this.$(".import-progress").html(" " + number + " / " + total);
  };

  ImporterView.prototype.addcontacts = function() {
    var importContact, total;
    if (!this.toImport) {
      return true;
    }
    this.content.html("<p>" + (t('dont close navigator import')) + "</p>\n<p>\n    " + (t('import progress')) + ":&nbsp;<span class=\"import-progress\"></span>\n</p>\n<p class=\"errors\">\n</p>");
    total = this.toImport.length;
    this.importing = true;
    this.updateProgress(0, total);
    return (importContact = (function(_this) {
      return function() {
        var contact;
        if (_this.toImport.length === 0) {
          alert(t('import succeeded'));
          _this.importing = false;
          return _this.close();
        } else {
          contact = _this.toImport.pop();
          contact.set('import', true);
          return contact.save(null, {
            success: function() {
              _this.updateProgress(total - _this.toImport.size(), total);
              app.contacts.add(contact);
              contact.savePicture();
              return importContact();
            },
            error: function() {
              $(".errors").append("<p>" + (t('fail to import')) + ": " + (contact.getComputedFN()) + "</p>");
              return importContact();
            }
          });
        }
      };
    })(this))();
  };

  ImporterView.prototype.close = function() {
    if (!this.importing) {
      this.$el.modal('hide');
      this.remove();
      return app.router.navigate('#help', {
        trigger: true
      });
    }
  };

  return ImporterView;

})(BaseView);
});

;require.register("widgets/autocomplete", function(exports, require, module) {
var ARROW_DOWN_KEY, ARROW_UP_KEY, Autocomplete, BaseView, ENTER_KEY, ESCAPE_KEY,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseView = require('../lib/base_view');

ENTER_KEY = 13;

ARROW_UP_KEY = 38;

ARROW_DOWN_KEY = 40;

ESCAPE_KEY = 27;

module.exports = Autocomplete = (function(_super) {
  __extends(Autocomplete, _super);

  function Autocomplete() {
    this.unbind = __bind(this.unbind, this);
    this.delayedUnbind = __bind(this.delayedUnbind, this);
    this.onInputKeyDown = __bind(this.onInputKeyDown, this);
    return Autocomplete.__super__.constructor.apply(this, arguments);
  }

  Autocomplete.prototype.className = 'autocomplete';

  Autocomplete.prototype.tagName = 'ul';

  Autocomplete.prototype.events = function() {
    return {
      'click li': 'onClick'
    };
  };

  Autocomplete.prototype.onInputKeyDown = function(e) {
    var delta, _ref;
    if ((_ref = e.keyCode) === ARROW_UP_KEY || _ref === ARROW_DOWN_KEY) {
      delta = e.keyCode - 39;
      this.select(this.selectedIndex + delta);
      e.preventDefault();
      e.stopPropagation();
    }
    if (e.keyCode === ESCAPE_KEY) {
      return this.unbind();
    }
  };

  Autocomplete.prototype.onClick = function(e) {
    var event;
    this.input.val(e.target.dataset.value);
    event = $.Event('keydown');
    event.keyCode = ENTER_KEY;
    this.input.trigger(event);
    e.preventDefault();
    e.stopPropagation();
    this.unbindCancel = true;
    this.input.parents('.folder-row').addClass('pseudohover');
    return this.input.focus();
  };

  Autocomplete.prototype.initialize = function(options) {
    if (options == null) {
      options = {};
    }
    this.limit = options.limit || 10;
    if (window.tags == null) {
      window.tags = [];
    }
    return this.tags = window.tags.map(function(value, idx) {
      var el, lc;
      el = document.createElement('li');
      el.textContent = value;
      el.dataset.value = value;
      el.dataset.index = idx;
      lc = value.toLowerCase();
      return {
        value: value,
        el: el,
        lc: lc
      };
    });
  };

  Autocomplete.prototype.position = function() {
    var pos;
    pos = this.input.offset();
    pos.top += this.input.outerHeight() - 1;
    pos.width = this.input.width();
    return this.$el.appendTo($('body')).css(pos).show();
  };

  Autocomplete.prototype.refresh = function(search, existings) {
    var selected, tag, _i, _len, _ref, _ref1;
    search = this.input.val();
    selected = (_ref = this.visible) != null ? _ref[this.selectedIndex] : void 0;
    if (existings == null) {
      existings = [];
    }
    _ref1 = this.tags;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      tag = _ref1[_i];
      tag.el.classList.remove('selected');
    }
    this.visible = this.tags.filter((function(_this) {
      return function(tag, index) {
        var _ref2;
        return (_ref2 = tag.value, __indexOf.call(existings, _ref2) < 0) && (tag.lc != null) && ~tag.lc.indexOf(search.toLowerCase()) && index < _this.limit;
      };
    })(this));
    if (selected && __indexOf.call(this.visible, selected) >= 0) {
      this.selectedIndex = this.visible.indexOf(selected);
    } else {
      this.selectedIndex = -1;
    }
    this.$el.empty().append(_.pluck(this.visible, 'el'));
    return this.$el.toggleClass('empty', this.visible.length === 0);
  };

  Autocomplete.prototype.select = function(index) {
    var tag, visibleElement, _i, _len, _ref;
    _ref = this.tags;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tag = _ref[_i];
      tag.el.classList.remove('selected');
    }
    index = (index + this.visible.length) % this.visible.length;
    this.selectedIndex = index;
    visibleElement = this.visible[this.selectedIndex];
    if (visibleElement != null) {
      visibleElement.el.classList.add('selected');
      return this.input.val(visibleElement.value);
    }
  };

  Autocomplete.prototype.bind = function($target) {
    if ($target === this.$target) {
      return;
    }
    if (this.$target) {
      this.unbind();
    }
    this.$target = $target;
    this.input = this.$target.find('input');
    this.position();
    this.input.on('keydown', this.onInputKeyDown);
    this.input.on('blur', this.delayedUnbind);
    return this.selectedIndex = -1;
  };

  Autocomplete.prototype.delayedUnbind = function() {
    this.unbindCancel = false;
    if (this.delayedUnbindTimeout) {
      clearTimeout(this.delayedUnbindTimeout);
    }
    return this.delayedUnbindTimeout = setTimeout(this.unbind, 100);
  };

  Autocomplete.prototype.unbind = function() {
    if (this.unbindCancel || !this.input) {
      return;
    }
    this.input.off('keydown', this.onInputKeyDown);
    this.input.off('blur', this.delayedUnbind);
    this.input.parents('.folder-row').removeClass('pseudohover');
    this.input.val('');
    this.$target = null;
    this.$el.hide();
    this.$el.detach();
    return this.selectedIndex = -1;
  };

  return Autocomplete;

})(BaseView);
});

;require.register("widgets/tags", function(exports, require, module) {
var Autocomplete, BaseView, TagsView,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

BaseView = require('../lib/base_view');

Autocomplete = require('./autocomplete');

module.exports = TagsView = (function(_super) {
  __extends(TagsView, _super);

  function TagsView() {
    this.hideInput = __bind(this.hideInput, this);
    this.toggleInput = __bind(this.toggleInput, this);
    this.refresh = __bind(this.refresh, this);
    this.deleteTag = __bind(this.deleteTag, this);
    this.setTags = __bind(this.setTags, this);
    this.tagClicked = __bind(this.tagClicked, this);
    this.refreshAutocomplete = __bind(this.refreshAutocomplete, this);
    this.onKeyDown = __bind(this.onKeyDown, this);
    return TagsView.__super__.constructor.apply(this, arguments);
  }

  TagsView.prototype.events = function() {
    return {
      'click .tag': 'tagClicked',
      'click .tag .deleter': 'deleteTag',
      'focus input': 'onFocus',
      'keydown input': 'onKeyDown',
      'keyup input': 'refreshAutocomplete'
    };
  };

  TagsView.prototype.template = function() {
    return "<input type=\"text\" placeholder=\"" + (t('add tags')) + "\">";
  };

  TagsView.prototype.initialize = function(options) {
    this.options = options;
    this.refresh();
    return this.listenTo(this.model, 'change:tags', (function(_this) {
      return function() {
        return _this.refresh();
      };
    })(this));
  };

  TagsView.prototype.onFocus = function(e) {
    TagsView.autocomplete.bind(this.$el);
    TagsView.autocomplete.refresh('', this.tags);
    if (this.input.val() === '') {
      return TagsView.autocomplete.$el.hide();
    } else {
      return TagsView.autocomplete.$el.show();
    }
  };

  TagsView.prototype.onKeyDown = function(e) {
    var val, _ref, _ref1, _ref2;
    val = this.input.val();
    if (val === '' && e.keyCode === 8) {
      this.setTags(this.tags.slice(0, -1));
      TagsView.autocomplete.refresh('', this.tags);
      TagsView.autocomplete.position();
      e.preventDefault();
      e.stopPropagation();
      return;
    }
    if (val && ((_ref = e.keyCode) === 188 || _ref === 32 || _ref === 9 || _ref === 13)) {
      if (this.tags == null) {
        this.tags = [];
      }
      if (__indexOf.call(this.tags, val) < 0) {
        this.tags.push(val);
      }
      this.setTags(this.tags);
      this.input.val('');
      TagsView.autocomplete.refresh('', this.tags);
      TagsView.autocomplete.position();
      e.preventDefault();
      e.stopPropagation();
      return;
    }
    if ((_ref1 = e.keyCode) === 188 || _ref1 === 32 || _ref1 === 9 || _ref1 === 13) {
      e.preventDefault();
      e.stopPropagation();
      return;
    }
    if ((_ref2 = e.keyCode) === 40 || _ref2 === 38) {
      return true;
    }
    if (val && e.keyCode !== 8) {
      this.refreshAutocomplete();
      return true;
    }
  };

  TagsView.prototype.refreshAutocomplete = function(e) {
    var _ref;
    if (this.input.val() !== '') {
      TagsView.autocomplete.$el.show();
    }
    if ((_ref = e != null ? e.keyCode : void 0) === 40 || _ref === 38 || _ref === 8) {
      return;
    }
    return TagsView.autocomplete.refresh(this.input.val(), this.tags);
  };

  TagsView.prototype.tagClicked = function(e) {
    var tag;
    tag = e.target.dataset.value;
    return this.trigger('tagClicked', tag);
  };

  TagsView.prototype.setTags = function(newTags) {
    this.tags = newTags;
    if (this.tags == null) {
      this.tags = [];
    }
    this.model.attributes.tags = newTags;
    if (this.options.onBlur != null) {
      return this.options.onBlur();
    } else {
      return this.model.save({
        tags: this.tags
      });
    }
  };

  TagsView.prototype.deleteTag = function(e) {
    var tag;
    tag = e.target.parentNode.dataset.value;
    this.setTags(_.without(this.tags, tag));
    e.stopPropagation();
    return e.preventDefault();
  };

  TagsView.prototype.afterRender = function() {
    this.refresh();
    return this.input = this.$('input');
  };

  TagsView.prototype.refresh = function() {
    var html, tag;
    this.tags = _.clone(this.model.get('tags'));
    this.$('.tag').remove();
    html = ((function() {
      var _i, _len, _ref, _results;
      _ref = this.model.getTags() || [];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        tag = _ref[_i];
        _results.push("<li class=\"tag\" data-value=\"" + (tag.get('name')) + "\" style=\"background: " + (tag.get('color')) + ";\">\n    " + (tag.get('name')) + "\n    <span class=\"deleter fa fa-remove\"/>\n</li>");
      }
      return _results;
    }).call(this)).join('');
    return this.$el.prepend(html);
  };

  TagsView.prototype.toggleInput = function() {
    this.$('input').toggle();
    if (this.$('input').is(':visible')) {
      return this.$('input').focus();
    }
  };

  TagsView.prototype.hideInput = function() {
    return this.$('input').hide();
  };

  return TagsView;

})(BaseView);

TagsView.autocomplete = new Autocomplete({
  id: 'tagsAutocomplete'
});

TagsView.autocomplete.render();
});

;
//# sourceMappingURL=app.js.map