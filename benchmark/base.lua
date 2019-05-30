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

test1()
test2()
