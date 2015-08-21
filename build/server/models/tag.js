// Generated by CoffeeScript 1.9.0
var Tag, cozydb, log,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __hasProp = {}.hasOwnProperty;

cozydb = require('cozydb');

log = require('printit')({
  prefix: 'tag:model'
});

module.exports = Tag = (function(_super) {
  __extends(Tag, _super);

  function Tag() {
    return Tag.__super__.constructor.apply(this, arguments);
  }

  Tag.schema = {
    name: {
      type: String
    },
    color: {
      type: String
    }
  };

  return Tag;

})(cozydb.CozyModel);

Tag.all = function(callback) {
  return Tag.request('byName', callback);
};

Tag.byName = function(name, callback) {
  return Tag.request('byName', {
    key: name
  }, callback);
};

Tag.getOrCreate = function(data, callback) {
  return Tag.byName(data.name, function(err, tags) {
    if (err) {
      log.error(err);
      return Tag.create(data, callback);
    } else if (tags.length === 0) {
      return Tag.create(data, callback);
    } else {
      return callback(null, tags[0]);
    }
  });
};
