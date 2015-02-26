Modal = require 'cozy-clearance/modal'
Photo = require '../models/photo'


module.exports = class FilesBrowser extends Modal

    id: 'files-browser-modal'
    template_content: require '../templates/photo_browser'
    title: t 'pick from files'
    content: '<p>Loading ...</p>'
    photoContainer:null # the div containing photos
    nextPrevContainer: null
    singleSelection:true # tells if user can select one or more photo
    currentStep:1


    events: -> _.extend super,
        'click    .photoContainer' : 'validateClick'
        'dblclick .photoContainer' : 'validateDblClick'
        'click    a.next'          : 'displayMore'
        'click    a.prev'          : 'displayPrevPage'
        'click   .chooseAgain'     : 'chooseAgain'


    validateDblClick:(e)->
        if e.target.nodeName != "IMG"
            return
        if @singleSelection
            if typeof @state.selected[e.target.id] != 'object'
                @toggleClicked(e.target)
            @showCropingTool()
        else
            return


    validateClick:(e)->
        el = e.target
        if el.nodeName != "IMG"
            return
        @toggleClicked(el)


    toggleClicked: (el) ->
        id = el.id
        if @singleSelection
            currentID = @getSelectedID()
            if currentID == id
                return
            @toggleOne(el, id)
            # unselect other thumbs
            for i, thumb of @state.selected # thumb = {id,name,thumbEl}
                if i != id
                    if typeof(thumb) == 'object' # means thumb is selected
                        $(thumb.el).removeClass('selected')
                        @state.selected[i] = false
                        @state.selected_n -=1
        else
            @toggleOne(el, id)


    selectFirstThumb:()->
        @toggleClicked(@photoContainer.firstChild)


    selectNextThumb: ()->
        thumb = @getSelectedThumb()
        if thumb == null
            return
        nextThumb = thumb.nextElementSibling
        if nextThumb
            @toggleClicked(nextThumb)


    selectPreviousThumb : ()->
        thumb = @getSelectedThumb()
        if thumb == null
            return
        prevThumb = thumb.previousElementSibling
        if prevThumb
            @toggleClicked(prevThumb)


    selectThumbUp : ()->
        thumb = @getSelectedThumb()
        if thumb == null
            return
        x = thumb.x
        prevThumb = thumb.previousElementSibling
        while prevThumb
            if prevThumb.x == x
                @toggleClicked(prevThumb)
                return
            prevThumb = prevThumb.previousElementSibling
        firstThumb = thumb.parentElement.firstChild
        if firstThumb != thumb
            @toggleClicked(firstThumb)


    selectThumbDown : ()->
        thumb = @getSelectedThumb()
        if thumb == null
            return
        x = thumb.x
        nextThumb = thumb.nextElementSibling
        while nextThumb
            if nextThumb.x == x
                @toggleClicked(nextThumb)
                return
            nextThumb = nextThumb.nextElementSibling
        lastThumb = thumb.parentElement.lastChild
        if lastThumb != thumb
            @toggleClicked(lastThumb)


    toggleOne: (thumbEl, id) ->
        if typeof(@state.selected[id]) == 'object'
            $(thumbEl).removeClass('selected')
            @state.selected[id] = false
            @state.selected_n -=1
        else
            $(thumbEl).addClass('selected')
            @state.selected[id] = {id:id,name:"",el:thumbEl}
            @state.selected_n +=1


    getSelectedID : () ->
        for k, val of @state.selected
            if typeof(val)=='object'
                return k
        return null


    getSelectedThumb : () ->
        for k, val of @state.selected
            if typeof(val)=='object'
                return val.el
        return null


    # supercharge the modal behavour : "ok" leads to the cropping step
    onYes: ()->
        if @currentStep == 1
            if @state.selected_n == 1
                @showCropingTool()
            else
                return false
        else
            super()


    closeOnEscape: (e)->
        # the modal class methog listening to keystrokes
        # should be named "onKeyStroke"
        if @currentStep == 2
            if e.which is 27 # escape
                e.stopPropagation()
                @chooseAgain()
            else if e.which == 13 # return
                e.stopPropagation()
                @onYes()
                return
            else
                return
        else # @currentStep == 1
            switch e.which
                when 27 # escape
                    return super(e)
                when 13 # return
                    e.stopPropagation()
                    @onYes()
                    return
                when 39 # right
                    e.stopPropagation()
                    @selectNextThumb()
                when 37 # left
                    e.stopPropagation()
                    @selectPreviousThumb()
                when 38 # up
                    e.stopPropagation()
                    @selectThumbUp()
                when 40 # down
                    e.stopPropagation()
                    @selectThumbDown()
                else
                    return
        return


    initialize: (state) ->
        @yes = t 'modal ok'
        @no  = t 'modal cancel'
        super({})
        @state=
            page       : 0
            selected   : {}
            selected_n : 0
            dates      : "Waiting for photo"
            percent    : 0
            hasNext    : false
            hasPrev    : false
        @body              = @el.querySelector('.modal-body')
        body               = @body
        body.innerHTML     = @template_content()
        @photoContainer    = body.querySelector('.photoContainer')
        @nextPrevContainer = body.querySelector('.nextPrevContainer')
        @croppingEl        = @el.querySelector('.cropping')
        @imgToCrop         = @croppingEl.querySelector('#img-to-crop')
        @nextBtn           = body.querySelector('.next')

        body.classList.add('photoBrowser')
        @imgToCrop.addEventListener('load', @onImgToCropLoaded, false)
        @croppingEl.style.display = 'none'  #hide the croping area
        @addPage(0)
        return true


    addPage:(page)->
        # Recover files
        Photo.listFromFiles page, @listFromFiles_cb


    listFromFiles_cb: (err, body) =>
        files = body.files if body?.files?

        if err
            return console.log err

        # If server is creating thumbs : then wait before to display files.
        else if body.percent?
            @state.dates   = "Thumb creation"
            @state.percent = body.percent
            pathToSocketIO = \
                "#{window.location.pathname.substring(1)}socket.io"
            socket = io.connect window.location.origin,
                resource: pathToSocketIO
            socket.on 'progress', (event) =>
                @state.percent = event.percent
                if @state.percent is 100
                    @initialize state
                else
                    template = @template_content @getRenderData()
                    @$('.modal-body').html template

        # If there is no photos in Cozy
        else if files? and Object.keys(files).length is 0
            @photoContainer.innerHTML = "<p>#{t 'no image'}</p>"

        # there are some images, add thumbs to modal
        else
            if body?.hasNext?
                hasNext = body.hasNext
            else
                hasNext = false
            @addThumbs(body.files, hasNext)
            if @singleSelection
                @selectFirstThumb()

        # Add selected files
        # if @state.selected[@state.page]?
        for id, val of @state.selected
            if typeof(val) == 'object'
                @$("##{id}").addClass 'selected'


    addThumbs : (files, hasNext) ->
        # Add next button
        if !hasNext
            @nextBtn.style.display = 'none'
        dates = Object.keys files
        dates.sort (a, b) ->
            -1 * a.localeCompare b
        frag = document.createDocumentFragment()
        s = ''
        for month in dates
            photos = files[month]
            for p in photos
                img       = new Image()
                img.src   = "files/thumbs/#{p.id}.jpg"
                img.id    = "#{p.id}"
                img.title = "#{p.name}"
                frag.appendChild(img)
        @photoContainer.appendChild(frag)


    cb: (confirmed) ->
        return unless confirmed
        fileID = @getSelectedID()
        attrs =
            x:0
            y:0
            w:50
            h:80
            resizedW:100
            resizedH:150
        Photo.cropResizeFromFile(fileID, attrs)


        # @state.beforeUpload (attrs) =>
        #     tmp = []
        #     # @state.selected[@state.page] = @$('.selected')
        #     for page in @state.selected
        #         for img in page
        #             fileid = img.id

        #             # Create a temporary photo
        #             attrs.title = img.name
        #             phototmp = new Photo attrs
        #             phototmp.file = img
        #             tmp.push phototmp
        #             @collection.add phototmp

        #             Photo.makeFromFile fileid, attrs, (err, photo) =>
        #                 return console.log err if err
        #                 # Replace temporary photo
        #                 phototmp = tmp.pop()
        #                 @collection.remove phototmp, parse: true
        #                 @collection.add photo, parse: true # bja : remise à jour


    displayMore: ->
        # Display next page of photo
        @state.page +=  1
        @addPage(@state.page)


    onImgToCropLoaded: ()=>
        img_w  = @imgToCrop.width
        img_h  = @imgToCrop.height
        @img_w = img_w
        @img_h = img_h
        selection_w    = Math.round(Math.min(img_h,img_w)*1)
        x = Math.round( (img_w-selection_w)/2 )
        y = Math.round( (img_h-selection_w)/2 )
        options =
            onChange    : @updatePreview
            onSelect    : @updatePreview
            aspectRatio : 1
            setSelect   : [ x, y, x+selection_w, y+selection_w ]
        t = this
        $(@imgToCrop).Jcrop( options, ()->
            t.jcrop_api = this
        )


    showCropingTool:->
        @currentStep = 2
        @currentPhotoScroll = @body.scrollTop
        croppingEl = @croppingEl

        @photoContainer.style.display = 'none'
        @nextPrevContainer.style.display = 'none'
        croppingEl.style.display = ''
        screenUrl = "files/screens/#{@getSelectedID()}.jpg"
        @imgToCrop.src = screenUrl
        croppingEl.querySelector('#img-preview').src= screenUrl


    updatePreview: (coords) =>
        target_h = 100 # height of the img-preview
        target_w = 100
        # todo BJA :
        # récupérer la largeur réelle de l'image affichée qui peut varier (fichier petit ou paysage ou portrait...)
        # ATTENTION il faut récupérer la dimention AFFICHEE, c'est à dire le nbr de px à l'écran, pas le nbr de px dans le fichier d'origine)

        prev_w = @img_w / coords.w * target_w
        prev_h = @img_h / coords.h * target_h
        prev_x = target_w / coords.w  * coords.x
        prev_y = target_h / coords.h * coords.y

        $('#img-preview').css(
            width      : Math.round(prev_w ) + 'px',
            height     : Math.round(prev_h ) + 'px',
            marginLeft : '-' + Math.round(prev_x) + 'px',
            marginTop  : '-' + Math.round(prev_y ) + 'px'
        )
        return true


    chooseAgain : ()->
        @currentStep = 1
        @jcrop_api.destroy()
        @imgToCrop.removeAttribute('style')
        @imgToCrop.src = ''
        croppingEl = @el.querySelector('.cropping')
        @photoContainer.style.display = ''
        @nextPrevContainer.style.display = ''
        croppingEl.style.display = 'none'
        @body.scrollTop = @currentPhotoScroll



