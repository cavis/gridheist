// ==============================================================
// gridheist.js v0.0.4
// A jQuery plugin to hijack an image gallery, making it great.
// http://github.com/cavis/gridheist
// ==============================================================
// Copyright (c) 2013 cav.is
// Licensed under http:#en.wikipedia.org/wiki/MIT_License
// ==============================================================
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __slice = [].slice;

  (function($, window) {
    var GridHeist;
    GridHeist = (function() {
      GridHeist.prototype["public"] = {
        update: true
      };

      GridHeist.prototype.defaults = {
        thumbSelector: '> *',
        thumbBorder: 10,
        thumbMinHeight: 200,
        thumbMaxHeight: null,
        preloadImages: true,
        expander: true,
        expandHeight: 300,
        expandSideWidth: 200,
        expandSideRender: false
      };

      function GridHeist(el, options) {
        this.keyHandler = __bind(this.keyHandler, this);
        this.moveRight = __bind(this.moveRight, this);
        this.moveLeft = __bind(this.moveLeft, this);
        this.clickHandler = __bind(this.clickHandler, this);
        var _this = this;
        this.options = $.extend({}, this.defaults, options);
        if (this.options.thumbMaxHeight && this.options.thumbMaxHeight < this.options.thumbMinHeight) {
          this.options.thumbMinHeight = this.options.thumbMaxHeight;
        }
        this.$el = $(el);
        this.$el.addClass('gridheist-gallery');
        this.$el.on('click', '.gridheist-thumb', this.clickHandler);
        this.$el.on('click', '.gridheist-left', function() {
          return _this.moveLeft();
        });
        this.$el.on('click', '.gridheist-right', function() {
          return _this.moveRight();
        });
        this.$el.on('click', '.gridheist-close', function() {
          return _this.closeExpander();
        });
        this.update();
        $(window).resize(function() {
          if (_this.width !== _this.$el.width()) {
            return _this.doLayout();
          }
        });
      }

      GridHeist.prototype.update = function(overrides) {
        if (overrides == null) {
          overrides = {};
        }
        $.extend(this.options, overrides);
        if (this.$thumbs) {
          this.$thumbs.unwrap();
        }
        this.$thumbs = this.$el.find(this.options.thumbSelector);
        this.$thumbs.addClass('gridheist-thumb');
        this.$thumbs.wrapAll('<div class="gridheist-wrap"></div>');
        this.$wrap = this.$el.find('.gridheist-wrap');
        return this.doLayout();
      };

      GridHeist.prototype.doLayout = function() {
        var margin;
        this.closeExpander();
        this.width = this.$el.width();
        this.$wrap.width(this.width);
        this.rows = [];
        margin = "0 " + this.options.thumbBorder + "px " + this.options.thumbBorder + "px 0";
        this.$thumbs.css('margin', margin);
        return this.processThumb(0, 0, 0);
      };

      GridHeist.prototype.processThumb = function(idx, rowIdx, rowWidth) {
        var $img, $thumb,
          _this = this;
        if (idx < this.$thumbs.length) {
          $thumb = this.$thumbs.eq(idx);
          $img = $thumb.find('img');
          return this.getDimensions($img, function(imgWidth, imgHeight) {
            if (!_this.rows[rowIdx]) {
              _this.rows[rowIdx] = {
                thumbs: [],
                images: [],
                widths: [],
                heights: []
              };
            }
            if (_this.options.thumbMaxHeight && imgHeight > _this.options.thumbMaxHeight) {
              imgWidth = Math.floor((_this.options.thumbMaxHeight / imgHeight) * imgWidth);
              imgHeight = _this.options.thumbMaxHeight;
              $img.attr('width', imgWidth);
              $img.attr('height', imgHeight);
            }
            _this.rows[rowIdx].thumbs.push($thumb);
            _this.rows[rowIdx].images.push($img);
            _this.rows[rowIdx].widths.push(imgWidth);
            _this.rows[rowIdx].heights.push(imgHeight);
            $thumb.data('row', rowIdx);
            if (rowWidth !== 0) {
              rowWidth += _this.options.thumbBorder;
            }
            rowWidth += imgWidth;
            if (rowWidth >= _this.width) {
              _this.layoutRow(rowIdx, rowWidth);
              return _this.processThumb(idx + 1, rowIdx + 1, 0);
            } else {
              return _this.processThumb(idx + 1, rowIdx, rowWidth);
            }
          });
        } else {
          if (this.rows[rowIdx]) {
            this.layoutRow(rowIdx, rowWidth);
          }
          if (this.options.preloadImages) {
            return this.preload();
          }
        }
      };

      GridHeist.prototype.layoutRow = function(rowIdx, rowWidth) {
        var $thumb, center, h, idx, margin, minHeight, rowDebt, thumbDebt, vertic, _i, _j, _len, _len1, _ref, _ref1, _results;
        minHeight = 9999;
        _ref = this.rows[rowIdx].heights;
        for (idx = _i = 0, _len = _ref.length; _i < _len; idx = ++_i) {
          h = _ref[idx];
          if (h < minHeight) {
            minHeight = h;
          }
        }
        minHeight = Math.max(this.options.thumbMinHeight, minHeight);
        rowDebt = Math.max(rowWidth - this.width, 0);
        _ref1 = this.rows[rowIdx].thumbs;
        _results = [];
        for (idx = _j = 0, _len1 = _ref1.length; _j < _len1; idx = ++_j) {
          $thumb = _ref1[idx];
          thumbDebt = Math.ceil(rowDebt / (this.rows[rowIdx].thumbs.length - idx));
          rowDebt -= thumbDebt;
          $thumb.css('width', this.rows[rowIdx].widths[idx] - thumbDebt);
          $thumb.css('height', minHeight);
          center = Math.floor(thumbDebt / 2);
          vertic = Math.floor((this.rows[rowIdx].heights[idx] - minHeight) / 2);
          this.rows[rowIdx].images[idx].css('margin-left', -center);
          this.rows[rowIdx].images[idx].css('margin-top', -vertic);
          if (idx === this.rows[rowIdx].thumbs.length - 1) {
            margin = "0 0 " + this.options.thumbBorder + "px 0";
            _results.push($thumb.css('margin', margin));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      GridHeist.prototype.getDimensions = function($img, callback) {
        var h, tmp, w;
        if ((w = $img.data('width')) && (h = $img.data('height'))) {
          return callback(w, h);
        } else {
          tmp = new Image();
          return $(tmp).load(function() {
            $img.data('width', tmp.width);
            $img.data('height', tmp.height);
            return callback(tmp.width, tmp.height);
          }).error(function() {
            console.error('An error occurred and your image could not be loaded.  Please try again.');
            return callback(100, 100);
          }).attr({
            src: $img.attr('src')
          });
        }
      };

      GridHeist.prototype.preload = function() {
        return this.$thumbs.each(function(idx, thumb) {
          return (new Image()).src = $(thumb).attr('href');
        });
      };

      GridHeist.prototype.clickHandler = function(e) {
        var $thumb;
        e.preventDefault();
        $thumb = $(e.currentTarget);
        if (this.options.expander && !$thumb.hasClass('expanded')) {
          return this.expandThumb($thumb);
        }
      };

      GridHeist.prototype.moveLeft = function(e) {
        var $curr, $prev;
        $curr = this.$el.find('.gridheist-thumb.expanded');
        $prev = $curr.prevAll('.gridheist-thumb').first();
        if ($prev.length > 0) {
          return this.expandThumb($prev, 'up');
        } else {
          return this.closeExpander();
        }
      };

      GridHeist.prototype.moveRight = function(e) {
        var $curr, $next;
        $curr = this.$el.find('.gridheist-thumb.expanded');
        $next = $curr.nextAll('.gridheist-thumb').first();
        if ($next.length > 0) {
          return this.expandThumb($next, 'down');
        } else {
          return this.closeExpander();
        }
      };

      GridHeist.prototype.keyHandler = function(e) {
        var code;
        code = e.keyCode || e.which;
        if (code === 37) {
          this.moveLeft();
        }
        if (code === 39) {
          this.moveRight();
        }
        if (code === 27) {
          return this.closeExpander;
        }
      };

      GridHeist.prototype.expandThumb = function($thumb, doScroll) {
        var $lastThumb, align, bordr, diff, imgSrc, rowIdx, scrollTo, width;
        if (doScroll == null) {
          doScroll = null;
        }
        rowIdx = $thumb.data('row');
        imgSrc = $thumb.attr('href');
        $lastThumb = this.rows[rowIdx].thumbs[this.rows[rowIdx].thumbs.length - 1];
        scrollTo = null;
        this.$el.find('.gridheist-thumb.expanded').removeClass('expanded');
        $thumb.addClass('expanded');
        if (doScroll) {
          scrollTo = $('body').scrollTop();
          diff = this.options.thumbBorder + $thumb.height();
          if (doScroll === 'up') {
            scrollTo -= diff;
          } else {
            scrollTo += diff;
          }
        }
        if (!this.$expander) {
          doScroll = false;
          this.$expander = $('<div class="gridheist-expander"></div>');
          $(document).on('keydown', this.keyHandler);
        } else if (!this.$expander.prev().is($lastThumb)) {
          this.$expander.remove();
          this.$expander = $('<div class="gridheist-expander"></div>');
        } else {
          doScroll = false;
          this.$expander.html('');
        }
        this.$expander.css('margin-bottom', this.options.thumbBorder);
        this.$expander.css('height', this.options.expandHeight);
        if (this.options.expandSideRender) {
          width = this.options.expandSideWidth;
          this.$expander.append("<div class=\"gridheist-expander-side\" style=\"width:" + width + "px\">\n  <div class=\"gridheist-expander-seperator\"></div>\n  <div class=\"gridheist-expander-content\">\n    " + (this.options.expandSideRender($thumb)) + "\n  </div>\n</div>");
        }
        align = $thumb.position().left + ($thumb.width() / 2);
        bordr = this.options.thumbBorder;
        this.$expander.append("<div class=\"gridheist-expander-arrow\" style=\"left:" + align + "px;\n  border-width:" + bordr + "px; margin-left:-" + bordr + "px;\">\n</div>\n<div class=\"gridheist-left\">&lsaquo;</div>\n<div class=\"gridheist-right\">&rsaquo;</div>\n<div class=\"gridheist-close\">&times;</div>");
        this.$expander.find('.gridheist-left, .gridheist-right, .gridheist-close').attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false);
        this.$expander.append("<div class=\"gridheist-expander-img\">\n  <img src=\"" + imgSrc + "\"/>\n</div>");
        if (!this.$expander.parent().length) {
          $lastThumb.after(this.$expander);
        }
        if (doScroll) {
          return $('body').scrollTop(scrollTo);
        }
      };

      GridHeist.prototype.closeExpander = function() {
        this.$el.find('.expanded').removeClass('expanded');
        if (this.$expander) {
          this.$expander.remove();
          this.$expander = void 0;
          return $(document).off('keydown', this.keyHandler);
        }
      };

      return GridHeist;

    })();
    return $.fn.extend({
      gridHeist: function() {
        var args, option;
        option = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        return this.each(function() {
          var $this, data;
          $this = $(this);
          data = $this.data('gridHeist');
          if (!data) {
            $this.data('gridHeist', (data = new GridHeist(this, option)));
          }
          if (typeof option === 'string' && data["public"][option]) {
            return data[option].apply(data, args);
          }
        });
      }
    });
  })(window.jQuery, window);

}).call(this);

