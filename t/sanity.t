# vim:set ft= ts=4 sw=4 et fdm=marker:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(1);

plan tests => repeat_each() * (blocks() * 3);

no_diff();
no_long_string();

our $HttpConfig = <<"_EOC_";
    lua_package_path "lib/?.lua;;";
    init_by_lua_block {
        -- local v = require "jit.v"
        -- v.on("$Test::Nginx::Util::ErrLogFile")
        require "resty.core"
    }
_EOC_

no_long_string();
run_tests();

__DATA__

=== TEST 1: sanity
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua_block {
            local var = require("resty.ngxvar")
            ngx.say(var("uri"))
            ngx.say(var("host"))
        }
    }
--- request
GET /t/test/foo
--- no_error_log
[error]
--- response_body
/t/test/foo
localhost



=== TEST 2: sanity
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
