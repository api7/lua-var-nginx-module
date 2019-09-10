local get_request = require("resty.core.base").get_request
local ngx_var = ngx.var


local _M = {
    _version = 0.1,
}


function _M.request()
    local r = get_request()
    if not r then
        return nil, "no request found"
    end

    return r
end


function _M.fetch(name, request)
    return ngx_var[name]
end


return _M
