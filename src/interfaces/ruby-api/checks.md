# Checks

```ruby
SCNR::Application::API.run do

    Checks {
      
        # Will get called for each check that is run.
        on :run do |check|
            p check
            # => #<SCNR::Engine::Checks::BackupDirectories:0x00007f2d55c66bf8 @page=#<SCNR::Engine::Page:7920 @url="http://testhtml5.vulnweb.com/" @dom=#<SCNR::Engine::Page::DOM:7940 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0>>>
        end

        # This will run from the context of SCNR::Engine::Check::Base; it
        # basically creates a new check component on the fly.
        #
        # This one does something really simple, logs an issue for each 404 page.
        as :not_found,
           issue: {
             name:     'Page not found',
             severity: SCNR::Engine::Issue::Severity::INFORMATIONAL
           } do
            response = page.response
            next if response.code != 404

            log(
              proof:    response.status_line,
              vector:   SCNR::Engine::Element::Server.new( response.url ),
              response: response
            )
        end

    }

end
```

## Example

```bash
bin/scnr http://testhtml5.vulnweb.com --script=checks.rb
```
