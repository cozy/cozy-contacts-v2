# [Cozy](http://cozy.io) Contacts

Cozy Contacts makes your contact management easy. Main features are:

* Simple UI
* Contact tagging
* Contact notes
* VCF import
* CardDAV sync (it requires [Cozy Sync](https://github.com/cozy/cozy-sync))

## Install

We assume here that the Cozy platform is correctly [installed](http://cozy.io/host/install)
 on your server.

You can simply install the Contacts application via the app registry. Click on ythe *Chose Your Apps* button located on the right of your Cozy Home.

From the command line you can type this command:

    cozy-monitor install contacts


## Contribution

You can contribute to the Cozy Contacts in many ways:

* Pick up an [issue](https://github.com/mycozycloud/cozy-contacts/issues?state=open) and solve it.
* Translate it in [a new language](https://github.com/mycozycloud/cozy-contacts/tree/master/client/app/locales).
* Allow to share contacts
* Allow to subscribe to a CardDAV Contact Book.


## Hack

Hacking the Contacts app requires you [setup a dev environment](http://cozy.io/hack/getting-started/). Once it's done you can hack Cozy Contact just like it was your own app.

    git clone https://github.com/mycozycloud/cozy-contacts.git

Run it with:

    node server.js

Each modification of the server requires a new build, here is how to run a
build:

    cake build

Each modification of the client requires a specific build too.

    cd client
    brunch build

## Tests

![Build
Status](https://travis-ci.org/mycozycloud/cozy-contacts.png?branch=master)

To run tests type the following command into the Cozy Contacts folder:

    cake tests

In order to run the tests, you must only have the Data System started.

## Icons

by [iconmonstr](http://iconmonstr.com/).

Main icon by [Elegant Themes](http://www.elegantthemes.com/blog/freebie-of-the-week/beautiful-flat-icons-for-free).

## Contribute with Transifex

Transifex can be used the same way as git. It can push or pull translations. The config file in the .tx repository configure the way Transifex is working : it will get the json files from the client/app/locales repository.
If you want to learn more about how to use this tool, I'll invite you to check [this](http://docs.transifex.com/introduction/) tutorial.

## License

Cozy Contacts is developed by Cozy Cloud and distributed under the AGPL v3 license.

## What is Cozy?
A
![Cozy Logo](https://raw.github.com/mycozycloud/cozy-setup/gh-pages/assets/images/happycloud.png)

[Cozy](http://cozy.io) is a platform that brings all your web services in the
same private space.  With it, your web apps and your devices can share data
easily, providing you
with a new experience. You can install Cozy on your own hardware where no one
profiles you.

## Community

You can reach the Cozy Community by:

* Chatting with us on IRC #cozycloud on irc.freenode.net
* Posting on our [Forum](https://forum.cozy.io/)
* Posting issues on the [Github repos](https://github.com/cozy/)
* Mentioning us on [Twitter](http://twitter.com/mycozycloud)
