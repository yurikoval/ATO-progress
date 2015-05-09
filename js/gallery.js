(function() {
  var Gallery, loadJSON,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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
    this.showPreviousEnabled = ko.pureComputed((function(_this) {
      return function() {
        return _this.current_image_index() > 0;
      };
    })(this));
    this.showNextEnabled = ko.pureComputed((function(_this) {
      return function() {
        return _this.current_image_index() < _this.images().length - 1;
      };
    })(this));
    this.avaiableDates = this.images().map(function(image) {
      return image.date;
    });
    this.updateImageByDate = (function(_this) {
      return function(event) {
        var i, image, index, len, ref;
        ref = _this.images();
        for (index = i = 0, len = ref.length; i < len; index = ++i) {
          image = ref[index];
          if (image.date === event.target.value) {
            _this.current_image_index(index);
            return true;
          }
        }
      };
    })(this);
    this.current_image_index.subscribe((function(_this) {
      return function() {
        _this.imageIsLoading(true);
        return imagesLoaded('#image', function() {
          return _this.imageIsLoading(false);
        });
      };
    })(this));
    $('#date').datepicker({
      autoclose: true,
      beforeShowDay: (function(_this) {
        return function(d) {
          var date;
          date = (d.getFullYear()) + "-" + (('0' + (d.getMonth() + 1)).slice(-2)) + "-" + (('0' + d.getDate()).slice(-2));
          return indexOf.call(_this.avaiableDates, date) >= 0;
        };
      })(this),
      format: 'yyyy-mm-dd'
    });
    $(document).on('changeDate', this.updateImageByDate.bind(this));
    return this;
  };

  $(function() {
    return loadJSON('img/images.json', function(data) {
      var images_json;
      images_json = JSON.parse(data);
      window.gallery = new Gallery(images_json);
      return ko.applyBindings(gallery);
    });
  });

}).call(this);
