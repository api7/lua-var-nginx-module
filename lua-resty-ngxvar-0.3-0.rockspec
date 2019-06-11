package = "lua-resty-ngxvar"
version = "0.3-0"
source = {
   url = "git://github.com/iresty/lua-var-nginx-module",
   tag = "v0.3"
}
description = {
   summary = "Fetch nginx variable by FFI way for OpenResty which is faster",
   homepage = "https://github.com/iresty/lua-var-nginx-module",
   license = "Apache License 2.0",
   maintainer = "Yuansheng Wang <membphis@gmail.com>"
}
build = {
   type = "builtin",
   modules = {
      ["resty.ngxvar"] = "lib/resty/ngxvar.lua"
   }
}
