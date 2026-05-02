# Urls

```ruby
SCNR::Application::API.run do

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
bin/spectre http://example.com/ --checks=- --script=urls.rb
```
