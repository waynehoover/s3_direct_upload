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

      progress: (e, data) ->
        if data.context
          progress = parseInt(data.loaded / data.total * 100, 10)
          data.context.find('.bar').css('width', progress + '%')

      done: (e, data) ->
        content = build_content_object $uploadForm, data.files[0]
        
        to = $uploadForm.data('post')
        if to
          content[$uploadForm.data('as')] = content.url
          $.post(to, content)
        
        data.context.remove() if data.context && settings.remove_completed_progress_bar # remove progress bar
        $uploadForm.trigger("s3_upload_complete", [content])

        current_files.splice($.inArray(data, current_files), 1) # remove that element from the array
        if current_files.length == 0
          $(document).trigger("s3_uploads_complete")

      fail: (e, data) ->
        content = build_content_object $uploadForm, data.files[0]
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

        data[1].value = settings.path + data[1].value

        data

  build_content_object = ($uploadForm, file) ->
    domain = $uploadForm.attr('action')
    path = settings.path + $uploadForm.find('input[name=key]').val().replace('/${filename}', '')
    content          = {}
    content.url      = domain + path + '/' + file.name
    content.filename = file.name
    content.filepath = path
    content.filesize = file.size if 'size' of file
    content.filetype = file.type if 'type' of file
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
