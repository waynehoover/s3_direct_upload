#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

$ = jQuery

$.fn.S3Uploader = (options) ->

  # support multiple elements
  if @length > 1
    @each ->
      $(this).S3Uploader options

    return this

  $uploaderElement = this

  settings =
    path: ''
    additional_data: null
    before_add: null
    remove_completed_progress_bar: true
    remove_failed_progress_bar: false
    progress_bar_target: null
    click_submit_target: null

  $.extend settings, options

  current_files = []
  forms_for_submit = []
  if settings.click_submit_target
    settings.click_submit_target.click ->
      form.submit() for form in forms_for_submit
      false

  setUploadElement = ->
    $uploaderElement.fileupload
      url: settings.url if settings.url

      add: (e, data) ->
        file = data.files[0]
        file.unique_id = Math.random().toString(36).substr(2,16)

        unless settings.before_add and not settings.before_add(file)
          current_files.push data
          data.context = $($.trim(tmpl("template-upload", file))) if $('#template-upload').length > 0
          $(data.context).appendTo(settings.progress_bar_target($(this)) || $uploaderElement)
          if settings.click_submit_target
           forms_for_submit.push data
          else
            data.submit()

      start: (e) ->
        $uploaderElement.trigger("s3_uploads_start", [e])

      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find('.bar').css('width', progress + '%')

      done: (e, data) ->
        content = build_content_object $uploaderElement, data.files[0], data.result

        to = $uploaderElement.data('callback-url')
        if to
          content[$uploaderElement.data('callback-param')] = content.url

          element = $(this)
          $.ajax
            type: $uploaderElement.data('callback-method')
            url: to
            data: content
            beforeSend: ( xhr, settings )       -> element.trigger( 'ajax:beforeSend', [xhr, settings] )
            complete:   ( xhr, status )         -> element.trigger( 'ajax:complete', [xhr, status] )
            success:    ( data, status, xhr )   -> element.trigger( 'ajax:success', [data, status, xhr] )
            error:      ( xhr, status, error )  -> element.trigger( 'ajax:error', [xhr, status, error] )

        data.context.remove() if data.context && settings.remove_completed_progress_bar # remove progress bar
        $uploaderElement.trigger("s3_upload_complete", [content])

        current_files.splice($.inArray(data, current_files), 1) # remove that element from the array
        $uploaderElement.trigger("s3_uploads_complete", [content]) unless current_files.length

      fail: (e, data) ->
        content = build_content_object $uploaderElement, data.files[0], data.result
        content.error_thrown = data.errorThrown

        data.context.remove() if data.context && settings.remove_failed_progress_bar # remove progress bar
        $uploaderElement.trigger("s3_upload_failed", [content])

      formData: (form) ->
        data = $('.s3upload_hidden_fields').serializeArray()
        fileType = ""
        if "type" of @files[0]
          fileType = @files[0].type
        data.push
          name: "Content-Type"
          value: fileType

        # substitute upload timestamp and unique_id into key
        key = data[1].value.replace('{timestamp}', new Date().getTime()).replace('{unique_id}', @files[0].unique_id)
        data[1].value = settings.path + key
        data

  build_content_object = ($uploaderElement, file, result) ->
    content = {}
    if result # Use the S3 response to set the URL to avoid character encodings bugs
      content.url      = $(result).find("Location").text()
      content.filepath = $('<a />').attr('href', content.url)[0].pathname
    #else # IE <= 9 return a null result object so we use the file object instead
      #domain           = $uploaderElement.attr('action')
      #content.filepath = settings.path + $uploaderElement.find('input[name=key]').val().replace('/${filename}', '')
      #content.url      = domain + content.filepath + '/' + encodeURIComponent(file.name)

    content.filename   = file.name
    content.filesize   = file.size if 'size' of file
    content.filetype   = file.type if 'type' of file
    content.unique_id  = file.unique_id if 'unique_id' of file
    content.relativePath = build_relativePath(file) if has_relativePath(file)
    content = $.extend content, settings.additional_data if settings.additional_data
    content

  has_relativePath = (file) ->
    file.relativePath || file.webkitRelativePath

  build_relativePath = (file) ->
    file.relativePath || (file.webkitRelativePath.split("/")[0..-2].join("/") + "/" if file.webkitRelativePath)


  #public methods
  @initialize = ->
    setUploadElement()
    this

  @path = (new_path) ->
    settings.path = new_path

  @additional_data = (new_data) ->
    settings.additional_data = new_data

  @initialize()
