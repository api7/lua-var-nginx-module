local get_request   = require("resty.core.base").get_request
local get_string_buf= require("resty.core.base").get_string_buf
local ffi           = require("ffi")
local C             = ffi.C
local ffi_string    = ffi.string
local ngx           = ngx
local ngx_var       = ngx.var
local re_gmatch     = ngx.re.gmatch
local str_t         = ffi.new("ngx_str_t[1]")
local pcall         = pcall
local num_type      = {}
local ups_num_type  = {}
local tonumber      = tonumber
local str_find      = string.find
local str_buf       = get_string_buf(1024)


ffi.cdef([[
int ngx_http_lua_var_ffi_uri(ngx_http_request_t *r, ngx_str_t *uri);
int ngx_http_lua_var_ffi_host(ngx_http_request_t *r, ngx_str_t *host);
int ngx_http_lua_var_ffi_remote_addr(ngx_http_request_t *r,
    ngx_str_t *remote_addr);
int ngx_http_lua_var_ffi_request_time(ngx_http_request_t *r,
    unsigned char *buf);
int ngx_http_lua_var_ffi_upstream_response_time(ngx_http_request_t *r,
    unsigned char *buf, int type);
int ngx_http_lua_var_ffi_scheme(ngx_http_request_t *r, ngx_str_t *scheme);
]])


local var_patched = pcall(function () return C.ngx_http_lua_var_ffi_uri end)
local vars = {
    request_method = ngx.req.get_method,
}


function vars.uri(r)
    r = r or get_request()
    if not r then
        return nil, "no request found"
    end

    C.ngx_http_lua_var_ffi_uri(r, str_t)
    return ffi_string(str_t[0].data, str_t[0].len)
end


function vars.host(r)
    r = r or get_request()
    if not r then
        return nil, "no request found"
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
        return nil, "no request found"
    end

    C.ngx_http_lua_var_ffi_remote_addr(r, str_t)
    return ffi_string(str_t[0].data, str_t[0].len)
end


function vars.request_time(r)
    r = r or get_request()
    if not r then
        return nil, "no request found"
    end

    local len = C.ngx_http_lua_var_ffi_request_time(r, str_buf)
    if len == 0 then
        return 0
    end

    return tonumber(ffi_string(str_buf, len))
end
num_type.request_time = true


local function upstream_response_time(r, typ)
    r = r or get_request()
    if not r then
        return nil, "no request found"
    end

    local len = C.ngx_http_lua_var_ffi_upstream_response_time(r, str_buf, typ)
    if len < 0 then
        return nil, "not found"
    end

    if len == 0 then
        return 0
    end

    return tonumber(ffi_string(str_buf, len))
end


vars.upstream_response_time = function (r)
    return upstream_response_time(r, 0)
end
ups_num_type.upstream_response_time = true


vars.upstream_header_time = function (r)
    return upstream_response_time(r, 1)
end
ups_num_type.upstream_header_time = true


vars.upstream_connect_time = function (r)
    return upstream_response_time(r, 2)
end
ups_num_type.upstream_connect_time = true


function vars.scheme(r)
    r = r or get_request()
    if not r then
        return nil, "no request found"
    end

    C.ngx_http_lua_var_ffi_scheme(r, str_t)
    return ffi_string(str_t[0].data, str_t[0].len)
end


for _, name in ipairs({"request_length", "bytes_sent"}) do
    vars[name] = function ()
        return tonumber(ngx_var[name])
    end
    num_type[name] = true
end


local _M = {}


function _M.enable_patch(state)
    var_patched = state
end


function _M.request()
    local r = get_request()
    if not r then
        return nil, "no request found"
    end

    return r
end


local function sum_upstream_num(s)
    if type(s) ~= "string" then
        return s
    end

    local idx = str_find(s, " ", 1, true)
    if not idx then
        -- fast path
        return tonumber(s)
    end

    local sum = 0
    local iterator, err = re_gmatch(s, [[(\d+(.\d+)?)]], "jo")
    if not iterator then
        ngx.log(ngx.ERR, "failed to create iterator: ", err)
        return nil
    end

    while true do
        local val = iterator()
        if not val then
            break
        end

        sum = sum + tonumber(val[1])
    end

    return sum
end


function _M.fetch(name, request)
    local method = vars[name]

    if not var_patched or not method then
        if num_type[name] then
            return tonumber(ngx_var[name])
        elseif ups_num_type[name] then
            return sum_upstream_num(ngx_var[name])
        end

        return ngx_var[name]
    end

    return method(request)
end


return _M
