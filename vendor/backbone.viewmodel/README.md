# Backbone.ViewModel

Backbone.ViewModel is a library of ViewModel for Backbone. It extends Backbone.Model to provides a ViewModel implementation for Backbone apps.

A ViewModel is a layer that takes place between your View and its Model or Collection. It provides a transparent API to access the Model/Collection data without exposing it directly to the View. It also provides a simple way to stores your View state.

A state describes a view by its current properties whose aren't data, but only an abstract representation of the View at a given time. Say you want to describes a Dialog View state, which contains a description of an item. The Dialog View needs to access the item's data Model ; but it also needs to know if the Dialog box is currently visible or not. This `visibility` state is a property taht do not rely on the item Data (it's specific to the Dialog View), but should not be contained in the View itself. The ViewModel handles it for you.

The ViewModel also provides a way to decorate data Model properties. When your View needs to transform the Model data, it should not do it by itself, but relies on an intermediate layer that decorates this data for the View. Backbone.ViewModel provides a way to declares decorators that auto-updates each times the underlying data changes.

Backbone.ViewModel also takes care of Backbone.Events model by triggering events and proxying Model events to the View.


## Why?

Backbone provides a lean way to develop MV* apps. It mainly provides Model structure. The Views are even simpler (remember that, by defaults `Backbone.View.render` method does nothing than returning the View itself). You can then use the pattern you want to develop your Backbone-based application.

Among all available patterns exists the Model-View-ViewModel pattern (see a [clean description of MVVM by Addy Osmani](http://addyosmani.com/blog/understanding-mvvm-a-guide-for-javascript-developers/)). It often rely on `data-binding`, and many libs, such as [Epoxy.js](http://epoxyjs.org/index.html), provides this kind of implementation. Unfortunately, if it provides a good way for data decorators, it doesn't simply offer a way to handle View states.

In MVVM philosophy, like in Model-View-Presenter pattern, the View should not do anything by itself. It must only consumes the data offered to it, and send-back events when something (i.e. User interaction) occurs. React to this events isn't View responsibility. So your View should be completely agnostic: it consumes data, render itself partially or completely when changes occurs, and send-back events to notify when something happens on it. That's all. Note that the View doesn't stores its state: it only renders when some of its state's properties change.

So why adding an additional layer of code? Because of code strength and tests! If you View doesn't do anything by itself but rendering, then you can freely replace it by another implementation when you need without rewriting logics. In same manner, you'll want probably test intensively the ViewModel, to be sure it stays consistent when changes occurs (in underlying model or when view's events are catched) but you can be more laxist on Ui tests, because your View is probably just a DOM representation of your state-machine at a given time.


## Install

As long as the library exposes a new Backbone component in the Backbone namespace, you can load Backbone.ViewModel as a main module, then use it simply with:

```js
var ViewModel = require('backbone.viewmodel');

var DialogViewModel = ViewModel.extend({
  /* Your ViewModel logics here… */
});
```

or, if you use globals directly:

```js
var DialogViewModel = Backbone.ViewModel.extend({
  /* Your ViewModel logics here… */
})
```


## Use

Remember that a ViewModel is simply a Backbone.Model by itself that extends specific behaviors to handle the state-machine, sync and decorators patterns. All that you know about Backbone.Models applies to Backbone.ViewModel.


### Instanciate

When you need a view model, you probably need it handles a data Model for your View (and not only stores your View state). In this case, simply pass a `model` attribute that points to your data Model when creating a new ViewModel, then use the `ViewModel` as, well… the View's model:

```js
var DataModel       = Backbone.Model.extend({});
var DialogViewModel = Backbone.ViewModel.extend({});
var DialogView      = Backbone.View.extend({});

var model      = new DataModel();
var viewModel  = new ViewModel({model: model});
var dialogView = new DialogView({model: viewModel});
```

Then access the ViewModel like you do with classic Backbone models.


### State-machine

The state are simple model properties that can be set as you want, and on which changes the associated view can react. Simply use the `ViewModel.set` method like with your Backbone models.


### Decorators

When you want to decorate some data properties, you can use the `map` attribute to declares the properties you want to _map_ to the underlying data model. It relies on 3 parts:

First, use the `map` ViewModel's attribute to declares the property and on which data properties it relies:
```js
var DialogViewModel = Backbone.ViewModel.extend({
  map: {
    initials: 'name firstname'
  }
})
```

Second, creates a method named `getMapped<MyMappedPropertyName>` that decorates the data, and takes the model properties as arguments:
```js
var DialogViewModel = Backbone.ViewModel.extend({
  map: {
    initials: 'name firstname'
  },

  getMappedInitials: function (name, firstname) {
    return name.slice(0) + firstname.slice(0);
  }
})
```

Then, optionally, you can declares a `saveMapped<MyMappedPropertyName>` that returns an object that updates the underlying model using its `set` method when the mapped attribute is set:
```js
var DialogViewModel = Backbone.ViewModel.extend({
  map: {
    initials: 'name firstname'
  },

  getMappedInitials: function (name, firstname) {
    return name[0] + firstname[0];
  },

  saveMappedInitials: function () {
    initials           = _.clone(this.get('initials'))
    attrs              = {}

    attrs['name']      = initials[0] + this.model.get('name').slice(1)
    attrs['firstname'] = initials[1] + this.model.get('firstname').slice(1)

    return attrs
  }
})
```

The `getMapped` et `saveMapped` acts as getters/setters for the mapped attributes and their underlying values. The ViewModel also subscribe them to the model changes, so each times a underlying model concerned property changes, the mapped attributes that depends on it are updated.


### Sync

The ViewModel can handle a temporary unsynced state: when you set a data property through the ViewModel, it isn't immediately transfered to the underlying model. Instead, the ViewModel staores this temporary changes and wait for later save action to resync with the model.

This way, you can trash the changes at any time by calling the `ViewModel.reset` method. When you call the `ViewModel.save` method (as you do with classic Backbone.Model), the temporary changed properties are synchronized on the underlying model, then this last is saved itself onto the server (like a regular `save` trigger).

It's particularly useful when dealing with forms where you want you User's input saved (in the view-state) but not synced (to the server) unless the user finally submit the form.


### Persistence

By default, the `sync` Backbone.Model method is disabled on the ViewModel, as long as you'll probably doesn't want to sync your view's state. If you need, or want, to persist your view state (e.g. to restore a form user's inputs if the page accidentally reload, and then preserves its progression), then feel free to implement your own ViewModel persistence way by overriding the `Backbone.ViewModel.sync` method (e.g. by syncing its properties state locally in localStorage or IndexedDB).


### React to View Events

In our MVVM approch, view does nothing but passing event when user interacts on it. It means that your view shouldn't embed any logic, but instead delegates it to another instance, like the ViewModel.

An easy way is to declares `viewEvents` in the ViewModel and bind them when the View initialize. If you use a Backbone framework like Marionette, it probably provides a simple way to do this, like:

```js
var DialogViewModel = Backbone.ViewModel.extend({
  viewEvents: {
    'form:submit': function () { this.save(null); },
    'form:cancel': 'reset'
  }
});

var DialogView = Backbone.View.extend({
  initialize: function () {
    Marionette.bindEntityEvents(this.model, this, this.model.viewEvents);
  }
});
```

_NOTE_: we're currently looking for a good way to automate this, but it'll probably need to hack the Backbone.View construction itself.


## Todo and Ideas

- Automatically bind `viewEvents` in model to its view events when the view is constructed with this ViewModel
- Support a `conflict<:property>` event that can be triggered when the underlying model is updated, but the ViewModel contains changes applied to this properties that aren't already synced. It may triggers an events containing each 3 values (old-model-value, new-model-value, view-model-value), and let the user decides what to do but apply a default action.
