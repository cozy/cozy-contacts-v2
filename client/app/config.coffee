module.exports =
    contact:
        xtras: ['bday']
        datapoints:
            main: ['tel', 'email', 'adr']
            types:
                default: ['main', 'work', 'home']
                social:  ['twitter:social', 'skype:chat']
                url:     ['website', 'blog']

    settings:
        sortkeys: ['gn', 'fn']

    search:
        pattern: (pattern, flags) ->
            flags = if pattern then 'i' else 'ig'
            new RegExp "`#{pattern or '\\w+'}:([^`]+)`", flags
