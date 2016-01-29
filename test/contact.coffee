fs = require 'fs'
expect = require('chai').expect

fixtures = require './fixtures/data'
helpers = require './helpers'

Contact = require "#{helpers.prefix}server/models/contact"

_global = {}

describe 'Contacts', ->

    before helpers.startServer
    before helpers.clearDb
    before helpers.createContact fixtures.contact1

    before helpers.makeTestClient
    after  helpers.killServer

    describe 'Index - GET /', ->

        it 'should allow requests', (done) ->
            # getLocale is very long, this need to be fixed
            @timeout 10000
            @client.get '/', done, false

        it 'should reply with the index.html file', ->
            expect(@err).to.not.exist
            expect(@body).to.have.string 'html lang='

    describe 'List - GET /contacts', ->

        it 'should allow requests', (done) ->
            @client.get 'contacts', done

        it 'should reply with the list of contacts', ->
            expect(@body).to.be.an 'array'
            expect(@body).to.have.length 1
            expect(@body[0].id).to.exist
            expect(@body[0].fn).to.equal fixtures.contact1.fn
            _global.id = @body[0].id

    describe 'Read - GET /contacts/:id', ->

        it 'should allow requests', (done) ->
            @client.get "contacts/#{_global.id}", done

        it 'should reply with one contact', ->
            expect(@body.fn).to.equal fixtures.contact1.fn
            expect(@body.note).to.equal fixtures.contact1.note
            expect(@body.id).to.exist

    describe 'Create - POST /contacts', ->

        contact =
            fn: 'Jane Smith'

        it 'should allow requests', (done) ->
            @client.post 'contacts', contact, done

        it 'should reply with the created contact', ->
            expect(@body.fn).to.equal contact.fn
            expect(@body.id).to.exist
            _global.id = @body.id

        it 'When you create the same contact with import flag', (done) ->
            contact =
                fn: 'Jane Smith'
                import: true

            @client.post 'contacts', contact, done

        it 'And you get all contacts', (done) ->
            @client.get 'contacts', done

        it 'Then there should be only one contact with that name', ->
            nb = 0
            for contact in @body
                nb++ if contact.fn is 'Jane Smith'
            expect(nb).to.equal 1

        it 'When you create the same contact without import flag', (done) ->
            contact =
                fn: 'Jane Smith'

            @client.post 'contacts', contact, done

        it 'And you get all contacts', (done) ->
            @client.get 'contacts', done

        it 'Then there should be two contacts with that name', ->
            nb = 0
            for contact in @body
                nb++ if contact.fn is 'Jane Smith'
            expect(nb).to.equal 2

    describe 'Update - PUT /contacts/:id', ->

        update =
            note: 'funny guy'

        it 'should allow requests', (done) ->
            @client.put "contacts/#{_global.id}", update, done

        it 'should reply with the updated album', ->
            expect(@body.note).to.equal update.note

        it 'when I GET the contact', (done) ->
            @client.get "contacts/#{_global.id}", done

        it 'then it is changed', ->
            expect(@body.note).to.equal update.note

    describe 'Add picture - PUT /contacts/:id/picture ', ->

        file = __dirname + '/fixtures/thumb.jpg'
        dest = './picture.jpg'

        it 'should allow request', (done) ->
            # request-json doesnt allow PUT form.
            # do it manually
            stream = require('http').request
                port: process.env.PORT or 8013
                method: 'PUT'
                path: "/contacts/#{_global.id}/picture"

            , (res) =>
                res.setEncoding 'utf8'
                @body = ''
                res.on 'data', (data) => @body += data
                res.on 'end', -> done null

            stream.on 'error', done
            stream.setHeader 'Content-Type', 'multipart/form-data; ' + \
                                'boundary=randomBoundary'
            stream.write "--randomBoundary\r\n"
            stream.write 'Content-Disposition: form-data; name="picture"; ' + \
                                '; filename="thumb.jpg"'
            stream.write "\r\nContent-Type: image/jpeg"
            stream.write "\r\n\r\n"
            stream.write fs.readFileSync file
            stream.write "\r\n--randomBoundary--"
            stream.end()

        it 'should return the contact', ->
            expect(JSON.parse(@body).fn).to.equal 'Jane Smith'

        it 'when i GET the picture', (done) ->
            path = "contacts/#{_global.id}/picture.png"
            @client.saveFile path, dest, done

        it 'the file has not been corrupted', ->
            stat1 = fs.statSync file
            stat2 = fs.statSync dest
            expect(stat1.size).to.equal stat2.size


    describe 'Delete - DELETE /contacts/:id', ->
        it 'should allow requests', (done) ->
            @client.del "contacts/#{_global.id}", done

        it 'should reply with 204 status', ->
            expect(@response.statusCode).to.equal 204

        it 'when I GET the contact', (done) ->
            @client.get "contacts/#{_global.id}", done

        it 'then i get an error', ->
            expect(@response.statusCode).to.equal 404


    describe 'Delete - POST /contacts/bulk-delete', ->

        ids = []

        before (done) ->
            @client.get 'contacts', =>
                ids.push @body[0].id
                ids.push @body[1].id
                done()

        it 'should allow requests', (done) ->
            @client.post "contacts/bulk-delete", ids, done

        it 'should reply with 204 status', ->
            expect(@response.statusCode).to.equal 200

        it 'when I GET all contacts', (done) ->
            @client.get "contacts", =>
                done()

        it 'then deleted contacts are no more there', ->
            expect(@body.length).to.equal 0

