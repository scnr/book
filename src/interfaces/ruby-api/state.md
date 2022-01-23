# State

```ruby
SCNR::Engine::API.run do

    State {
        on :change do |state|
            p state.status
            # => :preparing
        end
    }

end
```

## Example

```bash
bin/scnr http://example.com/ --checks=- --script=state.rb
```
