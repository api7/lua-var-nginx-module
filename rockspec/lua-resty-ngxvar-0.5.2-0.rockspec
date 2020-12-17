package = "lua-resty-ngxvar"
version = "0.5.2-0"
source = {
    url = "git://github.com/api7/lua-var-nginx-module",
    tag = "v0.5.2"
}
description = {
    summary = "Fetch nginx variable by FFI way for OpenResty which is faster",
    homepage = "https://github.com/api7/lua-var-nginx-module",
    license = "Apache License 2.0",
    maintainer = "Yuansheng Wang <membphis@gmail.com>"
}
build = {
    type = "builtin",
    modules = {
        ["resty.ngxvar"] = "lib/resty/ngxvar.lua",
        ["resty.ngxvar.http"] = "lib/resty/ngxvar/http.lua",
        ["resty.ngxvar.stream"] = "lib/resty/ngxvar/stream.lua",
    }
}
