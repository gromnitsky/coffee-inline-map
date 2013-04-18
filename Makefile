COFFEE := node_modules/.bin/coffee
MOCHA := node_modules/.bin/mocha
OPTS :=

out := lib
js_temp := $(patsubst %.coffee,$(out)/%.js,$(wildcard *.coffee))

.PHONY: clobber clean compile

all: test

node_modules: package.json
	npm install
	touch $@

test: compile
	$(MOCHA) --compilers coffee:coffee-script -u tdd test $(OPTS)

lib/%.js: %.coffee
	$(COFFEE) -o $(out) -c $<

compile: node_modules $(js_temp)

clean:
	rm -f $(js_temp)
	[ -r $(out) ] && rmdir $(out); :

clobber: clean
	rm -rf node_modules

# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
