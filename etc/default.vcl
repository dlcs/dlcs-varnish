# See: https://www.varnish-software.com/developers/tutorials/#vcl

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
    # Add debug header to see if it's a HIT/MISS and the number of hits, disable when not needed
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }

    # Set hits in X-Cache-Hits header
    set resp.http.X-Cache-Hits = obj.hits;

    return(deliver);
}
