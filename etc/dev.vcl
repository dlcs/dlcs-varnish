vcl 4.1;

backend default {
    .host = "backend";
    .port = "8080";
}

sub vcl_recv {
    set req.backend_hint = default;

    if (req.method == "BAN") {
        set req.url = regsub(req.url, "^(\/)", "");
        ban("obj.http.x-asset-id == " + req.url);
        return(synth(200, "Ban added"));
    }

    return(hash);
}

sub vcl_backend_response {
    # Short TTL so HIT/MISS behaviour is easy to observe
    set beresp.ttl = 1m;
    return(deliver);
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
    set resp.http.X-Cache-Hits = obj.hits;
    return(deliver);
}
