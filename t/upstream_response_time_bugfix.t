# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua 'no_plan';

repeat_each(1);

#no_shuffle();
no_long_string();
run_tests();

__DATA__

=== TEST 1: ignore the client abort event in the user callback
--- config
    location /t {
        proxy_pass http://127.0.0.1:$server_port/delay;
        log_by_lua_block {
            local var = require("resty.ngxvar")
            local req = var.request()
            ngx.log(ngx.NOTICE, "validate upstream_response_time: ", tonumber(var.fetch("upstream_response_time", req)) > 0)
        }
    }
    location = /delay {
        content_by_lua_block {
            ngx.sleep(2)
        }
    }
--- request
GET /t

--- timeout: 0.2
--- abort
--- wait: 0.7
--- ignore_response
--- no_error_log
[error]
--- error_log
validate upstream_response_time: true
