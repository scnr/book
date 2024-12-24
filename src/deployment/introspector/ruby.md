# Ruby -- Rack, Ruby on Rails, etc.

## Installation

```
gem install scnr-introspector
```

## Use

```ruby
require 'scnr/introspector'

use SCNR::Introspector, scope: {
  path_start_with: File.dirname( __FILE__ ),
  path_end_with:   '.rb',

  path_include_patterns: /new-features/,
  path_exclude_patterns: /old-features/
}
```

### Example Sinatra application

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