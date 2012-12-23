#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

$ = jQuery

$.fn.S3Uploader = (options) ->

  # support multiple elements
  if @length > 1
    @each ->
      $(this).S3Uploader options

    return this

  $uploadForm = this

  settings =
    path: ''
    additional_data: null
    before_add: null
    remove_completed_progress_bar: true

  $.extend settings, options

  current_files = []

  setUploadForm = ->
    $uploadForm.fileupload

      add: (e, data) ->
        current_files.push data
        file = data.files[0]
        unless settings.before_add and not settings.before_add(file)
          data.context = $(tmpl("template-upload", file)) if $('#template-upload').length > 0
          $uploadForm.append(data.context)
          data.submit()

      start: (e) ->
        $uploadForm.trigger("s3_uploads_start", [e])

      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find('.bar').css('width', progress + '%')

      done: (e, data) ->
        content = build_content_object $uploadForm, data.files[0], data.result

        to = $uploadForm.data('post')
        if to
          content[$uploadForm.data('as')] = content.url
          $.post(to, content)

        data.context.remove() if data.context && settings.remove_completed_progress_bar # remove progress bar

        current_files.splice($.inArray(data, current_files), 1) # remove that element from the array
        $uploadForm.trigger("s3_uploads_complete", [content]) unless current_files.length

      fail: (e, data) ->
        content = build_content_object $uploadForm, data.files[0], data.result
        content.error_thrown = data.errorThrown
        $uploadForm.trigger("s3_upload_failed", [content])

      formData: (form) ->
        data = form.serializeArray()
        fileType = ""
        if "type" of @files[0]
          fileType = @files[0].type
        data.push
          name: "Content-Type"
          value: fileType

        data[1].value = settings.path + data[1].value #the key
        data

  build_content_object = ($uploadForm, file, result) ->
    content = {}
    if result # Use the S3 response to set the URL to avoid character encodings bugs
      content.url      = $(result).find("Location").text()
      content.filepath = $('<a />').attr('href', content.url)[0].pathname
    else # IE <= 9 return a null result object so we use the file object instead
      domain           = $uploadForm.attr('action')
      content.filepath = settings.path + $uploadForm.find('input[name=key]').val().replace('/${filename}', '')
      content.url      = domain + content.filepath + '/' + file.name

    content.filename   = file.name
    content.filesize   = file.size if 'size' of file
    content.filetype   = file.type if 'type' of file
    content = $.extend content, settings.additional_data if settings.additional_data
    content

  #public methods
  @initialize = ->
    setUploadForm()
    this

  @path = (new_path) ->
    settings.path = new_path

  @additional_data = (new_data) ->
    settings.additional_data = new_data

  @initialize()
