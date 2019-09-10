# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua::Stream 'no_plan';

repeat_each(2);
no_diff();
no_long_string();
log_level('info');

our $StreamConfig = <<"_EOC_";
    resolver ipv6=off local=on;

    lua_package_path "lib/?.lua;;";
    init_by_lua_block {
        require "resty.core"
    }
_EOC_

run_tests();

__DATA__

=== TEST 1: sanity
--- stream_config eval: $::StreamConfig
--- stream_server_config
content_by_lua_block {
    local var = require("resty.ngxvar")

    local ok, err = ngx.print("server port: ", var.fetch("server_port"), "\n")
    if not ok then
        ngx.log(ngx.ERR, "print failed: ", err)
    end
}
--- stream_response
server port: 1985
--- no_error_log
[error]



=== TEST 2: request
--- stream_config eval: $::StreamConfig
--- stream_server_config
content_by_lua_block {
    local var = require("resty.ngxvar")

    local r = var.request()
    local ok, err = ngx.print("server port: ", var.fetch("server_port", r), "\n")
    if not ok then
        ngx.log(ngx.ERR, "print failed: ", err)
    end
}
--- stream_response
server port: 1985
--- no_error_log
[error]
