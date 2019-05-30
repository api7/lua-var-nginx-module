local get_request = require("resty.core.base").get_request
local ffi = require("ffi")
local C = ffi.C
local ffi_string = ffi.string
local ngx = ngx
local ngx_var = ngx.var
local str_t = ffi.new("ngx_str_t[1]")
local pcall = pcall


ffi.cdef([[
int ngx_http_lua_var_ffi_uri(ngx_http_request_t *r, ngx_str_t *uri);
int ngx_http_lua_var_ffi_host(ngx_http_request_t *r, ngx_str_t *host);
int ngx_http_lua_var_ffi_test();
int ngx_http_lua_var_ffi_remote_addr(ngx_http_request_t *r,
    ngx_str_t *remote_addr);
]])


local var_patched = pcall(function() return C.ngx_http_lua_var_ffi_test() end)
local vars = {
    method = ngx.req.get_method,
}


function vars.uri(r)
    r = r or get_request()
    if not r then
        return false, "no request found"
    end

    C.ngx_http_lua_var_ffi_uri(r, str_t)
    return ffi_string(str_t[0].data, str_t[0].len)
end


function vars.host(r)
    r = r or get_request()
    if not r then
        return false, "no request found"
    end

    C.ngx_http_lua_var_ffi_host(r, str_t)
    return (ffi_string(str_t[0].data, str_t[0].len))
end


function vars.status()
    return ngx.status
end


function vars.remote_addr(r)
    r = r or get_request()
    if not r then
        return false, "no request found"
    end

    C.ngx_http_lua_var_ffi_remote_addr(r, str_t)
    return ffi_string(str_t[0].data, str_t[0].len)
end


local _M = {
    _version = 0.1,
}


function _M.request()
    local r = get_request()
    if not r then
        return false, "no request found"
    end

    return r
end


function _M.fetch(name, request)
    local method = vars[name]

    if not var_patched or not method then
        return ngx_var[name]
    end

    return method(request)
end


return _M
