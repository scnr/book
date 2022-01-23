# Http

```ruby
SCNR::Engine::API.run do

    Http {
      
        on :request do |request|
            p request
            # => #<SCNR::Engine::HTTP::Request @id= @mode=async @method=get @url="https://wordpress.com/" @parameters={} @high_priority= @performer=#<SCNR::Engine::Framework (scanning) runtime=0.805773919 found-pages=0 audited-pages=0 issues=0 checks= plugins=autothrottle,healthmap,discovery,timing_attacks,uniformity>>
        end
        
        on :response do |response|
            p response
            # => #<SCNR::Engine::HTTP::Response:0x00007fd6e75923b8 ..>
        end
        
        on :cookies do |cookies|
            p cookies
            # => [#<SCNR::Engine::Element::Cookie (get) url="https://wordpress.com/start/?ref=logged-out-homepage-lp" action="https://wordpress.com/start/?ref=logged-out-homepage-lp" default-inputs={"country_code"=>"GR"} inputs={"country_code"=>"GR"} raw_inputs=[] >]
        end
        
        # Block to run after each HTTP request batch run.
        after :run do
        end
        
    }

end
```

## Example

```bash
bin/scnr https://wordpress.com --checks=- --script=http.rb
```
