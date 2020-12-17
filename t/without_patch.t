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
        package.loaded.mock = {}
        ngx.var = package.loaded.mock
        local var = require("resty.ngxvar")
        var.enable_patch(false)
    }
_EOC_

add_block_preprocessor(sub {
    my ($block) = @_;

    if (!$block->http_config) {
        $block->set_value("http_config", $HttpConfig);
    }

    if (!$block->request) {
        $block->set_value("request", "GET /t");
    }

    if (!$block->error_log && !$block->no_error_log) {
        $block->set_value("no_error_log", "[error]\n[alert]");
    }
});

run_tests();

__DATA__

=== TEST 1: upstream_response_time
--- config
    location /t {
        content_by_lua_block {
            package.loaded.mock.upstream_response_time = "102.023"
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("upstream_response_time"))
            ngx.say(type(var.fetch("upstream_response_time")))

            package.loaded.mock.upstream_response_time = "102.023, 0.000"
            ngx.say(var.fetch("upstream_response_time"))

            package.loaded.mock.upstream_response_time = "102.023 : 1.200"
            ngx.say(var.fetch("upstream_response_time"))
        }
    }
--- response_body
102.023
number
102.023
103.223



=== TEST 2: upstream_connect_time
--- config
    location /t {
        content_by_lua_block {
            package.loaded.mock.upstream_connect_time = "102.023"
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("upstream_connect_time"))
            ngx.say(type(var.fetch("upstream_connect_time")))

            package.loaded.mock.upstream_connect_time = "102.023, 0.000"
            ngx.say(var.fetch("upstream_connect_time"))

            package.loaded.mock.upstream_connect_time = "102.023 : 1.200"
            ngx.say(var.fetch("upstream_connect_time"))
        }
    }
--- response_body
102.023
number
102.023
103.223



=== TEST 3: upstream_header_time
--- config
    location /t {
        content_by_lua_block {
            package.loaded.mock.upstream_header_time = "102.023"
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("upstream_header_time"))
            ngx.say(type(var.fetch("upstream_header_time")))

            package.loaded.mock.upstream_header_time = "102.023, 0.000"
            ngx.say(var.fetch("upstream_header_time"))

            package.loaded.mock.upstream_header_time = "102.023 : 1.200"
            ngx.say(var.fetch("upstream_header_time"))
        }
    }
--- response_body
102.023
number
102.023
103.223



=== TEST 4: check if value is nil before conversion
--- config
    location /t {
        content_by_lua_block {
            package.loaded.mock.upstream_header_time = nil
            local var = require("resty.ngxvar")
            ngx.say(var.fetch("upstream_header_time"))
        }
    }
--- response_body
nil
