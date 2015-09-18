module.exports = class DataPoint extends Backbone.Model

    # Model :
    # name: String
    # type: String
    # value: String
    # ... optionnal fields.
    #
    # But, if name is 'adr', value is a [String][7]
    #
    defaults:
      type: 'main'
      name: 'other'
      value: ''

    # toJSON, unless name is 'adr', where value et flattened.
    toDisplayJSON: ->
        json = @toJSON()

        if @attributes.name is 'adr'
            json.value = VCardParser.adrArrayToString @attributes.value

        return json

    # Set the type and value fields with string.
    # If name is adr, convert value to Array
    setTypeNValue: (type, value) ->
        if @attributes.name is 'adr'
            value = VCardParser.adrStringToArray value

        @set {type, value}
