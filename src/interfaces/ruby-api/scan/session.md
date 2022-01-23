# Session

```ruby
SCNR::Engine::API.run do

    Scan {

        Session {
            to :login do |browser|
                # Login with whichever interface you prefer.
                watir    = browser.watir
                selenium = browser.selenium

                watir.goto SCNR::Engine::Options.url

                watir.link( href: '#myModal' ).click

                form = watir.form( id: 'loginForm' )
                form.text_field( name: 'username' ).set 'admin'
                form.text_field( name: 'password' ).set 'admin'
                form.submit
            end

            to :check do |async|
                http_client = SCNR::Engine::HTTP::Client
                check       = proc { |r| r.body.optimized_include? '<b>admin' }

                # If an async block is passed, then the framework would rather
                # schedule it to run asynchronously.
                if async
                    http_client.get SCNR::Engine::Options.url do |response|
                        success = check.call( response )
                        async.call success
                    end
                else
                    response = http_client.get( SCNR::Engine::Options.url, mode: :sync )
                    check.call( response )
                end
            end
        }

    }

end
```

## Example

```bash
bin/scnr http://testhtml5.vulnweb.com --checks=- --script=session.rb
```
