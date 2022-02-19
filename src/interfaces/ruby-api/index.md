# Ruby API

The Ruby API utilizes the [DSeL](https://github.com/qadron/dsel) DSL/API
generator and runner and allows you to:

1. Configure scans.
2. Add custom components on the fly.
3. Create custom scanners.

The API is separated into the following segments:

```ruby
# Runs the DSL.
SCNR::Engine::API.run do

    Data {
        Sitemap {}
        Urls {}
        Pages {}
        Issues {}
    }

    State { }

    Browserpool { }
    
    Dom { }

    Http { }

    Input { }

    Logging { }

    Checks { }

    Plugins { }

    Fingerprinters { }

    Scan {
        Options { }

        Scope { }

        Session { }
    }

end
```

## Examples

### As configuration

```ruby
SCNR::Engine::API.run do

    Dom {

        # Allow some time for the modal animation to complete in order for
        # the login form to appear.
        # 
        # (Not actually necessary, this is just an example on how to hande quirks.)
        on :event do |_, locator, event, *|
            next if locator.attributes['href'] != '#myModal' || event != :click
            sleep 1
        end
    }

    Checks {

        # This will run from the context of SCNR::Engine::Check::Base; it
        # basically creates a new check component on the fly.
        #
        # Does something really simple, logs an issue for each 404 page.
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

    Plugins {

        # This will run from the context of SCNR::Engine::Plugin::Base; it
        # basically creates a new plugin component on the fly.
        as :my_plugin do
            # Do stuff then wait until scan completes.
            wait_while_framework_running
            # Do stuff after scan completes.
        end

    }

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

        Scope {
            # Don't visit resources that will end the session.
            reject :url do |url|
                url.path.optimized_include?( 'login' ) ||
                  url.path.optimized_include?( 'logout' )
            end
        }
    }

end
```

Supposing the above is saved as `html5.config.rb`:

```bash
bin/scnr http://testhtml5.vulnweb.com --script=html5.config.rb
```

### Standalone

This basically creates a custom scanner.

```ruby
require 'scnr/engine/api'

# Mute output messages from the CLI interface, we've got our own output methods.
SCNR::UI::CLI::Output.mute

SCNR::Engine::API.run do

    State {
        on :change do |state|
            puts "State\t\t- #{state.status.capitalize}"
        end
    }

    Data {
        Issues {
            on :new do |issue|
                puts "Issue\t\t- #{issue.name} from `#{issue.referring_page.dom.url}`" <<
                       " in `#{issue.vector.type}`."
            end
        }
    }

    Logging {
        on :error do |error|
            $stderr.puts "Error\t\t- #{error}"
        end

        # Way too much noise.
        # on :exception do |exception|
        #     ap exception
        #     ap exception.backtrace
        # end
    }

    Dom {

        # Allow some time for the modal animation to complete in order for
        # the login form to appear.
        # 
        # (Not actually necessary, this is just an example on how to hande quirks.)
        on :event do |_, locator, event, *|
            next if locator.attributes['href'] != '#myModal' || event != :click
            sleep 1
        end
    }

    Checks {

        # This will run from the context of SCNR::Engine::Check::Base; it
        # basically creates a new check component on the fly.
        #
        # Does something really simple, logs an issue for each 404 page.
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

    Plugins {

        # This will run from the context of SCNR::Engine::Plugin::Base; it
        # basically creates a new plugin component on the fly.
        as :my_plugin do
            puts "#{shortname}\t- Running..."
            wait_while_framework_running
            puts "#{shortname}\t- Done!"
        end

    }

    Scan {
        Options {
            set url:    'http://testhtml5.vulnweb.com',
                audit:  {
                  elements: [:links, :forms, :cookies]
                },
                checks: ['*']
        }

        Session {
            to :login do |browser|
                print "Session\t\t- Logging in..."

                # Login with whichever interface you prefer.
                watir    = browser.watir
                selenium = browser.selenium

                watir.goto SCNR::Engine::Options.url

                watir.link( href: '#myModal' ).click

                form = watir.form( id: 'loginForm' )
                form.text_field( name: 'username' ).set 'admin'
                form.text_field( name: 'password' ).set 'admin'
                form.submit

                if browser.response.body =~ /<b>admin/
                    puts 'done!'
                else
                    puts 'failed!'
                end
            end

            to :check do |async|
                print "Session\t\t- Checking..."

                http_client = SCNR::Engine::HTTP::Client
                check       = proc { |r| r.body.optimized_include? '<b>admin' }

                # If an async block is passed, then the framework would rather
                # schedule it to run asynchronously.
                if async
                    http_client.get SCNR::Engine::Options.url do |response|
                        success = check.call( response )

                        puts "logged #{success ? 'in' : 'out'}!"

                        async.call success
                    end
                else
                    response = http_client.get( SCNR::Engine::Options.url, mode: :sync )
                    success = check.call( response )

                    puts "logged #{success ? 'in' : 'out'}!"

                    success
                end
            end
        }

        Scope {
            # Don't visit resources that will end the session.
            reject :url do |url|
                url.path.optimized_include?( 'login' ) ||
                  url.path.optimized_include?( 'logout' )
            end
        }

        before :page do |page|
            puts "Processing\t- [#{page.response.code}] #{page.dom.url}"
        end

        on :page do |page|
            puts "Scanning\t- [#{page.response.code}] #{page.dom.url}"
        end

        after :page do |page|
            puts "Scanned\t\t- [#{page.response.code}] #{page.dom.url}"
        end

        run! do |report, statistics|
            puts
            puts '=' * 80
            puts

            puts "[#{report.sitemap.size}] Sitemap:"
            puts
            report.sitemap.sort_by { |url, _| url }.each do |url, code|
                puts "\t[#{code}] #{url}"
            end

            puts
            puts '-' * 80
            puts

            puts "[#{report.issues.size}] Issues:"
            puts
            report.issues.each.with_index do |issue, idx|
                s = "\t[#{idx+1}] #{issue.name} in `#{issue.vector.type}`"
                if issue.vector.respond_to?( :affected_input_name ) &&
                  issue.vector.affected_input_name
                    s << " input `#{issue.vector.affected_input_name}`"
                end
                puts s << '.'

                puts "\t\tAt `#{issue.page.dom.url}` from `#{issue.referring_page.dom.url}`."

                if issue.proof
                    puts "\t\tProof:\n\t\t\t#{issue.proof.gsub( "\n", "\n\t\t\t" )}"
                end

                puts
            end

            puts
            puts '-' * 80
            puts

            puts "Statistics:"
            puts
            puts "\t" << statistics.ai.gsub( "\n", "\n\t" )
        end
    }

end
```

Supposing the above is saved as `html5.scanner.rb`:

```bash
bin/scnr_script html5.scanner.rb
```

