import std;


backend default {
  .host = "172.17.0.1";

  .port = "80";   
}

acl purge {
        "localhost";
        "10.0.0.0"/8;
}

sub vcl_recv {
    if (req.request == "PURGE") {
            if (!client.ip ~ purge) {
                    error 405 "Not allowed.";
            }
            return (lookup);
    }

    if (req.request != "GET" &&
            req.request != "HEAD" &&
            req.request != "PUT" &&
            req.request != "POST" &&
            req.request != "TRACE" &&
            req.request != "OPTIONS" &&
            req.request != "DELETE") {
            return (pipe);
    }

    if (req.request != "GET" && req.request != "HEAD") {
        /* We only deal with GET and HEAD by default */                
        return (pass);
    }
    return (lookup);
}

sub vcl_pass {
     return (pass);
}

sub vcl_hash {
    hash_data(req.url+req.http.host);
    return (hash);
}

sub vcl_hit {
    if (req.request == "PURGE") {
            purge;
            error 200 "Purged.";
    }
}