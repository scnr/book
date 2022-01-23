# Urls

```ruby
SCNR::Engine::API.run do

    Data {
        Urls {
            on :new do |url|
                p url
                # => "http://example.com"
            end
        }
    }

end
```

## Example

```bash
bin/scnr http://example.com/ --checks=- --script=urls.rb
```
