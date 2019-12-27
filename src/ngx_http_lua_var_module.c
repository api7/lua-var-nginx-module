#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>
#include <ngx_http_lua_var_module.h>


static ngx_http_module_t ngx_http_lua_var_module_ctx = {
    NULL,                                    /* preconfiguration */
    NULL,                                    /* postconfiguration */

    NULL,                                    /* create main configuration */
    NULL,                                    /* init main configuration */

    NULL,                                    /* create server configuration */
    NULL,                                    /* merge server configuration */

    NULL,                                    /* create location configuration */
    NULL                                     /* merge location configuration */
};


ngx_module_t ngx_http_lua_var_module = {
    NGX_MODULE_V1,
    &ngx_http_lua_var_module_ctx,        /* module context */
    NULL,                                /*  module directives */
    NGX_HTTP_MODULE,                     /* module type */
    NULL,                                /* init master */
    NULL,                                /* init module */
    NULL,                                /* init process */
    NULL,                                /* init thread */
    NULL,                                /* exit thread */
    NULL,                                /* exit process */
    NULL,                                /* exit master */
    NGX_MODULE_V1_PADDING
};


ngx_int_t
ngx_http_lua_var_ffi_uri(ngx_http_request_t *r, ngx_str_t *uri)
{
    uri->data = r->uri.data;
    uri->len = r->uri.len;

    return NGX_OK;
}


ngx_int_t
ngx_http_lua_var_ffi_host(ngx_http_request_t *r, ngx_str_t *host)
{
    ngx_http_core_srv_conf_t  *cscf;

    if (r->headers_in.server.len) {
        host->len = r->headers_in.server.len;
        host->data = r->headers_in.server.data;
        return NGX_OK;
    }

    cscf = ngx_http_get_module_srv_conf(r, ngx_http_core_module);

    host->len = cscf->server_name.len;
    host->data = cscf->server_name.data;

    return NGX_OK;
}


ngx_int_t
ngx_http_lua_var_ffi_remote_addr(ngx_http_request_t *r, ngx_str_t *remote_addr)
{
    remote_addr->len = r->connection->addr_text.len;
    remote_addr->data = r->connection->addr_text.data;

    return NGX_OK;
}


ngx_int_t
ngx_http_lua_var_ffi_request_time(ngx_http_request_t *r, unsigned char *buf)
{
    ngx_time_t      *tp;
    ngx_msec_int_t   ms;
    int              len;

    tp = ngx_timeofday();

    ms = (ngx_msec_int_t)
             ((tp->sec - r->start_sec) * 1000 + (tp->msec - r->start_msec));
    ms = ngx_max(ms, 0);

    len = ngx_sprintf(buf, "%T.%03M", (time_t) ms / 1000, ms % 1000) - buf;
    return len;
}


ngx_int_t
ngx_http_lua_var_ffi_upstream_response_time(ngx_http_request_t *r,
    unsigned char *buf, int type)
{
    u_char                     *p;
    size_t                      len;
    ngx_uint_t                  i;
    ngx_msec_int_t              ms, total_ms;
    ngx_http_upstream_state_t  *state;

    if (r->upstream_states == NULL || r->upstream_states->nelts == 0) {
        return NGX_ERROR;
    }

    i = 0;
    total_ms = 0;
    state = r->upstream_states->elts;

    for ( ;; ) {
        if (state[i].status) {

            if (type == 1 && state[i].header_time != (ngx_msec_t) -1) {
                ms = state[i].header_time;

            } else if (type == 2 && state[i].connect_time != (ngx_msec_t) -1) {
                ms = state[i].connect_time;

            } else {
                ms = state[i].response_time;
            }

            ms = ngx_max(ms, 0);
            total_ms = total_ms + ms;
        }

        if (++i == r->upstream_states->nelts) {
            break;
        }

        if (!state[i].peer) {
            if (++i == r->upstream_states->nelts) {
                break;
            }
        }
    }

    len = ngx_sprintf(buf, "%T.%03M", (time_t) total_ms / 1000,
                      total_ms % 1000) - buf;
    return len;
}


ngx_int_t
ngx_http_lua_var_ffi_scheme(ngx_http_request_t *r, ngx_str_t *scheme)
{
#if (NGX_HTTP_SSL)

    if (r->connection->ssl) {
        scheme->len = sizeof("https") - 1;
        scheme->data = (u_char *) "https";

        return NGX_OK;
    }

#endif

    scheme->len = sizeof("http") - 1;
    scheme->data = (u_char *) "http";

    return NGX_OK;
}

/**
 * only for checking
 */
ngx_int_t
ngx_http_lua_var_ffi_test()
{
    return 0;
}
