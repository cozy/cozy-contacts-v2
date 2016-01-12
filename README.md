# [Cozy](https://cozy.io) Contacts

Cozy Contacts makes your contact management easy. Main features are:

* Simple UI
* Contact tagging
* Contact notes
* VCF import
* CardDAV sync (it requires [Cozy Sync](https://github.com/cozy/cozy-sync))


## Install

We assume here that the Cozy platform is correctly [installed](https://docs.cozy.io/en/host/install) on your server.

You can simply install the Contacts application via the app registry. Click on the *Chose Your Apps* button located on the right of your Cozy Home.

From the command line you can type this command:

```sh
cozy-monitor install contacts
```


## Contribution

You can contribute to the Cozy Contacts in many ways:

* Pick up an [issue](https://github.com/cozy/cozy-contacts/issues?q=is%3Aissue+is%3Aopen) and solve it.
* Translate it in [a new language](https://www.transifex.com/cozy/cozy-contacts/dashboard/).
* Allow to share contacts
* Allow to subscribe to a CardDAV Contact Book.


## Hack

Hacking the Contacts app requires you [setup a dev environment](https://docs.cozy.io/en/hack/getting-started/). Once it's done you can hack Cozy Contact just like it was your own app.


```sh
$ git clone https://github.com/cozy/cozy-contacts.git
$ cd cozy-contacts
$ npm install
```

### Development

Run it with:

```sh
$ npm run watch
```

The `watch` task starts 3 daemons:

- the server one, running coffee-script server-side code through a [nodemon](https://github.com/remy/nodemon) process that reload the server part each time you make a change
- a [node-inspector](https://github.com/node-inspector/node-inspector) process, that let you use the Chome/Chromium devtools applied to your node process and debug it directly [in your browser](http://127.0.0.1:8080/?ws=127.0.0.1:8080&port=5858)
- a [brunch](https://github.com/brunch/brunch) watcher which recompiles and reload through browser-sync your front-end app in your browser each time you make a change

It also ensures that the client dependencies are well resolved.

### Build

[![Build Status](https://travis-ci.org/cozy/cozy-contacts.png?branch=master)](https://travis-ci.org/cozy/cozy-contacts)

The build is a part of the publication process, and you'll probably never need it explicitly. If you want to build you app anyway (e.g. to deploy it in a sandboxed cozy for tests purposes), you can achieve a build by running:

```sh
$ npm run build
```

Please, do not push your local builds in your PR, as long as we make the build process when we release the app.

If you need to run the tests suite to your build:

```sh
$ npm run test:build
```


## Tests

_NOTE:_ In order to run the tests, you must only have the Data System started.

A tests suite is available. You can run it with:

```sh
npm run test
```

Feel free to adapt/fix/add your own tests in your PR ;).

### Fixtures

Tests data are loaded by [cozy-fixtures](https://github.com/cozy/cozy-fixtures). A NPM script is pre-setted to help you to load fixtures.

Contacts fixtures are generated through the [Mockaroo](http://mockaroo.com/) service, so you need an API key to use it ([create an account](https://mockaroo.com/users/sign_in) on the Mockaroo service and use the api key provided in the [my account](https://mockaroo.com/profile) page)

```sh
$ MOCKAROO_API_KEY="your_api_key" npm run fixtures
```

### Backend

Running tests requires a Vagrant. Tests load a Dovecot instance in a Vagrant virtual machine. Make sure your Vagrant box is running, then run:

```sh
$ npm run test:server
```

## Contribute with Transifex

Transifex can be used the same way as git. It can push or pull translations. The config file in the .tx repository configure the way Transifex is working : it will get the json files from the client/app/locales repository.

If you want to learn more about how to use this tool, we invite you to check [the transifex tutorial](http://docs.transifex.com/introduction/).


## License

Cozy Contacts is developed by Cozy Cloud and distributed under the AGPL v3 license.


## What is Cozy?

![Cozy Logo](https://raw.github.com/mycozycloud/cozy-setup/gh-pages/assets/images/happycloud.png)

[Cozy](http://cozy.io) is a platform that brings all your web services in the same private space.  With it, your web apps and your devices can share data easily, providing you with a new experience. You can install Cozy on your own hardware where no one profiles you.


## Community

You can reach the Cozy Community by:

* Chatting with us on IRC #cozycloud on irc.freenode.net
* Posting on our [Forum](https://forum.cozy.io/)
* Posting issues on the [Github repos](https://github.com/cozy/)
* Mentioning us on [Twitter](https://twitter.com/mycozycloud)
