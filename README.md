lua-var-nginx-module
====================

Fetchs Nginx variable by Luajit with FFI way which is fast and cheap.

Compares to `ngx.var.*`, performance has increased by more than five times. ^_^


Table of Contents
=================
* [Install](#install)
* [Methods](#methods)
    * [request](#request)
    * [fetch](#fetch)
* [TODO](#todo)


Install
=======

Compiles the nginx c module to OpenResty:

```shell
./configure --prefix=/opt/openresty \
         --add-module=/path/to/lua-var-nginx-module
```

Install the Lua source code, there are two ways:

```shell
luarocks install lua-resty-ngxvar
```

Or we can copy the source lua file to specified directory which OpenResty can
load it normally.

```shell
make install LUA_LIB_DIR=/opt/openresty/lualib/
```

Method
======

### request

`syntax: req = ngxvar.request()`

Returns the request object of current request. We can cache it at your Lua code
land if we try to fetch more than one variable in one request.

[Back to TOC](#table-of-contents)

### fetch

`syntax: val = ngxvar.fetch(name, req)`

Returns the Nginx variable value by name.

```nginx
 location /t {
     content_by_lua_block {
         local var = require("resty.ngxvar")
         local req = var.request()

         ngx.say(var.fetch("host", req))
         ngx.say(var.fetch("uri", req))
     }
 }
```

[Back to TOC](#table-of-contents)

TODO
====

* support more variables.

[Back to TOC](#table-of-contents)
