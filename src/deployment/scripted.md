# Scripted

Scripted scans allow you to configure the system and take over decision making points
for a much more fine-grained scan.
Aside from that, scripts also allow you to quickly add custom components on the
fly.

Scan scripts can either be a form of configuration or standalone scanners.

## Examples

### As configuration

#### With helpers

`html5.config.rb`:
```ruby
SCNR::Application::API.run do
  require '/home/user/script/helpers'

  Dom {
    on :event, &method(:on_event_handler)
  }

  Checks {

    # This will run from the context of SCNR::Engine::Check::Base; it
    # basically creates a new check component on the fly.
    as :not_found, check_404_info, method(:check_404)
 
  }

  Plugins {

    # This will run from the context of SCNR::Engine::Plugin::Base; it
    # basically creates a new plugin component on the fly.
    as :my_plugin, my_plugin_info, method(:my_plugin)

  }

  Scan {

    Session {
      to :login, &method(:login)
      to :check, &method(:login_check)
    }

    Scope {
      # Don't visit resources that will end the session.
      reject :url, &method(:to_logout)
    }
  }

end
```

`helpers.rb`:
```ruby
# Allow some time for the modal animation to complete in order for
# the login form to appear.
#
# (Not actually necessary, this is just an example on how to hande quirks.)
def on_event_handler( result, locator, event, options, browser )
  return if locator.attributes['href'] != '#myModal' || event != :click
  sleep 1
end

# Does something really simple, logs an issue for each 404 page.
def check_404
  response = page.response
  return if response.code != 404

  log(
    proof:    response.status_line,
    vector:   SCNR::Engine::Element::Server.new( response.url ),
    response: response
  )
end

def check_404_info
  {
    issue: {
      name:     'Page not found',
      severity: SCNR::Engine::Issue::Severity::INFORMATIONAL
    }
  }
end

def my_plugin
  # Do stuff then wait until scan completes.
  wait_while_framework_running
  # Do stuff after scan completes.
end

def my_plugin_info
  {
    name: 'My Plugin',
    description: 'Just waits for the scan to finish,'
  }
end

def login( browser )
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

def login_check( &in_async_mode )
  http_client = SCNR::Engine::HTTP::Client
  check       = proc { |r| r.body.optimized_include? '<b>admin' }

  # If an async block is passed, then the framework would rather
  # schedule it to run asynchronously.
  if in_async_mode
    http_client.get SCNR::Engine::Options.url do |response|
      in_async_mode.call check.call( response )
    end
  else
    response = http_client.get( SCNR::Engine::Options.url, mode: :sync )
    check.call( response )
  end
end

def to_logout( url )
  url.path.optimized_include?( 'login' ) ||
    url.path.optimized_include?( 'logout' )
end
```

#### Single file

```ruby
SCNR::Application::API.run do

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

The difference is that these scripts will run a scan and handle its results on their own,
and not just serve as configuration.

#### With helpers

When a scan script is large-ish and/or complicated it's better to split it into the main file and helper handler methods.

```bash
bin/scnr_script scanner.rb
```

`scanner.rb`:
```ruby
require 'scnr/engine/api'

require "#{Options.paths.root}/tmp/scripts/with_helpers/helpers"

SCNR::Application::API.run do

  Scan {

    # Can also be written as:
    #
    # options.set(
    #   url:    'http://testhtml5.vulnweb.com',
    #   audit:  {
    #     elements: [:links, :forms, :cookies, :ui_inputs, :ui_forms]
    #   },
    #   checks: ['*']
    # )
    Options {
      set url:    'http://my-site.com',
          audit:  {
            elements: [:links, :forms, :cookies, :ui_inputs, :ui_forms]
          },
          checks: ['*']
    }

    # Scan session configuration.
    Session {
      # Login using the #fill_in_and_submit_the_login_form method from the helpers.rb file.
      to :login, :fill_in_and_submit_the_login_form

      # Check for a valid session using the #find_welcome_message method from the helpers.rb file.
      to :check, :find_welcome_message
    }

    # Scan scope configuration.
    Scope {

      # Limit the scope of the scan based on URL.
      select :url, :within_the_eshop

      # Limit the scope of the scan based on Element.
      reject :element, :with_sensitive_action; also :with_weird_nonce

      # Only select pages that are in the admin panel.
      select :page, :in_admin_panel

      # Limit the scope of the scan based on Page.
      reject :page, :with_error

      # Limit the scope of the scan based on DOM events and DOM elements.
      # In this case, never click the logout button!
      reject :event, :that_clicks_the_logout_button

    }

    # Run the scan and handle the results (in this case print to STDOUT) using #handle_results.
    run! :handle_results
  }

  Logging {

    # Error and exception handling.
    on :error,     :log_error
    on :exception, :log_exception

  }

  Data {

    # Don't store issues in memory, we'll send them to the DB.
    issues.disable(:storage).on :new, :save_to_db

    # Could also be written as:
    #
    #   Issues {
    #       disable(:storage)
    #       on :new, :save_to_db)
    #   }
    #
    # Or:
    #
    #   Issues { disable(:storage); on :new, :save_to_db)  }

    # Store every page in the DB too for later analysis.
    pages.on :new, :save_to_db

    # Or:
    #
    #   Pages {
    #       on :new, :save_to_db
    #   }

  }

  Http {
    on :request, :add_special_auth_header
    on :response, :gather_traffic_data; also :increment_http_performer_count
  }

  Checks {

    # Add a custom check on the fly to check for something simple specifically
    # for this scan.
    as :missing_important_header, with_missing_important_header_info,
       :log_pages_with_missing_important_headers

  }

  # Been having trouble with this scan, collect some runtime statistics.
  plugins.as :remote_debug, send_debugging_info_to_remote_server_info,
             :send_debugging_info_to_remote_server

  # Serves PHP scripts under the extension 'x'.
  fingerprinters.as :php_x, :treat_x_as_php

  Input {

    # Vouchers and serial numbers need to come from an algorithm.
    values :with_valid_role_id

  }

  Dom {

    # Let's have a look inside the live JS env of those interesting pages,
    # setup the data collection.
    before :load, :start_js_data_gathering
    after  :load, :retrieve_js_data; also :event, :retrieve_event_js_data

  }

