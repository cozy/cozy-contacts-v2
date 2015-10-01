###
Application bootstrap

Sets the browser environment to prepare it to launch the app, and then require
the application.
###

application = require './application'


###
Starts

Trigger locale initilization and starts application singleton.
###
$ ->
    Mn.Behaviors.behaviorsLookup = require 'lib/behaviors'
    # Temporary use a global variable to store the `t` helpers, waiting for
    # Marionette allow to register global helpers.
    # see https://github.com/marionettejs/backbone.marionette/issues/2164
    window.t    = require 'lib/i18n'
    application.start()
