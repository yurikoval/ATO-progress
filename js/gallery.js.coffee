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
  @imageIsLoading = ko.observable(false)
  @images = ko.observableArray(options.images)
  @current_image_index = ko.observable(@images().length-1)
  @current_image = ko.pureComputed(=> @images()[@current_image_index()])
  @showPrevious = -> @current_image_index(Math.max(@current_image_index()-1, 0))
  @showNext = -> @current_image_index(Math.min(@current_image_index()+1, @images().length-1))
  @avaiableDates = @images().map((image) -> image.date)
  @updateImageByDate = (event) =>
    for image, index in @images()
      if image.date == event.target.value
        @current_image_index(index)
        break and return true

  @current_image_index.subscribe =>
    @imageIsLoading(true)
    imagesLoaded '#image', => @imageIsLoading(false)

  $('#date').datepicker
    autoclose: true
    beforeShowDay: (d) =>
      date = "#{d.getFullYear()}-#{('0'+(d.getMonth()+1)).slice(-2)}-#{('0' + d.getDate()).slice(-2)}"
      date in @avaiableDates
    format: 'yyyy-mm-dd'
  $(document).on 'changeDate', @updateImageByDate.bind(this)

  return @

$ ->
  loadJSON 'img/images.json', (data) ->
    images_json = JSON.parse data
    window.gallery = new Gallery(images_json)
    ko.applyBindings(gallery)
