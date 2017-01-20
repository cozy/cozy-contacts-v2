###
Polyglot initialization

Locales need to be loaded in Polyglot before using it. We need to declares a
global translator `t` method to use it in Marionette templates.

We use the `html[lang]` attribute to get the correct locale.
###
init = ->
    locale = document.documentElement.getAttribute 'lang'
    try phrases = require "locales/#{locale}"
    catch e
        phrases = require 'locales/en'
    polyglot = new Polyglot phrases: phrases, locale: locale
    return polyglot.t.bind polyglot


module.exports = init()
