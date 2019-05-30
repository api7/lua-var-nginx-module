OPENRESTY_PREFIX=/usr/local/openresty

PREFIX ?= /usr/local
LUA_INCLUDE_DIR ?= $(PREFIX)/include
LUA_LIB_DIR ?=     $(PREFIX)/lualib/$(LUA_VERSION)
INSTALL ?= install

test = t/

.PHONY: all test install

install:
	$(INSTALL) -m664 lib/resty/*.lua $(DESTDIR)$(LUA_LIB_DIR)/resty

test:
	PATH=$(OPENRESTY_PREFIX)/nginx/sbin:$$PATH prove -I../test-nginx/lib -r $(test)
