###
Application bootstrap

Sets the browser environment to prepare it to launch the app, and then require
the application.
###


###
Logging

Send client side errors to server.
###
initReporting = ->
    env     = require('imports').env
    console = window.console or {}

    levels = ['log', 'info', 'warn', 'error']

    send = (level, msg, url, line, col, err) ->
        data =
            type:  level
            href:  window.location.href
            url:   url
            line:  line
            col:   col
            error: msg: msg

        if err instanceof Error
            _.extend data.error,
                name:  err?.name
                full:  err?.toString() or msg
                stack: err?.stack

        $.post 'log', data, 'json'

    wrapLog = (level) ->
        consolefn = console[level]

        (args...) ->
            send level, JSON.stringify args
            # display in console if not in production mode
            consolefn.apply console, args if env isnt 'production'

    console[level] = wrapLog level for level in levels

    window.onerror = (args...) ->
        send.call null, 'error', args...
        # prevent native runtime error
        return env is 'production'


###
Starts

Trigger locale initilization and starts application singleton.
###
application = require './application'
# Temporary use a global variable to store the `t` helpers, waiting for
# Marionette allow to register global helpers.
# see https://github.com/marionettejs/backbone.marionette/issues/2164
window.t    = require 'lib/i18n'

ColorHash.addScheme 'cozy', require('config').colorSet
Mn.Behaviors.behaviorsLookup = require 'lib/behaviors'

document.addEventListener 'DOMContentLoaded', ->
    initReporting()
    application.start()
