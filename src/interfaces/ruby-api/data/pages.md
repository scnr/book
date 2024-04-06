# Pages

```ruby
SCNR::Application::API.run do

    Data {
        Pages {
            on :new do |page|
                p page
                # => #<SCNR::Engine::Page:7240 @url="http://testhtml5.vulnweb.com/ajax/popular?offset=0" @dom=#<SCNR::Engine::Page::DOM:7260 @url="http://testhtml5.vulnweb.com/ajax/popular?offset=0" @transitions=1 @data_flow_sinks=0 @execution_flow_sinks=0>>
            end
        }
    }

end
```

## Example

```bash
bin/scnr http://testhtml5.vulnweb.com/ --checks=- --script=pages.rb
```
