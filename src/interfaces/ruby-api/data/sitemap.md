# Sitemap

```ruby
SCNR::Application::API.run do

    Data {
        Sitemap {
            on :new do |entry|
                p entry
                # => { "http://example.com" => 200 }
                #           URL             => HTTP code
            end
        }
    }

end
```

## Example

```bash
bin/spectre http://example.com/ --checks=- --script=sitemap.rb
```
