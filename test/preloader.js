//
// preload image testing
//
var config = {
  thumbBorder:      10,
  thumbMinHeight:   100,
  thumbMaxHeight:   150,
  expander:         true,
  expandHeight:     300,
  expandSideWidth:  200,
  preloadImages:    false
}

// helper to get query params
var qs = function(key) {
    key = key.replace(/[*+?^$.\[\]{}()|\\\/]/g, "\\$&"); // escape RegEx meta chars
    var match = location.search.match(new RegExp("[?&]"+key+"=([^&]+)(&|$)"));
    return match && decodeURIComponent(match[1].replace(/\+/g, " "));
}

// dom it!
$(function() {

  // update form
  if (before = qs('preloadBefore')) {
    $('input[name="preloadBefore"]').val(before);
  }
  if (after = qs('preloadAfter')) {
    $('input[name="preloadAfter"]').val(after);
  }

  // insert images
  $.getJSON('preloader.json', function(data) {
    var $gallery = $('#gallery').html('');

    if (data && data.hits && data.hits.length) {
      var cb = Math.round(new Date().getTime() / 1000); //bust the cache
      for (var i=0; i<data.hits.length; i++) {
        var w = data.hits[i].webformatWidth,
            h = data.hits[i].webformatHeight,
            sm = data.hits[i].webformatURL + '?_cb=' + cb,
            lg = data.hits[i].bigformatURL + '?_cb=' + cb;
        $gallery.append('<a class="thumb" href="'+lg+'"><img data-width="'+w+'" data-height="'+h+'" src="'+sm+'"/></a>');
      }

      $gallery.gridHeist(config);
    }
  });



});
