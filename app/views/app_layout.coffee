###
App Layout

Attach itself to the `[role=application] DOM node and declares the application
main region for its subviews.
###

ContactModel = require 'models/contact'

ContactViewModel = require 'views/models/contact'

DefaultActionsTool = require 'views/tools/default_actions'
ContextActionsTool = require 'views/tools/context_actions'
LabelsFiltersView  = require 'views/labels/index'
LabelsEditView     = require 'views/labels/edit'
ToolbarView        = require 'views/tools/toolbar'
ContactsView       = require 'views/contacts'
CardView           = require 'views/contacts/card'
DuplicatesView     = require 'views/duplicates'
SettingsView       = require 'views/settings'

t = require 'lib/i18n'
app = undefined


module.exports = class AppLayout extends Mn.LayoutView

    template: require 'views/templates/layouts/app'

    el: '[role="application"]'

    behaviors:
        Navigator: {}
        Dropdown:  {}
        Keyboard:
            keymaps:
                '33': 'key:pageup'
                '34': 'key:pagedown'

    ui:
        navigate: 'aside [role="button"], .name'
        content:  'main [role="contentinfo"] '
        counter:  'main .counter'

    regions:
        actions: 'aside .tool-actions'
        labels:  'aside .tool-labels'
        indexes: '@ui.content .indexes'
        results: '@ui.content .results'
        toolbar: 'main [role="toolbar"]'
        dialogs:
            selector: '.dialogs'
            regionClass: require 'lib/regions/dialogs'
        alerts:
            selector: '.alerts'
            regionClass: require 'lib/regions/dialogs'


    modelEvents:
        'change:dialog':   'showDialog'
        'select:start':    'showContextualMenu'
        'select:end':      'hideContextualMenu'
        'change:scored':   'onSearchResults'

    childEvents:
        'drawer:toggle':     'toggleDrawer'
        'contacts:select':   (contactsView, id) -> @model.select id
        'contacts:unselect': (contactsView, id) -> @model.unselect id
        'dialog:close':      -> @model.set 'dialog', false
        'label:change':      'updateContactsTags'


    initialize: ->
        app = require 'application'

        # bind render to collections / appModel events
        @listenToOnce app.tags.underlying, 'sync': @showFilters
        @listenToOnce app.contacts, 'sync': @showContactsList
        @listenTo app.filtered, 'update': @updateCounter
        @listenTo app.model, 'change:filter': @updateCounter

        # bind Ui reacts to global channel events
        @listenTo app.channel,
            'busy:enable':  -> @$el.attr 'aria-busy', true
            'busy:disable': -> @$el.attr 'aria-busy', false
            'filter:text': @toggleResults
            'search:error': @error


    # Regions contents rendering
    # ##########################################################################
    onRender: ->
        toolbar = new ToolbarView()
        @listenToOnce toolbar,
            'show': -> toolbar.$('#contacts-search').trigger('focus')

        @showChildView 'toolbar', toolbar
        @showChildView 'actions', new DefaultActionsTool()



    showFilters: ->
        @showChildView 'labels', new LabelsFiltersView
            model:      @model
            collection: app.tags


    showContactsList: ->
        view = new ContactsView collection: app.filtered

        @listenToOnce view, 'show': @updateCounter

        @showChildView 'indexes', view


    showContextualMenu: ->
        if app.tags.length > 0
            @showChildView 'labels', new LabelsEditView
                model:      @model
                collection: app.tags.underlying
        else #do not display edit tags view if no tags are available
            @getRegion('labels').empty()
        @showChildView 'actions', new ContextActionsTool model: @model


    hideContextualMenu: ->
        @showFilters()
        @showChildView 'actions', new DefaultActionsTool()


    # keybr events bindings
    # ##########################################################################
    onKeyPageup: ->
        el = @ui.content[0]
        el.scrollTop -= el.offsetHeight


    onKeyPagedown: ->
        el = @ui.content[0]
        el.scrollTop += el.offsetHeight


    toggleDrawer: ->
        $drawer = @$ 'aside.drawer'
        isVisible = $drawer.attr('aria-expanded') is 'true'
        $drawer.attr 'aria-expanded', not isVisible


    # Search results rendering
    #
    # Results are a secondary view only displayed when filtering is triggered.
    # It can be hidden when search pattern is to short (ERR.SEARCH_TOO_SHORT),
    # and showed again when search pattern updates.
    # ##########################################################################
    onSearchResults: (nil, isSearch) ->
        # hide/show indexed list view if is/isnt in search mode
        @indexes.$el.attr 'aria-hidden', isSearch

        if isSearch
            # delay search view threats to let the DOM safe
            setTimeout =>
                view = new ContactsView collection: app.filtered
                @showChildView 'results', view
        else
            @results.reset()


    toggleResults: (text) ->
        @results.$el?.attr 'aria-hidden', not text?.length


    # Dialogs showing
    #
    # Show modal dialogs in app's layout, such as card contact view, or merge
    # dialog.
    # ##########################################################################
    showDialog: (appViewModel, slug) ->
        return @dialogs.empty() unless slug

        # Remove old listeners
        # before updating DialogsRegion
        if (dialogs = @getChildView 'dialogs')
            dialogs.stopListening dialogs.model, 'change:tags'

        dialogView = switch slug
            when 'settings'   then new SettingsView model: @model
            when 'duplicates' then new DuplicatesView()
            else
                if slug is 'new'
                    model = new ContactModel null, parse: true
                else
                    model = app.contacts.get slug

                viewModel = new ContactViewModel {new: slug is 'new'},
                    model: model
                viewModel.listenTo app.channel,
                    'mode:edit': (edit) -> @set 'edit', edit

                new CardView model: viewModel

        @showChildView 'dialogs', dialogView


    # Counter updates / actions
    # ##########################################################################
    updateCounter: ->
        # delay counter update at next frame to keep ui more smooth
        window.requestAnimationFrame =>
            unless app.contacts.length
                label = t('list counter empty')
            else
                size = app.filtered.get(tagged: true).length
                label = if size
                    t('list counter', {smart_count: size})
                else
                    t('list counter no-search')

            @ui.counter
                .text label
                .toggleClass 'important', not size


    error: (err) ->
        {ERR} = require 'config'
        if err is ERR.SEARCH_TOO_SHORT
            @results.$el.attr 'aria-hidden', true
            @ui.counter
            .text t 'error search too short'
            .addClass 'important'
