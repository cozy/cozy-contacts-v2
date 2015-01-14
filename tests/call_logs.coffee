fixtures = require './fixtures/data'
fs = require 'fs'
helpers = require './helpers'
expect = require('chai').expect
async  = require 'async'

describe 'Call Logs', ->

    before helpers.startServer
    before helpers.clearDb
    before helpers.createContact fixtures.contact1

    before helpers.makeTestClient
    after  helpers.killServer

    describe 'Create logs (first merge) - POST /logs', ->

        it 'should allow requests', (done) ->
            @client.post "logs", fixtures.logs1, done

        it 'should reply with 201 status', ->
            expect(@response.statusCode).to.eql 201


    describe 'Get logs - GET /contact/:id/logs', ->

        it 'should allow requests', (done) ->
            @timeout 5000
            @client.get "contacts/#{@contact.id}/logs", done

        it 'should reply with the logs for this contact numbers (2)', ->
            expect(@body).to.be.an 'array'
            expect(@body).to.have.length 2

    describe 'Merge logs - POST /logs (same logs + some new)', ->

        it 'should allow requests', (done) ->
            @client.post "logs", fixtures.logs2, done

        it 'then, when i get', (done) ->
            @timeout 5000
            @client.get "contacts/#{@contact.id}/logs", done

        it 'should reply with the logs (now 3)', ->
            expect(@body).to.be.an 'array'
            expect(@body).to.have.length 3