end
```

`helpers.rb`:
```ruby
# State

def log_error( error )
  # ...
end
def log_exception( exception )
  # ...
end

# Data

def save_to_db( obj )
  # Do stufff...
end
def save_js_data_to_db( data, element, event )
  # Do other stufff...
end

# Scope

def within_the_eshop( url )
  url.path.start_with? '/eshop'
end

def with_error( page )
  /Error/i.match? page.body
end

def in_admin_panel( page )
  /Admin panel/i.match? page.body
end

def that_clicks_the_logout_button( event, element )
  event == :click && element.tag_name == :button &&
    element.attributes['id'] == 'logout'
end

def with_sensitive_action( element )
  element.action.include? '/sensitive.php'
end

def with_weird_nonce( element )
  element.inputs.include? 'weird_nonce'
end

# HTTP

def generate_request_header
  # ...
end
def save_raw_http_response( response )
  # ...
end
def save_raw_http_request( request )
  # ...
end

def add_special_auth_header( request )
  request.headers['Special-Auth-Header'] ||= generate_request_header
end

def increment_http_performer_count( response )
  # Count the amount of requests/responses this system component has
  # performed/received.
  #
  # Performers can be browsers, checks, plugins, session, etc.
  stuff( response.request.performer.class )
end

def gather_traffic_data( response )
  # Collect raw HTTP traffic data.
  save_raw_http_response( response.to_s )
  save_raw_http_request( response.request.to_s )
end

# Checks

def with_missing_important_header_info
  {
    name:        'Missing Important-Header',
    description: %q{Checks pages for missing `Important-Header` headers.},
    elements:    [ Element::Server ],
    issue:       {
      name:        %q{Missing 'Important-Header' header},
      severity:    Severity::INFORMATIONAL
    }
  }
end

# This will run from the context of a Check::Base.
def log_pages_with_missing_important_headers
  return if audited?( page.parsed_url.host ) ||
    page.response.headers['Important-Header']

  audited( page.parsed_url.host )

  log(
    vector: Element::Server.new( page.url ),
    proof:  page.response.headers_string
  )
end

# Plugins

# This will run from the context of a Plugin::Base.
def send_debugging_info_to_remote_server
  address = '192.168.0.11'
  port    = 81
  auth    = Utilities.random_seed

  url = `start_remote_debug_server.sh -a #{address} -p #{port} --auth #{auth}`
  url.strip!

  http.post( url,
             body: SCNR::Engine::SCNR::Engine::Options.to_h.to_json,
             mode: :sync
  )

  while framework.running? && sleep( 5 )
    http.post( "#{url}/statistics",
               body: framework.statistics.to_json,
               mode: :sync
    )
  end
end

def send_debugging_info_to_remote_server_info
  {
    name: 'Debugger'
  }
end

# Fingerprinters

# This will run from the context of a Fingerprinter::Base.
def treat_x_as_php
  return if extension != 'x'
  platforms << :php
end

# Session

def fill_in_and_submit_the_login_form( browser )
  browser.load "#{SCNR::Engine::SCNR::Engine::Options.url}/login"

  form = browser.form
  form.text_field( name: 'username' ).set 'john'
  form.text_field( name: 'password' ).set 'doe'

  form.input( name: 'submit' ).click
end

def find_welcome_message
  http.get( SCNR::Engine::Options.url, mode: :sync ).body.include?( 'Welcome user!' )
end

# Inputs

def with_valid_code( name, current_value )
  {
    'voucher-code'  => voucher_code_generator( current_value ),
    'serial-number' => serial_number_generator( current_value )
  }[name]
end

def with_valid_role_id( inputs )
  return if !inputs.include?( 'role-type' )

  inputs['role-id'] ||= (inputs['role-type'] == 'manager' ? 1 : 2)
  inputs
end

# Browser

def start_js_data_gathering( page, browser )
  return if !page.url.include?( 'something/interesting' )

  browser.javascript.inject <<JS
    // Gather JS data from listeners etc.
    window.secretJSData = {};
JS
end

def retrieve_js_data( page, browser )
  return if !page.url.include?( 'something/interesting' )

  save_js_data_to_db(
    browser.javascript.run( 'return window.secretJSData' ),
    page, :load
  )
end

def retrieve_event_js_data( event, element, browser )
  return if !browser.url.include?( 'something/interesting' )

  save_js_data_to_db(
    browser.javascript.run( 'return window.secretJSData' ),
    element, event
  )
end

def handle_results( report, statistics )
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
```

#### Single file

```ruby
require 'scnr/engine/api'

# Mute output messages from the CLI interface, we've got our own output methods.
SCNR::UI::CLI::Output.mute

SCNR::Application::API.run do

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
