# Ruby

## Install

```bash
gem install scnr-introspector
```

## Use middleware

### Options

| Option                  | Description                                                    | Default | Example       |
|-------------------------|----------------------------------------------------------------|---------|---------------|
| `path_start_with`       | Only instrument classes whose path starts with this prefix     | none | `example/`    |
| `path_ends_with`        | Only instrument classes whose path ends with this suffix       | none | `app.rb`      |
| `path_include_patterns` | Only instrument classes whose path matches all regex patterns  | none | `.*service.*` |
| `path_exclude_patterns` | Exclude classes matching whose path matches any regex patterns | none | `.*test.*`    |

`app.rb`:

```ruby
require 'scnr/introspector' # Include!
require 'sinatra/base'

class MyApp < Sinatra::Base
    # Use!
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

## Verify

Run the Web App:

```bash
bundle exec ruby examples/sinatra/app.rb
```

You should see this at the beginning:

```
[INTROSPECTOR] Codename SCNR Introspector Initialized.
```

Along with these types of messages:

```
[INTROSPECTOR] Injecting trace code for MyApp#process_paramsin examples/sinatra/app.rb:12
```

As an integration test, you can run:

```bash
curl -i http://localhost:4567/ -H "X-Scnr-Engine-Scan-Seed:Test" -H "X-Scnr-Introspector-Trace:1" -H "X-SCNR-Request-ID:1"
```

You should see something like this (the comments are the important part):

```html
HTTP/1.1 200 OK
Content-Type: text/html;charset=utf-8
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
Content-Length: 7055


<a href="?v=stuff">XSS</a>
<!-- Test
{"execution_flow":{"points":[{"path":"examples/sinatra/app.rb","line_number":17,"class_name":"MyApp","method_name":"GET /","event":"call","source":"    get '/' do\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":19,"class_name":"MyApp","method_name":"GET /","event":"line","source":"            blah: 'foo'\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":21,"class_name":"MyApp","method_name":"GET /","event":"line","source":"        local_variable = 1\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":23,"class_name":"MyApp","method_name":"GET /","event":"line","source":"        <<EOHTML\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":12,"class_name":"MyApp","method_name":"process_params","event":"call","source":"    def process_params( params )\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":13,"class_name":"MyApp","method_name":"process_params","event":"line","source":"        noop\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":9,"class_name":"MyApp","method_name":"noop","event":"call","source":"    def noop\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":14,"class_name":"MyApp","method_name":"process_params","event":"line","source":"        params.values.join( ' ' )\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":14,"class_name":"Hash","method_name":"values","event":"c_call","source":"        params.values.join( ' ' )\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"},{"path":"examples/sinatra/app.rb","line_number":14,"class_name":"Array","method_name":"join","event":"c_call","source":"        params.values.join( ' ' )\n","file_contents":"require 'scnr/introspector'\nrequire 'sinatra/base'\n\nclass MyApp < Sinatra::Base\n    use SCNR::Introspector, scope: {\n      path_start_with: __FILE__\n    }\n\n    def noop\n    end\n\n    def process_params( params )\n        noop\n        params.values.join( ' ' )\n    end\n\n    get '/' do\n        @instance_variable = {\n            blah: 'foo'\n        }\n        local_variable = 1\n\n        <<EOHTML\n        #{process_params( params )}\n        <a href=\"?v=stuff\">XSS</a>\nEOHTML\n    end\n\n    run!\nend\n"}]},"platforms":["ruby","linux"]}
-->
```
