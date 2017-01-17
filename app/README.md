# Cozy-Contacts front app

This frontend application serves the cozy-contacts browser app. It relies on the server `views/index.jade` for its base markup and exported globales, which are relocated in the `imports` module (use `require('imports')` to get them).


## Requirements

You'll need a valid node.js/npm environment to develop the app. We use [Brunch](http://brunch.io/) as build tool and [bower](http://bower.io/) for the dependencies so you want them installed on your system:

```sh
$ npm -g i brunch bower
```

Before trying to develop the front app, you need to load its dependencies:

```sh
npm i
bower install
```

_NOTE:_ we currently use Bower as deps manager to avoid deps in the app repository. We'll replace it by npm node_modules packages when Brunch will be stable enough to use it for the vendor files.


## Librairies

You should be aware of the app libraries in use:
* [Backbone](http://backbonejs.org/) is used for a quick and valid components architecture, like models
* [Marionette](http://marionettejs.com/) is the framework used upon Backbone to have a more clever and easier way to deal with views (like layouts, regions, and views switching)
* [BackboneProjections](https://github.com/andreypopp/backbone.projections) offers a lean way to keep context collections (like search filtering, etc) consistent over the whole app
* [Backbone.ViewModel](https://github.com/cozy-labs/backbone.viewmodel) keeps logics externally to views rendering part, and gets contextual stores
* [cozy-vcard](https://github.com/cozy/cozy-vcard) is a cozy tailored lib to deal with vcard format parsing and generation


## Architecture

### Files structure

The app is organized in the following way:

```txt
app
├── assets                    # App static assets (like fonts from cozy-proxy)
├── collections               # Collections. Can be root-ones (like contacts
│   ├── charindex.coffee      # and tags) or projections over the last.
│   ├── contacts.coffee
│   ├── duplicates.coffee
│   ├── search.coffee
│   └── tags.coffee
├── lib
│   ├── behaviors                 # Behaviors are chunks of code used in
│   │   ├── confirm.coffee        # composition for marionette Views.
│   │   ├── dialog.coffee         # (NOTE: the behaviors are not specifics to
│   │   ├── dropdown.coffee       # contacts and will be moved to cozy-ui soon)
│   │   ├── form.coffee
│   │   ├── index.coffee
│   │   ├── keyboard.coffee
│   │   ├── navigator.coffee
│   │   └── pickavatar.coffee
│   ├── regions                   # Regions extra-app top-classes
│   │   └── dialogs.coffee
│   ├── views                     # Views extra-app templates and top-classes
│   │   ├── templates
│   │   │   ├── base
│   │   │   │   ├── alert.jade
│   │   │   │   └── dialog.jade
│   │   │   └── confirm.jade
│   │   └── confirm.coffee
│   ├── contacts_listener.coffee  # Listener are client-side realtime adapter
│   ├── i18n.coffee               # Localization abstraction tool
│   └── tags_listener.coffee
├── locales
├── models                        # Root data models
│   ├── config.coffee
│   ├── contact.coffee
│   └── tag.coffee
├── routes                        # Default routes and subroutes
│   ├── contacts.coffee
│   ├── index.coffee
│   └── tags.coffee
├── styles
│   ├── app                       # App related styles and layouts
│   ├── base                      # Base styles using Cozy-ui as fondation
│   ├── components                # Each components can use its own style
│   └── main.styl
├── views                         # Views components, including templates
│   ├── contacts                  # and models logics.
│   ├── duplicates                # Each "top-component" (contacts, labels, etc)
│   ├── labels                    # as its dedicated group.
│   ├── models                    # Models are inherited from Backbone.ViewModel
│   │   ├── app.coffee            # and contains internal conponents stores and
│   │   ├── contact.coffee        # logics. They can be shared across components
│   │   ├── group.coffee          # (such as AppViewModel).
│   │   └── merge.coffee
│   ├── settings
│   ├── templates                 # Templates use Jade as templating engine,
│   │   ├── contacts              # and reflect views components dir structure.
│   │   │   └── components
│   │   ├── duplicates
│   │   ├── labels
│   │   ├── layouts
│   │   ├── settings
│   │   └── tools
│   ├── tools
│   └── app_layout.coffee         # App layout childView switching part
├── application.coffee            # Application boostraping
├── config.coffee                 # Const config
└── initialize.coffee             # Env initialization
```

### App workflow

So, what happens when you request an URL in the front app ? Here is the step-by-step workflow:

1. Environment is initialized (`initialize.coffee`):
  - sets a color palette use in the app
  - register behaviors for the app
  - bind localization tool ([Polyglot](http://airbnb.io/polyglot.js/)) to the browser context
  - starts app
2. Initialize the app (`application.coffee`)
  - initialize the AppViewModel from the config model
  - prepare the collections (roots and search projection) and app layout
  - starts the router
3. Then, when application is ready (`application.coffee`), it complete the following tasks:
  - fetch _contacts_ and _tags_ from the server
  - render the layout
  - start the history stack
4. Router (`routes/index`)starts in parallel and match the path to the relevant subroute. Note that frequenly, routes ensure the collections are properly fetched before dealing with actions.
5. Layout (`views/app_layout.coffee`) renders, starting its childViews (the drawer, the toolbar, the list) and starts the dialogs if needed
6. In parallel, each instanciated component gets or creates its ViewModel and render in the viewport

## Ready to go

Now you've got a basic knowledge of how the app works. The main concepts are:
- There's only 2 collections (one for _contacts_, one for _tags_) stored into the app. It _should_ not be more, as they represent the data. So all other collections are only projections of the last
- There's no more models as long as there's nothing more data to represent
- Some data may be more flexible when using internal Collections. It's in use for _datapoints_ in _contact_ models, as long as they are just _a collection of a bunch of datapoints_. They do not declares explicits models and collections, just use the Backbone defaults
- components _should not_ call others components API, but instead trigger events. Components responsibles of actions will catch them (like ViewModels and their associated views) to react to those events
- the views _should_ never do things by themselves

If you follow this principles, all things will cascade cleverly and smoothly through your app.

Now go to read the code ;).
