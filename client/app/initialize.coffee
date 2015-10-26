###
Application bootstrap

Sets the browser environment to prepare it to launch the app, and then require
the application.
###


###
Logging

Send client side errors to server.
###
window.onerror = (msg, url, line, col, error) ->
    console.error msg, url, line, col, error, error?.stack
    exception = error?.toString() or msg
    if exception isnt window.lastError
        data =
            data:
                type: 'error'
                error:
                    msg: msg
                    name: error?.name
                    full: exception
                    stack: error?.stack
                url: url
                line: line
                col: col
                href: window.location.href
        xhr = new XMLHttpRequest()
        xhr.open 'POST', 'log', true
        xhr.setRequestHeader "Content-Type", "application/json;charset=UTF-8"
        xhr.send JSON.stringify(data)
        window.lastError = exception


###
Starts

Trigger locale initilization and starts application singleton.
###
application = require './application'

$ ->
    Mn.Behaviors.behaviorsLookup = require 'lib/behaviors'
    # Temporary use a global variable to store the `t` helpers, waiting for
    # Marionette allow to register global helpers.
    # see https://github.com/marionettejs/backbone.marionette/issues/2164
    window.t    = require 'lib/i18n'
    application.start()
