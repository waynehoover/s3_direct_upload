#= require jquery-fileupload/basic
#= require jquery-fileupload/vendor/tmpl

jQuery ->
  $('#fileupload').fileupload
    add: (e, data) ->
      file = data.files[0]
      data.context = $(tmpl("template-upload", file))
      $('#fileupload').append(data.context)
      data.submit()
      
    progress: (e, data) ->
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
    
    done: (e, data) ->
      file = data.files[0]
      domain = $('#fileupload').attr('action')
      path = $('#fileupload input[name=key]').val().replace('${filename}', file.name)
      to = $('#fileupload').data('post')
      content = {}
      content[$('#fileupload').data('as')] = domain + path
      $.post(to, content)
      data.context.remove() if data.context # remove progress bar
    
    fail: (e, data) ->
      alert("#{data.files[0].name} failed to upload.")
      console.log("Upload failed:")
      console.log(data)

    formData: (form) ->
      data = form.serializeArray()
      fileType = ""
      if "type" of @files[0]
        fileType = @files[0].type
      data.push
        name: "Content-Type"
        value: fileType

      data

