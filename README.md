
GridHeist
===========

A jQuery plugin to hijack an image gallery, making it great.

Check out [the dynamic test page](http://cav.is/gridheist/test/dynamic.html "Dynamic Test").

![Alt text](http://cav.is/img/gridheist-example.png "GridHeist Demo")

Requirements
------------

### jQuery

Requires [jQuery](http://jquery.com/ "jQuery") version **>= 1.7.0**


Compiling
---------

You'll need to install the `grunt-cli` using the Node Package Manager...

    npm install -g grunt-cli

Then install the dependencies from `package.json` (if you haven't already)...

    npm install <module-name-here>

Then you can run grunt tasks!

    grunt build
    grunt watch


Getting Started
---------------

Include gridheist.js and gridheist.css, or some version of them.  (See example/index.html for an example).

### In your `<head>` section (next to other CSS):

    <link href="path/to/gridheist.css" rel="stylesheet">

### At the bottom of the `<body>` section (next to other JS)

    <script src="path/to/jquery-1.10.2.min.js"></script>
    <script src="path/to/gridheist.js"></script>


Usage
------------

GridHeist is a jQuery plugin, so just call the function on a selector to create a gallery.

    $(document).ready(function() {
        var options = {};
        $('#gallery').gridHeist(options);
    });

Galleries should have semi-standardized markup.  For now, all your thumbnails (the inner img) should have THE SAME HEIGHT if you want this to work. The following is pretty standard:

    <div id="gallery">
      <a href="img/something1_big.png">
        <img src="img/something1_thumb.png"/>
      </a>
      <a href="img/something2_big.png">
        <img src="img/something2_thumb.png"/>
      </a>
    </div>

If you want things to load snappier, I'd recommend pre-populating the `data-width` and `data-height` of the thumbnail images, so we don't have to wait for the `<img>` to load before we can get the native dimensions.

    <div id="gallery">
      <a href="img/something1_big.png">
        <img src="img/something1_thumb.png" data-width="300" data-height="200"/>
      </a>
    </div>


Options
------------

These options can be passed in when you create the gridheist.  Numbers are probably something in `px`, unless otherwise noted.

`thumbSelector` - A jQuery selector to get the thumbnail objects within the element - __(default: `> *`)__

`thumbBorder` - Border width between thumbnails - __(default: `10`)__

`thumbMinHeight` - Minimum height of a row of thumbnails - __(default: `200`)__

`thumbMaxHeight` - Maximum height of a row of thumbnails - __(default: `null`)__

`preloadImages` - Preloads the big-kid images (set by the href attribute) after the thumbnails are all loaded - __(default: `true`)__

`expandHeight` - Height of the expander-row - __(default: `300`)__

`expandSideRender` - Function to return markup for the expander sidebar; passed the jQuery `$thumb` object - __(default: `false`)__

`expandSideWidth` - Width of the expander sidebar (if expandSideRender is passed) - __(default: `200`)__


Methods
------------

TODO


Issues and Contributing
-----------------------

Report any bugs or feature-requests via the issue tracker.  Or send me a fax.  And if you'd like to contribute, send me a note!  Thanks.


License
------------

GridHeist is free software, and may be redistributed under the MIT-LICENSE.

Thanks for listening!
