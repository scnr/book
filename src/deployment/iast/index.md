# IAST

## Ruby

### Add the following to your `Gemfile`:

```ruby
gem "scnr-introspector"
```

### Use the Rack Middleware

```ruby
require 'scnr/introspector'
use SCNR::Introspector, scope: {
      path_start_with: __FILE__
    }
```

#### Example Sinatra app:

```ruby
require 'scnr/introspector'
require 'sinatra/base'

class MyApp < Sinatra::Base
    use SCNR::Introspector, scope: {
      path_start_with: __FILE__
    }

    def noop
    end

    def process_params( params )
        noop
        params.values.join( ' ' )
    end

    get '/' do
        @instance_variable = {
            blah: 'foo'
        }
        local_variable = 1

        <<EOHTML
#{process_params( params )}
        <a href="?v=stuff">XSS</a>
EOHTML
    end

    run!
end
```

## Scan as usual

`./bin/scnr http://my-app/`

### Results

With IAST enabled on the server-side, the results will include data and execution flow trace information:

```
[+] 1 issues were detected.

[+] [1] Cross-Site Scripting (XSS) (Trusted)
[~] ~~~~~~~~~~~~~~~~~~~~
[~] Digest:     3187004085
[~] Severity:   High
[~] Description:
[~]
Client-side scripts are used extensively by modern web applications.
They perform from simple functions (such as the formatting of text) up to full
manipulation of client-side data and Operating System interaction.

Cross Site Scripting (XSS) allows clients to inject scripts into a request and
have the server return the script to the client in the response. This occurs
because the application is taking untrusted data (in this example, from the client)
and reusing it without performing any validation or sanitisation.

If the injected script is returned immediately this is known as body XSS.
If the injected script is stored by the server and returned to any client visiting
the affected page, then this is known as persistent XSS (also stored XSS).

SCNR::Engine has discovered that it is possible to insert script content directly into
HTML element content.

[~] Tags: xss, regexp, injection, script

[~] CWE: http://cwe.mitre.org/data/definitions/79.html
[~] References:
[~]   Secunia - http://secunia.com/advisories/9716/
[~]   WASC - http://projects.webappsec.org/w/page/13246920/Cross%20Site%20Scripting
[~]   OWASP - https://www.owasp.org/index.php/XSS_%28Cross_Site_Scripting%29_Prevention_Cheat_Sheet

[~] URL:        http://localhost:4567/
[~] Element:    link
[~] All inputs: v
[~] Method:     GET
[~] Input name: v

[~] Seed:      "<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"
[~] Injected:  "stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"
[~] Proof:     "<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"

[~] Execution trace
[0] examples/sinatra/app.rb#17 MyApp#GET / call
[1] examples/sinatra/app.rb#17 MyApp#GET / b_call
[2] examples/sinatra/app.rb#19 MyApp#GET / line
[3] examples/sinatra/app.rb#21 MyApp#GET / line
[4] examples/sinatra/app.rb#24 MyApp#GET / line
[5] examples/sinatra/app.rb#12 MyApp#process_params call
[6] examples/sinatra/app.rb#13 MyApp#process_params line
[7] examples/sinatra/app.rb#9 MyApp#noop call
[8] examples/sinatra/app.rb#10 MyApp#noop return
[9] examples/sinatra/app.rb#14 MyApp#process_params line
[10] examples/sinatra/app.rb#14 Hash#values c_call
[11] examples/sinatra/app.rb#14 Hash#values c_return
[12] examples/sinatra/app.rb#14 Array#join c_call
[13] examples/sinatra/app.rb#14 Array#join c_return
[14] examples/sinatra/app.rb#15 MyApp#process_params return
[15] examples/sinatra/app.rb#27 MyApp#GET / b_return

[~] Data trace
[0] MyApp#call argument #0: "v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E"
Arguments:
[
{
"rack.version": [
1,
6
],
"rack.errors": "#<IO:0x000055d59b7eb758>",
"rack.multithread": true,
"rack.multiprocess": false,
"rack.run_once": false,
"rack.url_scheme": "http",
"SCRIPT_NAME": "",
"QUERY_STRING": "v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E",
"SERVER_SOFTWARE": "puma 6.2.2 Speaking of Now",
"GATEWAY_INTERFACE": "CGI/1.2",
"REQUEST_METHOD": "GET",
"REQUEST_PATH": "/",
"REQUEST_URI": "/?v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E",
"SERVER_PROTOCOL": "HTTP/1.1",
"HTTP_HOST": "localhost:4567",
"HTTP_ACCEPT_ENCODING": "gzip, deflate",
"HTTP_USER_AGENT": "Mozilla/5.0 (Gecko) SCNR::Engine/v0.1.2",
"HTTP_ACCEPT": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
"HTTP_ACCEPT_LANGUAGE": "en-US,en;q=0.8,he;q=0.6",
"puma.request_body_wait": 0.006314277648925781,
"SERVER_NAME": "localhost",
"SERVER_PORT": "4567",
"PATH_INFO": "/",
"REMOTE_ADDR": "127.0.0.1",
"HTTP_VERSION": "HTTP/1.1",
"puma.socket": "#<TCPSocket:0x000055d59c8b2078>",
"rack.hijack?": true,
"rack.hijack": "#<Puma::Client:0x000055d59c8b2028>",
"rack.input": "#<Puma::NullIO:0x000055d59c4b2c20>",
"rack.after_reply": [

    ],
    "puma.config": "#<Puma::Configuration:0x000055d59c1379d8>",
    "rack.logger": "#<Rack::NullLogger:0x000055d59bdbe7c0>",
    "rack.request.query_string": "v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E",
    "rack.request.query_hash": {
      "v": "stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"
    },
    "sinatra.route": "GET /"
}
]
Backtrace:
(eval):4:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/xss_header.rb:20:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/path_traversal.rb:18:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/json_csrf.rb:28:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/frame_options.rb:33:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/null_logger.rb:11:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/head.rb:12:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:219:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:2018:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `block in call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1792:in `synchronize'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/configuration.rb:270:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:98:in `block in handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:340:in `with_force_shutdown'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:97:in `handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:431:in `process_client'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:233:in `block in run'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:147:in `block in spawn_thread'

