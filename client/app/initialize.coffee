app = require 'application'

# Send client side errors to server
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

$ ->
    try
        jQuery.event.props.push 'dataTransfer'
        app.initialize()

    catch e
        console.error e, e?.stack
        exception = e.toString()
        if exception isnt window.lastError
            # Send client side errors to server
            data =
                data:
                    type: 'error'
                    error:
                        msg: e.message
                        name: e?.name
                        full: exception
                        stack: e?.stack
                    file: e?.fileName
                    line: e?.lineNumber
                    col: e?.columnNumber
                    href: window.location.href
            xhr = new XMLHttpRequest()
            xhr.open 'POST', 'log', true
            xhr.setRequestHeader "Content-Type",
                "application/json;charset=UTF-8"
            xhr.send JSON.stringify(data)
            window.lastError = exception
