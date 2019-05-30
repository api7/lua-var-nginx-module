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
            ngx.say(var("uri"))
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
            ngx.say(var("host"))
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
            ngx.log(ngx.ERR, var("status"), " type: ", type(var("status")))
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
            local req = var("_request")
            ngx.say(var("host", req))
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
            ngx.say(var("remote_addr"))
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
