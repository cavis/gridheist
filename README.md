
GridHeist
===========

A jQuery plugin to hijack an image gallery, making it great.

Check out [the demo here](http://cav.is/gridheist/example/index.html "Demo").

![Alt text](http://cav.is/img/gridheist-example.png "GridHeist Demo")

Requirements
------------

### jQuery

Requires [jQuery](http://jquery.com/ "jQuery") version **>= 1.7.0**


Compiling
---------

You'll need to install CoffeeScript using the Node Package Manager...

    npm install -g coffee-script

Then you can compile into normal ol' javascript

    coffee --compile gridheist.coffee
    coffee --watch --compile gridheist.coffee

This may end up slightly different, as I always put the header comments at the
top of my files, but you get the idea.


Getting Started
---------------

Include gridheist.js and gridheist.css.  (See example/index.html for an example).

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

If you want things to load snappier, I'd recommend pre-populating the `data-width` of the thumbnail images, so we don't have to wait for the `<img>` to load before we can get the native dimensions.

    <div id="gallery">
      <a href="img/something1_big.png">
        <img src="img/something1_thumb.png" data-width="300"/>
      </a>
    </div>


Options
------------

TODO


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
