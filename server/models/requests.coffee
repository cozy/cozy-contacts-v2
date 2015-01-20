americano = require 'cozydb'

module.exports =

    contact:
        all: americano.defaultRequests.all
        byName: (doc) ->
            if doc.fn? and doc.fn.length > 0
                emit doc.fn, doc
            else if doc.n?
                emit doc.n.split(';').join(' ').trim(), doc
            else
                for dp in doc.datapoints
                    if dp.name is 'email'
                        emit dp.value, doc

    config:
        all: americano.defaultRequests.all

    contact_log:
        all: americano.defaultRequests.all
        bySnippet : (doc) ->
            remote = doc.remote.id or doc.remote.tel or doc.remote.mail
            snippet = "#{doc.timestamp} : #{doc.type} "
            snippet += "#{doc.direction} #{remote}"
            emit snippet, doc
        byRemote  : (doc) ->
            remote = doc.remote.id or doc.remote.tel or doc.remote.mail
            emit remote, doc

    webdavaccount:
        all: americano.defaultRequests.all
