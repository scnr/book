# Fingerprinters

```ruby
SCNR::Engine::API.run do

    Fingerprinters {

        # Identify `*.x` resources as PHP.
        as :x_as_php do
            next unless extension == 'x'
            platforms << :php
        end
    }

end
```

## Example

```bash
bin/scnr http://testhtml5.vulnweb.com --checks=- --script=fingerprinters.rb
```
