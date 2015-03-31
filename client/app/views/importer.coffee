BaseView = require 'lib/base_view'
Contact  = require 'models/contact'
app      = require 'application'

module.exports = class ImporterView extends BaseView

    template: require 'templates/importer'

    id: 'importer'
    tagName: 'div'
    className: 'modal'

    events: ->
        'change #vcfupload': 'onupload'
        'click  #confirm-btn': 'addcontacts'


    afterRender: ->
        @$el.modal()
        @upload = @$('#vcfupload')[0]
        @content = @$('.modal-body')
        @confirmBtn = @$('#confirm-btn')


    # Handle upload of vcard file: check type and make it a string.
    onupload: ->
        file = @upload.files[0]
        extension = file.name.substring file.name.lastIndexOf('.')
        if extension not in ['.vcf', '.vcard']
            @$('.control-group').addClass 'error'
            @$('.help-inline').text t 'is not a vcard'
            return

        $(".loading").show()
        # Read the uploaded filed and make it a simple string.
        reader = new FileReader()
        reader.readAsText file
        reader.onloadend = =>

            @prepareImport reader.result


    # Parse all vcards from the text file and display information about them
    # to the user (name of each contact and number of parsed contacts).
    # Once done, it disables the import button.
    prepareImport: (vcardText) ->
        # Separate all vCards to import.
        cards = vcardText.split 'END:VCARD'
        @toImport = []

        # Prepare information displaying.
        txt = """
            <p>#{t 'import count'} <span class=\"contact-amount\">0</span></p>
            <ul class=\"import-list\"></ul>
        """
        @content.html txt

        amount = 0
        cards.pop()

        # Recursive function that makes pause between each card import.
        # That's useful to not block the browser while parsing the vcard
        # file.
        do addCard = =>
            if cards.length > 0
                card = cards.shift()
                card += '\nEND:VCARD'

                parsedCards = Contact.fromVCF(card)
                if parsedCards.models.length > 0
                    contact = parsedCards.models[0]

                    @toImport.push contact

                    # Ensure there is something to display.
                    name = contact.get('fn') or contact.getComputedFN()
                    if not name? or name.trim() is ''
                        name = contact.getBest 'email'
                    if not name? or name.trim() is ''
                        name = contact.getBest 'tel'

                    # Update display to make things less boring for the user.
                    amount++
                    $('.contact-amount').html amount
                    $('.import-list').append "<li>#{name}</li>"

                setTimeout addCard, 1

            else
                @confirmBtn.removeClass 'disabled'


    # Update progress count.
    updateProgress: (number, total) ->
        @$(".import-progress").html " #{number} / #{total}"


    # Run the import process. It creates all contacts stored in the toImport
    # attribute. Contacts were stored during the import preparation step.
    addcontacts: ->
        return true unless @toImport
        @content.html """
        <p>#{t('dont close navigator import')}</p>
        <p>
            #{t('import progress')}:&nbsp;<span class="import-progress"></span>
        </p>
        <p class="errors">
        </p>
        """
        currentSize = total = @toImport.length
        @importing = true
        @updateProgress 0, total

        do importContact = =>
            if @toImport.length is 0
                alert t 'import succeeded'
                @importing = false
                @close()
            else
                contact = @toImport.pop()
                currentSize--

                contact.set 'import', true
                contact.save null,
                    success: =>
                        @updateProgress (total - currentSize), total
                        app.contacts.add contact
                        contact.savePicture()
                        # Don't know why datasystem has hard time dealing with
                        # too many successive request. This aims to let it
                        # breath. But we should handle import on the server
                        # side and make bulk creations to make it much faster.
                        # (Write leads to reindexation, so one write at at time
                        # is really inefficient).
                        setTimeout importContact, 10
                    error: =>
                        $(".errors").append """
                        <p>#{t 'fail to import'}: #{contact.getComputedFN()}</p>
                        """
                        importContact()


    close: ->
        unless @importing
            @$el.modal 'hide'
            @remove()
            app.router.navigate '#help', trigger: true
