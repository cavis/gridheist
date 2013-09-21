//
// gridheist config
//
var defaults = {
  thumbBorder:      10,
  thumbMinHeight:   100,
  thumbMaxHeight:   200,
  expander:         false,
  expandHeight:     300,
  expandSideWidth:  200,
  // non-gridheist
  layoutType: 'fluid',
  layoutFluidValue: 100,
  layoutFixedValue: 1000
}
var config = _.extend({}, defaults);

// load any stored configs
if (localStorage && localStorage.getItem('config')) {
  var json = JSON.parse(localStorage.getItem('config'));
  if (json) {
    config = _.extend(config, json);
  }
}

// set the layout type
var updateLayoutType = function() {
  if (config.layoutType == 'fluid') {
    $('#gallery').css({marginLeft: config.layoutFluidValue, marginRight: config.layoutFluidValue, width: 'auto'});
  }
  else {
    $('#gallery').css({marginLeft: 'auto', marginRight: 'auto', width: config.layoutFixedValue});
  }
}

// dom => config
var updateConfig = function() {
  config.layoutType = $('select[name="layoutType"]').val();
  config.layoutFluidValue = parseInt( $('input[name="layoutFluidValue"]').val() )
  config.layoutFixedValue = parseInt( $('input[name="layoutFixedValue"]').val() )
  updateLayoutType();

  config.thumbBorder    = parseInt( $('input[name="thumbBorder"]').val() );
  config.thumbMinHeight = parseInt( $('input[name="thumbMinHeight"]').val() );
  config.thumbMaxHeight = parseInt( $('input[name="thumbMaxHeight"]').val() );
  $('#gallery').gridHeist('update', config);

  // update storage
  if (localStorage) {
    localStorage.setItem('config', JSON.stringify(config));
  }
}

// config => dom
var updateDom = function() {
  $('select[name="layoutType"]').val(config.layoutType);
  $('input[name="layoutFluidValue"]').val(config.layoutFluidValue)
    .filter('[data-slider]').simpleSlider('setValue', config.layoutFluidValue);
  $('input[name="layoutFixedValue"]').val(config.layoutFixedValue)
    .filter('[data-slider]').simpleSlider('setValue', config.layoutFixedValue);

  if (config.layoutType == 'fluid') {
    $('.layout-fluid').show() && $('.layout-fixed').hide();
  }
  else {
    $('.layout-fluid').hide() && $('.layout-fixed').show();
  }

  $('input[name="thumbBorder"]').val(config.thumbBorder)
    .filter('[data-slider]').simpleSlider('setValue', config.thumbBorder);
  $('input[name="thumbMinHeight"]').val(config.thumbMinHeight)
    .filter('[data-slider]').simpleSlider('setValue', config.thumbMinHeight);
  $('input[name="thumbMaxHeight"]').val(config.thumbMaxHeight)
    .filter('[data-slider]').simpleSlider('setValue', config.thumbMaxHeight);
}

// dom it!
$(function() {
  updateDom();
  updateLayoutType();

  // insert images
  $.getJSON('dynamic.json', function(data) {
    var $gallery = $('#gallery').html('');

    if (data && data.hits && data.hits.length) {
      for (var i=0; i<data.hits.length; i++) {
        var w = data.hits[i].webformatWidth,
            h = data.hits[i].webformatHeight,
            sm = data.hits[i].webformatURL,
            lg = data.hits[i].webformatURL;
        $gallery.append('<a class="thumb" href="'+lg+'"><img data-width="'+w+'" data-height="'+h+'" src="'+sm+'"/></a>');
      }

      $gallery.gridHeist(config);
    }
  });

  // sync sliders
  $('input[data-slider]').on('slider:changed', function(e, data) {
    $('[name="' + $(this).attr('name') + '"]').val(data.value);
  });

  // layout change
  $('input').on('change', updateConfig);
  $('select').on('change', function() {
    $('input').off('change', updateConfig);
    if ($(this).val() == 'fluid') {
      $('.layout-fluid').show() && $('.layout-fixed').hide();
      $('input[name="layoutFluidValue"]').val(100).filter('[data-slider]').simpleSlider('setValue', 100);
    }
    else {
      $('.layout-fluid').hide() && $('.layout-fixed').show();
      $('input[name="layoutFixedValue"]').val(1000).filter('[data-slider]').simpleSlider('setValue', 1000);
    }
    updateConfig();
    $('input').on('change', updateConfig);
  });

  // revert to defaults
  $('h2.reset').click(function() {
    alert('Reset to defaults');
    config = _.extend({}, defaults);
    if (localStorage) localStorage.clear();
    $('input').off('change', updateConfig);
    updateDom();
    $('input').on('change', updateConfig);
    $('#gallery').gridHeist('update', config);
  });

});
