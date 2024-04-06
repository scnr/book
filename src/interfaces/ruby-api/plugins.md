# Plugins

```ruby
SCNR::Application::API.run do

    Plugins {

        # Will get called upon plugin class initialization.
        on :initialize do |plugin|
            p plugin
            # => #<SCNR::Engine::Plugins::AutoThrottle:0x00007f8896ccacd8 @options={}>
        end

        # Will get called when each plugin's #prepare method is called.
        on :prepare do |plugin|
        end

        # Will get called when each plugin's #run method is called.
        on :run do |plugin|
        end

        # Will get called when each plugin's #clean_up method is called.
        on :clean_up do |plugin|
        end

        # Will get called when each plugin is done running.
        on :done do |plugin|
        end
        
        # This will run from the context of SCNR::Engine::Plugin::Base; it
        # basically creates a new plugin component on the fly.
        as :my_plugin do
            # Do stuff then wait until scan completes.
            wait_while_framework_running
            # Do stuff after scan completes.
        end

    }

end
```

## Example

```bash
bin/scnr http://testhtml5.vulnweb.com --checks=- --script=plugins.rb
```
