# coffee-inline-map

Compile CoffeeScript files with inline source maps.

    $ coffee-inline-map -h
    TODO

## Features

* Error reporting similar to original coffee-script compiler.

## Installation

    $ npm install -g coffee-inline-map

## With make-commonjs-depend & browserify

    $ cat .gitignore
    js.mk

    $ ls *.coffee
    main.coffee a.coffee b.coffee

Here `main.coffee` depends on `a.coffee` & `b.coffee`. And we need for
our site just 1 `bundle.js` which includes all our CoffeeScript compiled
files.

We want to rebuild `bundle.js` only & only when on .coffee files
change. That's obviously a job for make.

    $ cat Makefile
    js_temp := $(patsubst %.coffee,%.js,$(wildcard *.coffee))
    bundle := ./lib/bundle.js

    %.js: %.coffee
            coffee -c $<

    depend:
            make-commonjs-depend *js -o js.mk

    -include js.mk

    compile: $(bundle)

    $(bundle): main.js
            browserify -o $@

    clean:
            rm -f js.mk $(js_temp)


To create a dependency tree, we run

    $ make depend
    TODO

    $ cat js.mk
    main.js: \
      a.js \
      b.js

Then compile the bundle

    $ make compile
    TODO

    $ make compile
    TODO

Notice that the bundle wasn't recompiled 2nd time. That's our goal!

    $ touch a.coffee
    $ make compile

Yay!

## Why not just use coffeeify plugin for browserify?

1. browserify can't (& shouldn't) check what has changed in our source
   files to decide whether it's time to recompile.
2. Error reporting.

## Why are you using make instead of cake or jake? It's not 1977 anymore!

facepalm.jpg

Dude. <br/>
Just take a walk for 10 minutes & no one will hurt.

## License

MIT.
