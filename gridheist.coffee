# ==============================================================
# gridheist.js v0.0.3
# A jQuery plugin to hijack an image gallery, making it great.
# http://github.com/cavis/gridheist
# ==============================================================
# Copyright (c) 2013 Ryan Cavis
# Licensed under http://en.wikipedia.org/wiki/MIT_License
# ==============================================================
(($, window) ->

  #
  # the proper gridheist class
  #
  class GridHeist

    # public methods
    public:
      update: true

    # config options
    defaults:
      thumbSelector:    '> *'
      thumbBorder:      10
      thumbMinHeight:   200
      thumbMaxHeight:   null
      preloadImages:    true
      expandHeight:     300
      expandSideWidth:  200
      expandSideRender: false

    # initialize it!
    constructor: (el, options) ->
      @options = $.extend({}, @defaults, options)
      if @options.thumbMaxHeight && @options.thumbMaxHeight < @options.thumbMinHeight
        @options.thumbMinHeight = @options.thumbMaxHeight

      # gallery element
      @$el = $(el)
      @$el.addClass('gridheist-gallery')
      @$el.on 'click', '.gridheist-thumb', @clickHandler

      # bind some events (global level, so we can dynamically add thumbs)
      @$el.on 'click', '.gridheist-left',  => @moveLeft()
      @$el.on 'click', '.gridheist-right', => @moveRight()
      @$el.on 'click', '.gridheist-close', => @closeExpander()

      # initial update/layout
      @update()

      # track changes to the width
      $(window).resize => @doLayout() unless @width == @$el.width()

    # refresh thumbs
    update: ->
      @$thumbs = @$el.find(@options.thumbSelector)
      @$thumbs.addClass('gridheist-thumb')
      @doLayout()

    # re-distribute the thumbnails
    doLayout: ->
      @closeExpander()
      @width = @$el.width()
      @rows = []

      # pad everything according to thumbBorder
      margin = "0 #{@options.thumbBorder}px #{@options.thumbBorder}px 0"
      @$thumbs.css('margin', margin)

      # kick off processing the first thumbnail
      @processThumb(0, 0, 0)

    # recursively process thumbnails
    processThumb: (idx, rowIdx, rowWidth) ->
      if idx < @$thumbs.length

        # cache the jquery objects; get the native <img> width
        $thumb = @$thumbs.eq(idx)
        $img = $thumb.find('img')
        @getDimensions $img, (imgWidth, imgHeight) =>
          unless @rows[rowIdx]
            @rows[rowIdx] = {thumbs: [], images: [], widths: [], heights: []}

          # optionally scale DOWN to height
          if @options.thumbMaxHeight && imgHeight > @options.thumbMaxHeight
            imgWidth = (@options.thumbMaxHeight / imgHeight) * imgWidth
            imgHeight = @options.thumbMaxHeight
            $img.attr('width', imgWidth)
            $img.attr('height', imgHeight)

          # add to the row
          @rows[rowIdx].thumbs.push($thumb)
          @rows[rowIdx].images.push($img)
          @rows[rowIdx].widths.push(imgWidth)
          @rows[rowIdx].heights.push(imgHeight)
          $thumb.data('row', rowIdx)

          # compute the new width of the row
          rowWidth += @options.thumbBorder unless rowWidth == 0
          rowWidth += imgWidth

          # layout the row, if we've passed the max width
          if rowWidth >= @width
            @layoutRow(rowIdx, rowWidth)
            @processThumb(idx + 1, rowIdx + 1, 0)
          else
            @processThumb(idx + 1, rowIdx, rowWidth)

      # layout last non-full row, and start pre-loading the big images
      else
        @layoutRow(rowIdx, rowWidth) if @rows[rowIdx]
        @preload() if @options.preloadImages

    # expand a row to fill the full width
    layoutRow: (rowIdx, rowWidth) ->
      minHeight = 9999
      for h, idx in @rows[rowIdx].heights
        minHeight = h if h < minHeight
      minHeight = Math.max(@options.thumbMinHeight, minHeight)

      # number of px to compress
      rowDebt = Math.max(rowWidth - @width, 0)

      # subtract the difference from each row
      for $thumb, idx in @rows[rowIdx].thumbs
        thumbDebt = Math.ceil(rowDebt / (@rows[rowIdx].thumbs.length - idx))
        rowDebt -= thumbDebt

        # chop the sides off the image
        $thumb.css('width', @rows[rowIdx].widths[idx] - thumbDebt)
        $thumb.css('height', minHeight)

        # center the image
        center = Math.floor(thumbDebt / 2)
        vertic = Math.floor((@rows[rowIdx].heights[idx] - minHeight) / 2)
        @rows[rowIdx].images[idx].css('margin-left', -center)
        @rows[rowIdx].images[idx].css('margin-top', -vertic)

        # no margin-right on the last one
        if idx == @rows[rowIdx].thumbs.length - 1
          margin = "0 0 #{@options.thumbBorder}px 0"
          $thumb.css('margin', margin)

    # helper to calculate native image dimensions
    getDimensions: ($img, callback) ->
      if (w = $img.data('width')) && (h = $img.data('height'))
        callback(w, h)
      else
        tmp = new Image() # slow - load a temp image to check width
        $(tmp)
          .load ->
            $img.data('width', tmp.width)
            $img.data('height', tmp.height)
            callback(tmp.width, tmp.height)
          .error ->
            console.error('An error occurred and your image could not be loaded.  Please try again.')
            callback(100, 100)
          .attr
            src: $img.attr('src')

    # preload the big images
    preload: ->
      @$thumbs.each (idx, thumb) -> (new Image()).src = $(thumb).attr('href')

    # handle clicking on a thumbnail
    clickHandler: (e) =>
      e.preventDefault()
      $thumb = $(e.currentTarget)
      @expandThumb($thumb) unless $thumb.hasClass('expanded')

    # flip to the left
    moveLeft: (e) =>
      $curr = @$el.find('.gridheist-thumb.expanded')
      $prev = $curr.prevAll('.gridheist-thumb').first()
      if $prev.length > 0 then @expandThumb($prev, 'up') else @closeExpander()

    # flip to the right
    moveRight: (e) =>
      $curr = @$el.find('.gridheist-thumb.expanded')
      $next = $curr.nextAll('.gridheist-thumb').first()
      if $next.length > 0 then @expandThumb($next, 'down') else @closeExpander()

    # handle left/right/escape keys
    keyHandler: (e) =>
      code = e.keyCode || e.which
      @moveLeft() if code == 37
      @moveRight() if code == 39
      @closeExpander if code == 27 # escape

    # render the row-expander for a thumbnail
    expandThumb: ($thumb, doScroll=null) ->
      rowIdx     = $thumb.data('row')
      imgSrc     = $thumb.attr('href')
      $lastThumb = @rows[rowIdx].thumbs[@rows[rowIdx].thumbs.length - 1]
      scrollTo   = null

      # helper class to indicate what's expanded
      @$el.find('.gridheist-thumb.expanded').removeClass('expanded')
      $thumb.addClass('expanded')

      # compute any scrolling we're going to do
      if doScroll
        scrollTo = $('body').scrollTop()
        diff = @options.thumbBorder + $thumb.height()
        if doScroll == 'up' then scrollTo -= diff else scrollTo += diff

      # render expander container, bind key events
      if !@$expander
        doScroll = false # never!
        @$expander = $('<div class="gridheist-expander"></div>')
        $(document).on('keydown', @keyHandler)
      else if !@$expander.prev().is($lastThumb)
        @$expander.remove()
        @$expander = $('<div class="gridheist-expander"></div>')
      else
        doScroll = false # never!
        @$expander.html('')

      # update interior style
      @$expander.css('margin-bottom', @options.thumbBorder)
      @$expander.css('height', @options.expandHeight)

      # optional sidebar (content dynamically created)
      if @options.expandSideRender
        width = @options.expandSideWidth
        @$expander.append("""
          <div class="gridheist-expander-side" style="width:#{width}px">
            <div class="gridheist-expander-seperator"></div>
            <div class="gridheist-expander-content">
              #{@options.expandSideRender($thumb)}
            </div>
          </div>
        """)

      # arrow to expanded img, left/right nav, and close button
      align = $thumb.position().left + ($thumb.width() / 2)
      bordr = @options.thumbBorder
      @$expander.append("""
        <div class="gridheist-expander-arrow" style="left:#{align}px;
          border-width:#{bordr}px; margin-left:-#{bordr}px;">
        </div>
        <div class="gridheist-left">&lsaquo;</div>
        <div class="gridheist-right">&rsaquo;</div>
        <div class="gridheist-close">&times;</div>
      """)

      # disable selections
      @$expander.find('.gridheist-left, .gridheist-right, .gridheist-close')
        .attr('unselectable', 'on').css('user-select', 'none').on('selectstart', false);

      # add the image
      @$expander.append("""
        <div class="gridheist-expander-img">
          <img src="#{imgSrc}"/>
        </div>
      """)

      # optionally render and scroll
      $lastThumb.after(@$expander) unless @$expander.parent().length
      $('body').scrollTop(scrollTo) if doScroll

    # close down the expander and remove key listeners
    closeExpander: ->
      @$el.find('.expanded').removeClass('expanded')
      if @$expander
        @$expander.remove()
        @$expander = undefined
        $(document).off('keydown', @keyHandler)

  #
  # define the plugin function
  #
  $.fn.extend gridHeist: (option, args...) ->
    @each ->
      $this = $(this)
      data = $this.data('gridHeist')

      # initialize a new plugin
      if !data
        $this.data 'gridHeist', (data = new GridHeist(this, option))

      # run a public method
      if typeof option == 'string' && data.public[option]
        data[option].apply(data, args)

) window.jQuery, window
