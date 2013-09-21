
GridHeist Versions
====================

0.0.1
------------

* Basic row layout functionality

0.0.2
------------

* Handle different thumb heights
* Minimum thumb height option
* Key listeners (left-right-escape)
* Scrollbar changer (when keying through)
* Better event cleanup
* Image preloading option
* Grid images can't have a max-width set (bootstrap tries to do this)

0.0.3
------------
* Bugfixes
* Add thumbMaxHeight option to scale down image heights
* Add left/right/close buttons to expander
* Unselectable buttons

0.0.4
------------
* Add `expander` option to hide the expander altogether
* Fix bug with browsers initially reporting an incorrect `$el.width()`, messing up the first layout
* Fix image-jumping when browser window gets smaller (adds an inner `.gridheist-wrap` container to the `$el`)
* Various optimizations, so complex and awesome that you totally wouldn't appreciate them

0.0.5
------------
* New preloading strategy and options for image expander
* Test for preloading
