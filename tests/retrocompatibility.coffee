# ensure all patches and compat layers are working properly
helpers = require './helpers'
expect = require('chai').expect

describe 'Contacts Retrocompatibility', ->

    # clean the db
    before helpers.startServer
    before helpers.clearDb
    before helpers.killServer

    # start test server
    before helpers.startServer
    before helpers.makeTestClient
    after  helpers.clearDb
    after  helpers.killServer


    describe 'no N, no FN', ->

        # create some random contacts
        before helpers.createRaw
            docType: 'contact'
            datapoints: []

        it 'should allow requests', (done) ->
            @client.get "contacts/#{@created._id}", done

        it 'should reply with one contact', ->
            expect(@body.n).to.exist
            expect(@body.n.split ';').to.have.length 5
            expect(@body.fn).to.exist

    describe 'N, no FN', ->

        # create some random contacts
        before helpers.createRaw
            docType: 'contact'
            datapoints: []
            n: 'a;b;c;d;e'

        it 'should allow requests', (done) ->
            @client.get "contacts/#{@created._id}", done

        it 'should reply with computed FN', ->
            expect(@body.n).to.exist
            expect(@body.n).to.equal 'a;b;c;d;e'
            expect(@body.fn).to.exist
            expect(@body.fn).to.have.string 'a'

    describe 'no N, FN', ->

        # create some random contacts
        before helpers.createRaw
            docType: 'contact'
            datapoints: []
            fn: 'yolo'

        it 'should allow requests', (done) ->
            @client.get "contacts/#{@created._id}", done

        it 'should reply with computed N', ->
            expect(@body.n).to.exist
            expect(@body.n).to.have.string 'yolo'
            expect(@body.fn).to.exist
            expect(@body.fn).to.equal 'yolo'
