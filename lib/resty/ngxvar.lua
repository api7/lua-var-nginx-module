local get_request = require("resty.core.base").get_request
local ffi = require("ffi")
local C = ffi.C
local ffi_string = ffi.string
local ngx_var = ngx.var
local str_t = ffi.new("ngx_str_t[1]")
local pcall = pcall


local ngxvar_patched


ffi.cdef([[
int ngx_http_lua_var_ffi_uri(ngx_http_request_t *r, ngx_str_t *uri);
int ngx_http_lua_var_ffi_host(ngx_http_request_t *r, ngx_str_t *host);
]])


local _M = {version = 0.1}


function _M.uri()
    local r = get_request()
    if not r then
        return false, "no request found"
    end

    C.ngx_http_lua_var_ffi_uri(r, str_t)
    return ffi_string(str_t[0].data, str_t[0].len)
end


function _M.host()
    local r = get_request()
    if not r then
        return false, "no request found"
    end

    C.ngx_http_lua_var_ffi_host(r, str_t)
    return (ffi_string(str_t[0].data, str_t[0].len))
end


return function (name)
    local method = _M[name]

    if ngxvar_patched == nil and method then
        local val
        ngxvar_patched, val = pcall(method)
        if ngxvar_patched then
            return val
        end

        return ngx_var[name]
    end

    if not ngxvar_patched or not method then
        return ngx_var[name]
    end

    return method()
end
