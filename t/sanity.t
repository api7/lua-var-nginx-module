# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua 'no_plan';

repeat_each(2);
no_diff();
no_long_string();

our $HttpConfig = <<"_EOC_";
    lua_package_path "lib/?.lua;;";
    init_by_lua_block {
        require "resty.core"
    }
_EOC_

run_tests();

__DATA__

=== TEST 1: uri
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("uri"))
        }
    }
--- request
GET /t/test/bar
--- no_error_log
[error]
--- response_body
/t/test/bar



=== TEST 2: host
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("host"))
        }
    }
--- request
GET /t/test/foo
--- more_headers
Host: foo.com
--- no_error_log
[error]
--- response_body
foo.com



=== TEST 3: status
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            ngx.exit(301)
        }
        log_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.log(ngx.ERR, var.fetch("status"),
                    " type: ", type(var.fetch("status")))
        }
    }
--- request
GET /t
--- error_log
301 type: number
--- error_code: 301



=== TEST 4: use cached `request` object
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            local req = var.fetch("_request")
            ngx.say(var.fetch("host", req))
        }
    }
--- request
GET /t/test/foo
--- more_headers
Host: foo.com
--- no_error_log
[error]
--- response_body
foo.com



=== TEST 5: use cached `request` object
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("remote_addr"))
        }
    }
--- request
GET /t/test/foo
--- more_headers
Host: foo.com
--- no_error_log
[error]
--- response_body
127.0.0.1



=== TEST 6: request_time
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            ngx.sleep(0.123)
            ngx.say("hit")
        }
        log_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.log(ngx.ERR, "request_time: ", var.fetch("request_time"))
        }
    }
--- request
GET /t
--- error_log eval
qr/request_time: 0\.1\d{2} while logging request/
--- response_body
hit
