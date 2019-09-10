
local subsystem = ngx.config.subsystem

if subsystem == "http" then
    return require("resty.ngxvar.http")
end

return require("resty.ngxvar.stream")
