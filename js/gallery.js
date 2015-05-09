(function() {
  var Gallery, loadJSON;

  loadJSON = function(file, callback) {
    var xobj;
    xobj = new XMLHttpRequest;
    xobj.overrideMimeType('application/json');
    xobj.open('GET', file, true);
    xobj.onreadystatechange = function() {
      if (xobj.readyState === 4 && xobj.status === 200) {
        callback(xobj.responseText);
      }
    };
    xobj.send(null);
  };

  Gallery = function(options) {
    this.imageIsLoading = ko.observable(false);
    this.images = ko.observableArray(options.images);
    this.current_image_index = ko.observable(this.images().length - 1);
    this.current_image = ko.pureComputed((function(_this) {
      return function() {
        return _this.images()[_this.current_image_index()];
      };
    })(this));
    this.showPrevious = function() {
      return this.current_image_index(Math.max(this.current_image_index() - 1, 0));
    };
    this.showNext = function() {
      return this.current_image_index(Math.min(this.current_image_index() + 1, this.images().length - 1));
    };
    this.current_image_index.subscribe((function(_this) {
      return function() {
        _this.imageIsLoading(true);
        return imagesLoaded('#image', function() {
          return _this.imageIsLoading(false);
        });
      };
    })(this));
    return this;
  };

  loadJSON('img/images.json', function(data) {
    var gallery, images_json;
    images_json = JSON.parse(data);
    gallery = new Gallery(images_json);
    return ko.applyBindings(gallery);
  });

}).call(this);
