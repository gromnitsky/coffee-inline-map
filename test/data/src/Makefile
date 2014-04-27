COFFEE_COMPILER := ../../../bin/coffee-inline-map
BROWSERIFY := ../../../node_modules/.bin/browserify

out := ../public
js_temp := \
	$(patsubst %.coffee,%.js,$(wildcard *.coffee)) \
	$(patsubst %.litcoffee,%.js,$(wildcard *.litcoffee))
bundle := $(out)/bundle.js

.PHONY: depend compile compile-js clean

all: compile

%.js: %.coffee
	$(COFFEE_COMPILER) $< -o $@

%.js: %.litcoffee
	$(COFFEE_COMPILER) $< -o $@

depend: compile-js
	make-commonjs-depend *js -o js.mk

-include js.mk

compile-js: $(js_temp)
compile: compile-js $(bundle)

$(bundle): main.js
	@mkdir -p $(out)
	$(BROWSERIFY) -d $< -o $@

clean:
	rm -f js.mk $(js_temp) $(bundle)
