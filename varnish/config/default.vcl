vcl 4.0;

backend default {
    .host = "127.0.0.1";
    .port = "8080";
    .connect_timeout = 5s;
    .first_byte_timeout = 10s;
    .between_bytes_timeout = 2s;
    .max_connections = 20;
}

sub vcl_recv {
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Not allowed."));
        }
        return (purge);
    }

    if (req.method == "BAN") {
        if (!client.ip ~ purge) {
            return (synth(403, "Not allowed."));
        }
        ban("req.url ~ " + req.url);
        return (synth(200, "Banned."));
    }

    if (req.method != "GET" && req.method != "HEAD" && req.method != "PUT" && req.method != "POST" && req.method != "TRACE" && req.method != "OPTIONS" && req.method != "DELETE") {
        return (pipe);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    if (req.http.Authorization || req.http.Cookie) {
        return (pass);
    }

    return (hash);
}

sub vcl_backend_response {
    if (beresp.ttl <= 0s || beresp.http.Set-Cookie || beresp.http.Vary == "*") {
        set beresp.uncacheable = true;
        set beresp.ttl = 120s;
        return (deliver);
    }

    if (beresp.http.Surrogate-Control) {
        unset beresp.http.Surrogate-Control;
    }

    if (beresp.http.Cache-Control ~ "no-cache" || beresp.http.Cache-Control ~ "no-store") {
        unset beresp.http.Cache-Control;
        set beresp.http.Cache-Control = "public";
    }

    if (beresp.http.X-Accel-Expires) {
        set beresp.ttl = beresp.http.X-Accel-Expires;
    }

    return (deliver);
}

sub vcl_deliver {
    if (resp.http.X-Varnish) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }

    if (resp.http.Set-Cookie) {
        unset resp.http.Set-Cookie;
    }

    return (deliver);
}
