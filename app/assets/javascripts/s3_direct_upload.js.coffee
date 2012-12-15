(($) ->
  $.widget("waynehoover.s3upload", {
    options: {
      path: ''
      additional_data: null
      remove_completed_progress_bar: true

      before_add: null
      start: null
    }
    _create: ->
      @current_files = []
      @form = $(this.element.prop("form"))
      that = @

      @element.fileupload
        add: (e, data) =>
          @current_files.push data
          file = data.files[0]
          if @_trigger("before_add", null, {file: file})
            data.context = $(tmpl("template-upload", file)) if $('#template-upload').length > 0
            @form.append(data.context)
            data.submit()

        start: (e) =>
          @_trigger("start")

        progress: (e, data) =>
          data = $.extend({}, data, {percentage: parseInt(data.loaded / data.total * 100, 10)})
          data.context.find('.bar').css('width', data.percentage + '%') if data.context
          @_trigger("progress", e, data)

        done: (e, data) =>
          content = @_buildContentObject data.files[0], data.result

          to = @form.data('post')
          if to
            content[@form.data('as')] = content.url
            $.post(to, content)

          data.context.remove() if data.context && @options.remove_completed_progress_bar # remove progress bar

          @current_files.splice($.inArray(data, @current_files), 1) # remove that element from the array
          @_trigger("done", e, content) unless @current_files.length

        fail: (e, data) =>
          content = @_buildContentObject data.files[0], data.result
          content.error_thrown = data.errorThrown
          @_trigger("fail", e, content)

        formData: (form) ->
          data = form.serializeArray()
          fileType = ""
          if "type" of @files[0]
            fileType = @files[0].type
          data.push
            name: "Content-Type"
            value: fileType

          data[1].value = that.options.path + data[1].value

          data

    _buildContentObject: (file, result) ->
      domain = @form.attr('action')
      content = {}
      if result # Use the S3 response to set the URL to avoid character encodings bugs
        path             = $('Key', result).text()
        split_path       = path.split('/')
        content.url      = domain + path
        content.filename = split_path[split_path.length - 1]
        content.filepath = split_path.slice(0, split_path.length - 1).join('/')
      else # IE8 and IE9 return a null result object so we use the file object instead
        path             = @options.path + @form.find('input[name=key]').val().replace('/${filename}', '')
        content.url      = domain + path + '/' + file.name
        content.filename = file.name
        content.filepath = path

      content.filekey = "#{content.filepath}/#{content.filename}"
      content.filesize   = file.size if 'size' of file
      content.filetype   = file.type if 'type' of file
      content = $.extend content, @options.additional_data if @options.additional_data
      content

    path: (new_path) ->
      @options.path = new_path

    additional_data: (new_data) ->
      @options.additional_data = new_data
  })
)(jQuery)
