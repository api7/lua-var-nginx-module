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


/**
 * only for checking
 */
ngx_int_t
ngx_http_lua_var_ffi_test()
{
    return 0;
}
