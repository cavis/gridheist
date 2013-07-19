# ==============================================================
# gridheist.js v0.0.1
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
      expandHeight:     300
      expandSideWidth:  200
      expandSideRender: false

    # initialize it!
    constructor: (el, options) ->
      @options = $.extend({}, @defaults, options)

      # gallery element
      @$el = $(el)
      @$el.addClass('gridheist-gallery')
      @$el.on 'click', '.gridheist-thumb', @clickHandler

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
      @$expander.remove() if @$expander
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
        @getImageWidth $img, (imgWidth) =>
          @rows[rowIdx] = {thumbs: [], images: [], widths: []} unless @rows[rowIdx]

          # add to the row
          @rows[rowIdx].thumbs.push($thumb)
          @rows[rowIdx].images.push($img)
          @rows[rowIdx].widths.push(imgWidth)
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

      # layout last non-full row
      else if @rows[rowIdx]
        @layoutRow(rowIdx, rowWidth)

    # expand a row to fill the full width
    layoutRow: (rowIdx, rowWidth) ->

      # number of px to compress
      rowDebt = Math.max(rowWidth - @width, 0)

      # subtract the difference from each row
      for $thumb, idx in @rows[rowIdx].thumbs
        thumbDebt = Math.ceil(rowDebt / (@rows[rowIdx].thumbs.length - idx))
        rowDebt -= thumbDebt

        # chop the sides off the image
        $thumb.css('width', @rows[rowIdx].widths[idx] - thumbDebt)

        # center the image
        center = Math.floor(thumbDebt / 2)
        @rows[rowIdx].images[idx].css('margin-left', -center)

        # no margin-right on the last one
        if idx == @rows[rowIdx].thumbs.length - 1
          margin = "0 0 #{@options.thumbBorder}px 0"
          $thumb.css('margin', margin)

    # helper to calculate an image width
    getImageWidth: ($img, callback) ->
      if w = $img.data('width')
        callback(w)
      else
        tmp = new Image() # slow - load a temp image to check width
        $(tmp)
          .load ->
            $img.data('width', tmp.width)
            callback(tmp.width)
          .error ->
            console.error('An error occurred and your image could not be loaded.  Please try again.')
            callback(0)
          .attr
            src: $img.attr('src')

    # handle clicking on a thumbnail
    clickHandler: (e, other) =>
      e.preventDefault()
      $target = $(e.currentTarget)
      rowIdx  = $target.data('row')
      href    = $target.attr('href')
      $last   = @rows[rowIdx].thumbs[@rows[rowIdx].thumbs.length - 1]
      @renderExpander($last, href, $target)

    # render the row-expander for a thumbnail
    renderExpander: ($after, src, $target) ->
      @$expander.remove() if @$expander
      @$el.find('.gridheist-thumb.expanded').removeClass('expanded')
      $target.addClass('expanded')

      # create the styled expander
      @$expander = $('<div class="gridheist-expander"></div>')
      @$expander.css('margin-bottom', @options.thumbBorder)
      @$expander.css('height', @options.expandHeight)

      # optional sidebar (content dynamically created)
      if @options.expandSideRender
        width = @options.expandSideWidth
        @$expander.append("""
          <div class="gridheist-expander-side" style="width:#{width}px">
            <div class="gridheist-expander-seperator"></div>
            <div class="gridheist-expander-content">
              #{@options.expandSideRender($target)}
            </div>
          </div>
        """)

      # draw the arrow to the expanded picture
      align = $target.position().left + ($target.width() / 2)
      bordr = @options.thumbBorder
      @$expander.append("""
        <div class="gridheist-expander-arrow" style="left:#{align}px;
          border-width:#{bordr}px; margin-left:-#{bordr}px;">
        </div>
      """)

      # add the image and go!
      @$expander.append("""
        <div class="gridheist-expander-img">
          <img src="#{src}"/>
        </div>
      """)
      $after.after(@$expander)


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