[1] MyApp#call! argument #0: "v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E"
Arguments:
[
{
"rack.version": [
1,
6
],
"rack.errors": "#<IO:0x000055d59b7eb758>",
"rack.multithread": true,
"rack.multiprocess": false,
"rack.run_once": false,
"rack.url_scheme": "http",
"SCRIPT_NAME": "",
"QUERY_STRING": "v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E",
"SERVER_SOFTWARE": "puma 6.2.2 Speaking of Now",
"GATEWAY_INTERFACE": "CGI/1.2",
"REQUEST_METHOD": "GET",
"REQUEST_PATH": "/",
"REQUEST_URI": "/?v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E",
"SERVER_PROTOCOL": "HTTP/1.1",
"HTTP_HOST": "localhost:4567",
"HTTP_ACCEPT_ENCODING": "gzip, deflate",
"HTTP_USER_AGENT": "Mozilla/5.0 (Gecko) SCNR::Engine/v0.1.2",
"HTTP_ACCEPT": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
"HTTP_ACCEPT_LANGUAGE": "en-US,en;q=0.8,he;q=0.6",
"puma.request_body_wait": 0.006314277648925781,
"SERVER_NAME": "localhost",
"SERVER_PORT": "4567",
"PATH_INFO": "/",
"REMOTE_ADDR": "127.0.0.1",
"HTTP_VERSION": "HTTP/1.1",
"puma.socket": "#<TCPSocket:0x000055d59c8b2078>",
"rack.hijack?": true,
"rack.hijack": "#<Puma::Client:0x000055d59c8b2028>",
"rack.input": "#<Puma::NullIO:0x000055d59c4b2c20>",
"rack.after_reply": [

    ],
    "puma.config": "#<Puma::Configuration:0x000055d59c1379d8>",
    "rack.logger": "#<Rack::NullLogger:0x000055d59bdbe7c0>",
    "rack.request.query_string": "v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E",
    "rack.request.query_hash": {
      "v": "stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"
    },
    "sinatra.route": "GET /"
}
]
Backtrace:
(eval):4:in `call!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:938:in `call'
(eval):5:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/xss_header.rb:20:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/path_traversal.rb:18:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/json_csrf.rb:28:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/frame_options.rb:33:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/null_logger.rb:11:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/head.rb:12:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:219:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:2018:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `block in call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1792:in `synchronize'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/configuration.rb:270:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:98:in `block in handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:340:in `with_force_shutdown'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:97:in `handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:431:in `process_client'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:233:in `block in run'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:147:in `block in spawn_thread'

[2] MyApp#process_params argument #0: "stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"
Arguments:
[
{
"v": "stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>"
}
]
Backtrace:
(eval):4:in `process_params'
examples/sinatra/app.rb:24:in `block in <class:MyApp>'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1706:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1706:in `block in compile!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1019:in `block (3 levels) in route!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1037:in `route_eval'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1019:in `block (2 levels) in route!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1068:in `block in process_route'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1066:in `catch'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1066:in `process_route'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1017:in `block in route!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1014:in `each'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1014:in `route!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1138:in `block in dispatch!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1109:in `catch'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1109:in `invoke'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1133:in `dispatch!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:949:in `block in call!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1109:in `catch'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1109:in `invoke'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:949:in `call!'
(eval):5:in `call!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:938:in `call'
(eval):5:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/xss_header.rb:20:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/path_traversal.rb:18:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/json_csrf.rb:28:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/frame_options.rb:33:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/null_logger.rb:11:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/head.rb:12:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:219:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:2018:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `block in call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1792:in `synchronize'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/configuration.rb:270:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:98:in `block in handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:340:in `with_force_shutdown'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:97:in `handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:431:in `process_client'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:233:in `block in run'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:147:in `block in spawn_thread'

[3] MyApp#body argument #0: "stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>\n        <a href=\"?v=stuff\">XSS</a>\n"
Arguments:
[
[
"stuff<xss_4e12ad53210ef9db2fe43d2bd73eee80/>\n        <a href=\"?v=stuff\">XSS</a>\n"
]
]
Backtrace:
(eval):4:in `body'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1118:in `invoke'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1133:in `dispatch!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:949:in `block in call!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1109:in `catch'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1109:in `invoke'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:949:in `call!'
(eval):5:in `call!'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:938:in `call'
(eval):5:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/xss_header.rb:20:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/path_traversal.rb:18:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/json_csrf.rb:28:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/base.rb:53:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-protection-3.0.6/lib/rack/protection/frame_options.rb:33:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/null_logger.rb:11:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/rack-2.2.7/lib/rack/head.rb:12:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:219:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:2018:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `block in call'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1792:in `synchronize'
/home/zapotek/scnr-dev-env/.system/gems/gems/sinatra-3.0.6/lib/sinatra/base.rb:1576:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/configuration.rb:270:in `call'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:98:in `block in handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:340:in `with_force_shutdown'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/request.rb:97:in `handle_request'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:431:in `process_client'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/server.rb:233:in `block in run'
/home/zapotek/scnr-dev-env/.system/gems/gems/puma-6.2.2/lib/puma/thread_pool.rb:147:in `block in spawn_thread'


[~] Referring page: http://localhost:4567/

[~] Affected page:  http://localhost:4567/?v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80/%3E
[~] HTTP request
GET /?v=stuff%3Cxss_4e12ad53210ef9db2fe43d2bd73eee80%2F%3E HTTP/1.1
Host: localhost:4567
Accept-Encoding: gzip, deflate
User-Agent: Mozilla/5.0 (Gecko) SCNR::Engine/v0.1.2
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.8,he;q=0.6
X-Scnr-Engine-Scan-Seed: 4e12ad53210ef9db2fe43d2bd73eee80
X-Scnr-Introspector-Taint: 4e12ad53210ef9db2fe43d2bd73eee80
X-Scnr-Introspector-Trace: 2
```
