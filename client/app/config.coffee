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

    colorSet: [
        '304FFE'
        '2979FF'
        '00B0FF'
        '00DCE9'
        '00D5B8'
        '00C853'
        'E70505'
        'FF5700'
        'FF7900'
        'FFA300'
        'B3C51D'
        '64DD17'
        'FF2828'
        'F819AA'
        'AA00FF'
        '6200EA'
        '7190AB'
        '51658D'
    ]

    search:
        pattern: (pattern, flags) ->
            flags = if pattern then 'i' else 'ig'
            new RegExp "`#{pattern or '\\w+'}:([^`]+)`", flags

