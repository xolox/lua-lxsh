VERSION = $(shell grep _VERSION src/init.lua | cut "-d'" -f 2)
RELEASE = $(VERSION)-1
PACKAGE = lxsh-$(RELEASE)
STYLESHEETS = examples/earendel.css \
              examples/slate.css \
              examples/wiki.css

demo: $(STYLESHEETS)
	@mkdir -p examples/earendel examples/slate examples/wiki
	@lua etc/demo.lua

test:
	@lua test/lexers.lua
	@lua test/highlighters.lua

examples/%.css: src/colors/%.lua src/init.lua
	@lua -e "print(require 'lxsh'.stylesheet'$(notdir $(basename $@))')" > $@

package: demo
	@rm -f $(PACKAGE).zip
	@mkdir -p $(PACKAGE)/etc
	@cp -al etc/demo.lua etc/doclinks.lua $(PACKAGE)/etc
	@cp -al examples $(PACKAGE)
	@cp -al src $(PACKAGE)
	@cp README.md TODO.md $(PACKAGE)
	@zip $(PACKAGE).zip  -x '*.sw*' -r $(PACKAGE)
	@rm -R $(PACKAGE)
	@echo Generated $(PACKAGE).zip

rockspec: package
	@cat etc/template.rockspec \
		| sed "s/{{VERSION}}/$(RELEASE)/g" \
		| sed "s/{{DATE}}/`export LANG=; date '+%B %d, %Y'`/" \
		| sed "s/{{HASH}}/`md5sum $(PACKAGE).zip | cut '-d ' -f1 `/" \
		> $(PACKAGE).rockspec
	@echo Generated $(PACKAGE).rockspec

.PHONY: demo test package
