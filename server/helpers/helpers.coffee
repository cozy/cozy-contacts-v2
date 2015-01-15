module.exports =
    slugify: (text) ->
        text.replace(/[^-a-zA-Z0-9,&\s]+/ig, '')
        .replace(/-/gi, '_')
        .replace(/\s/gi, '-')

    makeDateStamp: ->
        date = new Date()
        year = date.getYear()
        month = date.getMonth()
        day = date.getDay()
        date = "#{year}-#{month}-#{day}"
