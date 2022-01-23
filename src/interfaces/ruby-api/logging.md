# Logging

```ruby
SCNR::Engine::API.run do

    Logging {
      
        # Will get called for each error message that is logged.
        on :error do |error|
            p error
            # => "Error string"
        end

        # Will get called for each exception that is created, even if safely handled.
        on :exception do |exception|
            p exception
            # => #<SCNR::Engine::URICommon::Error: Failed to parse URL.>
        end
        
    }

end
```

## Example

```bash
bin/scnr https://example.com --checks=- --script=logging.rb
```
