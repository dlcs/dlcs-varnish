vcl 4.1;
# See: https://www.varnish-software.com/developers/tutorials/#vcl

backend default {
    .host = "127.0.0.1";
    .port = "80";
}

sub vcl_recv {
    set req.backend_hint = default;

    if (req.method == "BAN") {

        set req.url = regsub(req.url, "^(\/)", "");

        ban("obj.http.x-asset-id == " + req.url);

        # Throw a synthetic page so the
        # request won't go to the backend.
        return(synth(200, "Ban added"));
    }

    return(hash);
}

sub vcl_miss {
    return(fetch);
}

sub vcl_hit {
    return(deliver);
}

sub vcl_backend_response {
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
