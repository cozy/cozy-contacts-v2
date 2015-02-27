module.exports =
    slugify: (text) ->
        text.replace(/[^-a-zA-Z0-9,&\s]+/ig, '')
        .replace(/-/gi, '_')
        .replace(/\s/gi, '-')

    makeDateStamp: ->
        date = new Date()
        year = date.getFullYear()
        month = date.getMonth() + 1
        day = date.getDate()
        month = "0#{month}" if month < 10
        day = "0#{month}" if day < 10
        date = "#{year}-#{month}-#{day}"
