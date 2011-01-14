STYLESHEETS = examples/earendel.css \
              examples/slate.css \
              examples/wiki.css

demo: $(STYLESHEETS)
	lua etc/demo.lua

examples/%.css: src/colors/%.lua src/init.lua
	lua -e "print(require 'lxsh'.stylesheet'$(notdir $(basename $@))')" > $@

ZIPNAME = lxsh-0.6.1-1

package: demo
	@rm -f $(ZIPNAME).zip
	@mkdir -p $(ZIPNAME)/etc
	@cp -al etc/demo.lua etc/doclinks.lua $(ZIPNAME)/etc
	@cp -al examples $(ZIPNAME)
	@cp -al src $(ZIPNAME)
	@cp README.md TODO.md $(ZIPNAME)
	@zip $(ZIPNAME).zip  -x '*.sw*' -r $(ZIPNAME)
	@rm -R $(ZIPNAME)
	@echo Calculating MD5 sum for LuaRocks
	@md5sum $(ZIPNAME).zip
