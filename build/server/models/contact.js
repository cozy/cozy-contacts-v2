// Generated by CoffeeScript 1.8.0
var Contact, ContactLog, VCardParser, americano, async, fs, log;

americano = require('americano-cozy');

async = require('async');

ContactLog = require('./contact_log');

VCardParser = require('cozy-vcard');

fs = require('fs');

log = require('printit')({
  prefix: 'Contact Model'
});

module.exports = Contact = americano.getModel('Contact', {
  id: String,
  fn: String,
  n: String,
  datapoints: function(x) {
    return x;
  },
  note: String,
  tags: function(x) {
    return x;
  },
  _attachments: Object
});

Contact.afterInitialize = function() {
  if ((this.n == null) || this.n === '') {
    if (this.fn == null) {
      this.fn = '';
    }
    this.n = this.getComputedN();
  } else if ((this.fn == null) || this.fn === '') {
    this.fn = this.getComputedFN();
  }
  return this;
};

Contact.prototype.remoteKeys = function() {
  var dp, model, out, _i, _len, _ref, _ref1;
  model = this.toJSON();
  out = [this.id];
  _ref = model.datapoints;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    dp = _ref[_i];
    if (dp.name === 'tel') {
      out.push(ContactLog.normalizeNumber(dp.value));
    } else if (dp.name === 'email') {
      out.push((_ref1 = dp.value) != null ? _ref1.toLowerCase() : void 0);
    }
  }
  return out;
};

Contact.prototype.savePicture = function(path, callback) {
  var data;
  data = {
    name: 'picture'
  };
  log.debug(path);
  return this.attachFile(path, data, function(err) {
    if (err) {
      return callback(err);
    } else {
      return fs.unlink(path, function(err) {
        if (err) {
          log.error("failed to purge " + file.path);
        }
        return callback();
      });
    }
  });
};

Contact.prototype.getComputedFN = function() {
  return VCardParser.nToFN(this.n.split(';'));
};

Contact.prototype.getComputedN = function() {
  return VCardParser.fnToN(this.fn).join(';');
};

Contact.prototype.toVCF = function(callback) {
  var buffers, stream, _ref;
  if (((_ref = this._attachments) != null ? _ref.picture : void 0) != null) {
    stream = this.getFile('picture', function() {});
    buffers = [];
    stream.on('data', buffers.push.bind(buffers));
    return stream.on('end', (function(_this) {
      return function() {
        var picture;
        picture = Buffer.concat(buffers).toString('base64');
        return callback(null, VCardParser.toVCF(_this, picture));
      };
    })(this));
  } else {
    return callback(null, VCardParser.toVCF(this));
  }
};

Contact.prototype.migrateAdr = function(callback) {
  var hasMigrate, _ref;
  hasMigrate = false;
  if (typeof this !== "undefined" && this !== null) {
    if ((_ref = this.datapoints) != null) {
      _ref.forEach(function(dp) {
        if (dp.name === 'adr') {
          if (typeof dp.value === 'string' || dp.value instanceof String) {
            dp.value = VCardParser.adrStringToArray(dp.value);
            return hasMigrate = true;
          }
        }
      });
    }
  }
  if (hasMigrate) {
    return this.updateAttributes({}, callback);
  } else {
    return callback();
  }
};

Contact.migrateAll = function(callback) {
  return Contact.all({}, function(err, contacts) {
    if (err != null) {
      console.log(err);
      return callback();
    } else {
      return async.eachLimit(contacts, 10, function(contact, done) {
        return contact.migrateAdr(done);
      }, callback);
    }
  });
};
