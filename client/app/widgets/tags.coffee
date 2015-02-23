BaseView = require '../lib/base_view'
Autocomplete = require './autocomplete'

module.exports = class TagsView extends BaseView

    events: ->
        'click .tag': 'tagClicked'
        'click .tag .deleter': 'deleteTag'
        'focus input': 'onFocus'
        'keydown input': 'onKeyDown'
        'keyup input': 'refreshAutocomplete'

    template: -> """
        <input type="text" placeholder="#{t('add tags')}">
    """

    initialize: (options)->
        @options = options
        @refresh()
        @listenTo @model, 'change:tags', =>
            @refresh()

    onFocus: (e) ->
        TagsView.autocomplete.bind this.$el
        TagsView.autocomplete.refresh '', @tags
        if @input.val() is ''
            TagsView.autocomplete.$el.hide()
        else
            TagsView.autocomplete.$el.show()

    onKeyDown: (e) =>
        val = @input.val()

        if val is '' and e.keyCode is 8 #BACKSPACE
            @setTags @tags[0..-2] # remove last tag

            TagsView.autocomplete.refresh('', @tags)
            TagsView.autocomplete.position()
            e.preventDefault()
            e.stopPropagation()
            return

        # COMMA, SPACE, TAB, ENTER
        if val and e.keyCode in [188, 32, 9, 13]
            @tags ?= []
            @tags.push val unless val in @tags
            @setTags @tags

            @input.val ''
            TagsView.autocomplete.refresh('', @tags)
            TagsView.autocomplete.position()

            e.preventDefault()
            e.stopPropagation()
            return

        if e.keyCode in [188, 32, 9, 13]
            e.preventDefault()
            e.stopPropagation()
            return

        #UP, DOWN
        if e.keyCode in [40, 38]
            return true

        if val and e.keyCode isnt 8
            @refreshAutocomplete()
            return true

    refreshAutocomplete: (e) =>
        if @input.val() isnt ''
            TagsView.autocomplete.$el.show()

        return if e?.keyCode in [40, 38, 8]
        TagsView.autocomplete.refresh @input.val(), @tags

    tagClicked: (e) =>
        tag = e.target.dataset.value
        @trigger 'tagClicked', tag

    setTags: (newTags) =>
        @tags = newTags
        @tags ?= []
        @model.attributes.tags = newTags
        if @options.onBlur?
            @options.onBlur()
        else
            @model.save tags: @tags

    deleteTag: (e) =>
        tag = e.target.parentNode.dataset.value
        @setTags _.without @tags, tag
        e.stopPropagation()
        e.preventDefault()

    afterRender: ->
        @refresh()
        @input = @$('input')

    refresh: =>
        @tags = _.clone @model.get 'tags'
        @$('.tag').remove()
        html = ("""
                <li class="tag" data-value="#{tag.get 'name' }" style="background: #{tag.get 'color' };">
                    #{tag.get 'name'}
                    <span class="deleter fa fa-remove"/>
                </li>
            """ for tag in @model.getTags() or []).join ''
        @$el.prepend html

    toggleInput: =>
        @$('input').toggle()
        @$('input').focus() if @$('input').is(':visible')

    hideInput: =>
        @$('input').hide()

TagsView.autocomplete = new Autocomplete(id: 'tagsAutocomplete')
TagsView.autocomplete.render()
