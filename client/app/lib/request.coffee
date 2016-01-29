# Make ajax request more simpler to send.
module.exports = request =
    send: (type, url, data, callback) ->
        $.ajax
            type: type
            url: url
            data: if data? then JSON.stringify data else null
            contentType: "application/json"
            dataType: "json"
            success: (data) ->
                callback null, data if callback?
            error: (data) ->
                if data? and data.msg? and callback?
                    callback new Error data.msg
                else if callback?
                    callback new Error "Server error occured"

    # Sends a get request.
    get: (url, callback) ->
        request.send "GET", url, null, callback

    # Sends a post request with data as body.
    post: (url, data, callback) ->
        request.send "POST", url, data, callback

    # Sends a put request with data as body.
    put: (url, data, callback) ->
        request.send "PUT", url, data, callback

    # Sends a delete request.
    del: (url, callback) ->
        exports.request "DELETE", url, null, callback

