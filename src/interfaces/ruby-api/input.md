# Input

```ruby
SCNR::Application::API.run do

    Input {

        # Fill-in values for the given element; must return Hash not alter the element.
        values do |element|
            p element
            # => #<SCNR::Engine::Element::Form (post) auditor=SCNR::Engine::Trainer::SinkTracer url="http://testhtml5.vulnweb.com/" action="http://testhtml5.vulnweb.com/login" default-inputs={"username"=>"admin", "password"=>"", "loginFormSubmit"=>""} inputs={"username"=>"admin", "password"=>"5543!%scnr_engine_secret", "loginFormSubmit"=>"1"} raw_inputs=[] >
            element.inputs
        end
   
    }

end
```

## Example

```bash
bin/scnr https://testhtml5.vulnweb.com --checks=xss --script=input.rb
```
