lua-var-nginx-module
====================

Fetchs Nginx variable by Luajit with FFI way which is fast and cheap.

```lua
local function test1()
    local start_time = ngx.now()

    local var = ngx.var
    local uri
    for i = 1, 10000 * 1000 do
        uri = var.uri
        if not uri then
            uri = uri .. "xxx"
        end
    end

    ngx.update_time()
    ngx.say("ngx.var directly, used time: ", ngx.now() - start_time)
end

local function test2()
    local start_time = ngx.now()

    local ngxvar = require("resty.ngxvar").fetch
    local req = ngxvar("_request")
    local uri

    for i = 1, 10000 * 1000 do
        uri = ngxvar("uri", req)
        if not uri then
            uri = uri .. "xxx"
        end
    end

    ngx.update_time()
    ngx.say("ngxvar patch, used time: ", ngx.now() - start_time)
end

test1()     -- ngx.var directly, used time: 0.49900007247925
test2()     -- fetch with ngxvar, used time: 0.08299994468689
```

Compares to `ngx.var`, performance has increased by more than five times. ^_^


Table of Contents
=================
* [Install](#install)
* [Methods](#methods)
    * [request](#request)
    * [fetch](#fetch)
* [TODO](#todo)

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
         local req = var.fetch("_request")

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
