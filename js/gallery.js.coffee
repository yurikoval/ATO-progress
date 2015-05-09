loadJSON = (file, callback) ->
  xobj = new XMLHttpRequest
  xobj.overrideMimeType 'application/json'
  xobj.open 'GET', file, true
  xobj.onreadystatechange = ->
    if xobj.readyState == 4 and xobj.status == 200
      # Required use of an anonymous callback as .open will NOT return a value but simply returns undefined in asynchronous mode
      callback xobj.responseText
    return

  xobj.send null
  return

Gallery = (options) ->
  @images = ko.observableArray(options.images)
  @current_image = ko.observable(@images()[@images().length-1])
  return @

loadJSON 'img/images.json', (data) ->
  window.images_json = JSON.parse data
  window.gallery = new Gallery(images_json)
  ko.applyBindings(gallery)
