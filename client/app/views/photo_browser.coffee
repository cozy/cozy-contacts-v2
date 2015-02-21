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
        'click img'           : 'toggleClicked'
        'dblclick img'        : 'validateDblClick'
        'click a.next'        : 'displayMore'
        'click a.prev'        : 'displayPrevPage'
        'click .chooseAgain'  : 'chooseAgain'


    validateDblClick:(e)->
        if @singleSelection
            if typeof @state.selected[e.target.id] != 'object'
                @toggleClicked(e)
            @showCropingTool()
        else
            return


    toggleClicked: (e) ->
        id = e.target.id
        if @singleSelection
            @toggleOne(e.target, id)
            for i, thumb of @state.selected # thumb = {id,name,thumbEl}
                if i != id
                    if typeof(thumb) == 'object' # means thumb is selected
                        $(thumb.el).removeClass('selected')
                        @state.selected[i] = false
                        @state.selected_n -=1
        else
            @toggleOne(e.target, id)


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
                return val.id
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
        if @currentStep == 2
            e.stopPropagation()
            @chooseAgain()
        else
            super(e)


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

        @imgToCrop.addEventListener('load', ()=>
            @img_w = @imgToCrop.width
            @img_h = @imgToCrop.height
            options =
                onChange    : @showPreview
                onSelect    : @showPreview
                aspectRatio : 1
                setSelect   : [ 10, 10, 150, 150 ]
            t = this
            $(@imgToCrop).Jcrop( options, ()->
                t.jcrop_api = this
            )
        , false)

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
            @state.dates = "No photos found"

        else
            if body?.hasNext?
                hasNext = body.hasNext
            else
                hasNext = false
            @addPhotos(body.files, hasNext)

        # Add selected files
        # if @state.selected[@state.page]?
        for id, val of @state.selected
            if typeof(val) == 'object'
                @$("##{id}").addClass 'selected'


    addPhotos : (files, hasNext) ->
        # Add next button
        if !hasNext
            @nextBtn.style.display = 'none'
        dates = Object.keys files
        dates.sort (a, b) ->
            -1 * a.localeCompare b
        s = ''
        for month in dates
            photos = files[month]
            for p in photos
                s += "<img src='files/thumbs/#{p.id}.jpg' id='#{p.id}' title='#{p.name}'></img>"
        div = document.createElement('div')
        div.innerHTML = s
        @photoContainer.appendChild(div)
        # @$('.modal-body').html @template_content @getRenderData()
        # @state.render()


    cb: (confirmed) ->
        return unless confirmed
        @state.beforeUpload (attrs) =>
            tmp = []
            # @state.selected[@state.page] = @$('.selected')
            for page in @state.selected
                for img in page
                    fileid = img.id

                    # Create a temporary photo
                    attrs.title = img.name
                    phototmp = new Photo attrs
                    phototmp.file = img
                    tmp.push phototmp
                    @collection.add phototmp

                    Photo.makeFromFile fileid, attrs, (err, photo) =>
                        return console.log err if err
                        # Replace temporary photo
                        phototmp = tmp.pop()
                        @collection.remove phototmp, parse: true
                        @collection.add photo, parse: true # bja : remise à jour


    displayMore: ->
        # Display next page of photo
        @state.page +=  1
        @addPage(@state.page)


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


    # CROPPING OF PHOTO
    showPreview: (coords) =>
        target_h = 100 # height of the img-preview
        target_w = 100
        # todo BJA :
        # récupérer la largeur réelle de l'image affichée qui peut varier (fichier petit ou paysage ou portrait...)
        # ATTENTION il faut récupérer la dimention AFFICHEE, c'est à dire le nbr de px à l'écran, pas le nbr de px dans le fichier d'origine)
        # img_w = @imgToCrop.width
        # img_h = @imgToCrop.height

        # img_w = @imgToCrop.naturalWidth
        # img_h = @imgToCrop.naturalHeight

        prev_w = @img_w / coords.w * target_w
        prev_h = @img_h / coords.h * target_h
        prev_x = target_w / coords.w  * coords.x
        prev_y = target_h / coords.h * coords.y

        $('#img-preview').css(
            width: Math.round(prev_w ) + 'px',
            height: Math.round(prev_h ) + 'px',
            marginLeft: '-' + Math.round(prev_x) + 'px',
            marginTop: '-' + Math.round(prev_y ) + 'px'
        )
        return true


    chooseAgain : ()->
        @currentStep = 1
        @jcrop_api.destroy()
        @imgToCrop.removeAttribute('style')
        croppingEl = @el.querySelector('.cropping')
        @photoContainer.style.display = ''
        @nextPrevContainer.style.display = ''
        croppingEl.style.display = 'none'
        @body.scrollTop = @currentPhotoScroll



