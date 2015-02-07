M4 := m4
COFFEE := node_modules/.bin/coffee
MOCHA := node_modules/.bin/mocha
TEST_OPTS :=

out := lib
js := $(patsubst %.coffee,$(out)/%.js,$(wildcard *.coffee))

.PHONY: all
all: test

node_modules: package.json
	npm install
	touch $@

.PHONY: test
test: compile
	$(MAKE) -C test/data compile
	$(MOCHA) --compilers coffee:coffee-script/register -u tdd test/test_* $(TEST_OPTS)

lib/%.js: %.coffee
	$(COFFEE) -o $(out) -c $<

README.html: README.md
	pandoc $< -o $@

README.md: README.m4.md
	cd test/data/src ; \
		$(MAKE) clean; \
		$(M4) ../../../$< > ../../../$@

.PHONY: compile
compile: node_modules $(js) README.md

.PHONY: npm
npm: compile
	rm -f README.html
	npm publish

.PHONY: npm-view
npm-view: test
	rm -f README.html coffee-inline-map-*.tgz
	npm pack && less coffee-inline-map-*.tgz
	rm coffee-inline-map-*.tgz

.PHONY: clean
clean:
	rm -f $(js)
	$(MAKE) -C test/data clean

.PHONY: nuke
nuke: clean
	rm -rf node_modules


# Debug. Use 'gmake p-obj' to print $(obj) variable.
p-%:
	@echo $* = $($*)
	@echo $*\'s origin is $(origin $*)
