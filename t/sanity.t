# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua 'no_plan';

repeat_each(2);
no_diff();
no_long_string();
log_level('info');

our $HttpConfig = <<"_EOC_";
    resolver ipv6=off local=on;

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
301 type: string
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



=== TEST 7: upstream request time
--- http_config eval: $::HttpConfig
--- config
    location /t {
        proxy_pass http://www.baidu.com/;
        log_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.log(ngx.ERR, "upstream_response_time: ",
                    var.fetch("upstream_response_time"))
        }
    }
--- request
GET /t
--- error_log eval
qr/upstream_response_time: 0\.\d+ while logging request/



=== TEST 8: upstream header time
--- http_config eval: $::HttpConfig
--- config
    location /t {
        proxy_pass http://www.baidu.com/;
        log_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.log(ngx.ERR, "upstream_header_time: ",
                    var.fetch("upstream_header_time"))
        }
    }
--- request
GET /t
--- error_log eval
qr/upstream_header_time: 0\.\d+ while logging request/



=== TEST 9: upstream connect time
--- http_config eval: $::HttpConfig
--- config
    location /t {
        proxy_pass http://www.baidu.com/;
        log_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.log(ngx.ERR, "upstream_connect_time: ",
                    var.fetch("upstream_connect_time"))
        }
    }
--- request
GET /t
--- error_log eval
qr/upstream_connect_time: 0\.\d+ while logging request/



=== TEST 10: upstream request time (no upstream)
--- http_config eval: $::HttpConfig
--- config
    location /t {
        echo "hello";
        log_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.log(ngx.ERR, "upstream_response_time: ",
                    var.fetch("upstream_response_time"))
        }
    }
--- request
GET /t
--- error_log
upstream_response_time: nil



=== TEST 11: scheme
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("scheme"))
        }
    }
--- request
GET /t/test/bar
--- no_error_log
[error]
--- response_body
http



=== TEST 12: `GET` from `request_method`
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("request_method"))
        }
    }
--- request
GET /t
--- no_error_log
[error]
--- response_body
GET



=== TEST 13: `POST` from `request_method`
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("request_method"))
        }
    }
--- request
POST /t
--- no_error_log
[error]
--- response_body
POST



=== TEST 14: `PUT` from `request_method`
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("request_method"))
        }
    }
--- request
PUT /t
--- no_error_log
[error]
--- response_body
PUT



=== TEST 14: `DELETE` from `request_method`
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("request_method"))
        }
    }
--- request
DELETE /t
--- no_error_log
[error]
--- response_body
DELETE
