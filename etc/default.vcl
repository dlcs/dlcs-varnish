backend default {
    .host = "${BACKEND_HOST}";
    .port = "${BACKEND_PORT}";
}

sub vcl_recv {
    set req.backend = default;
    return(lookup);
}

sub vcl_miss {
    return(fetch);
}

sub vcl_hit {
    return(deliver);
}

sub vcl_fetch {
    # Get the response. Set the cache lifetime of the response to 1 hour.
    set beresp.ttl = 1h;

    # Indicate that this response is cacheable. This is important.
    set beresp.http.X-Cacheable = "YES";
    
    # Now pass this backend response along to the cache to be stored and served.
    return(deliver);
}

sub vcl_deliver {
    return(deliver);
}
