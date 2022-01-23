# Scope

Determines which resources are in or out of scope. All return values will be cast
to boolean.

```ruby
SCNR::Engine::API.run do

    Scan {
        Scope {
          
            select :url do |url|
            end

            select :page do |page|
            end

            select :element do |element|
            end

            select :event do |locator, event, options, browser|
            end

            reject :url do |url|
            end

            reject :page do |page|
            end

            reject :element do |element|
            end

            reject :event do |locator, event, options, browser|
            end

        }
    }

end
```

## Example

```bash
bin/scnr http://testhtml5.vulnweb.com --checks=- --script=scope.rb
```
