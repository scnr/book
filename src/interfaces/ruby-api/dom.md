# Dom

```ruby
SCNR::Application::API.run do

    Dom {
      
        before :load do |resource, options, browser|
            p resource
            # => #<SCNR::Engine::Page::DOM:6160 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0>
            p options
            # => {:take_snapshot=>true}
            p browser
            # => #<SCNR::Engine::BrowserPool::Worker pid= job=#<SCNR::Engine::BrowserPool::Jobs::DOMExploration:6140 @resource=#<SCNR::Engine::Page::DOM:6160 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0> time= timed_out=false> last-url=nil transitions=0>
        end
        
        before :event do |locator, event, options, browser|
            p locator
            # => <li class="active" id="popularLi">
            p event
            # => :click
            p options
            # => {}
            p browser
            # => #<SCNR::Engine::BrowserPool::Worker pid= job=#<SCNR::Engine::BrowserPool::Jobs::DOMExploration::EventTrigger:7760 @resource=#<SCNR::Engine::Page::DOM:7720 @url="http://testhtml5.vulnweb.com/#/popular" @transitions=17 @data_flow_sinks=0 @execution_flow_sinks=0> time= timed_out=false> last-url="http://testhtml5.vulnweb.com/" transitions=17>
        end
        
        on :event do |success, locator, event, options, browser|
            p success
            # => true
            p locator
            # => <li class="active" id="popularLi">
            p event
            # => :click
            p options
            # => {}
            p browser
            # => #<SCNR::Engine::BrowserPool::Worker pid= job=#<SCNR::Engine::BrowserPool::Jobs::DOMExploration::EventTrigger:7760 @resource=#<SCNR::Engine::Page::DOM:7720 @url="http://testhtml5.vulnweb.com/#/popular" @transitions=17 @data_flow_sinks=0 @execution_flow_sinks=0> time= timed_out=false> last-url="http://testhtml5.vulnweb.com/" transitions=17>
        end
        
        after :load do |resource, options, browser|
            p resource
            # => #<SCNR::Engine::Page::DOM:6160 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0>
            p options
            # => {:take_snapshot=>true}
            p browser
            # => #<SCNR::Engine::BrowserPool::Worker pid= job=#<SCNR::Engine::BrowserPool::Jobs::DOMExploration:6140 @resource=#<SCNR::Engine::Page::DOM:6160 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0> time= timed_out=false> last-url="http://testhtml5.vulnweb.com/" transitions=17>
        end
        
        after :event do |transition, locator, event, options, browser|
            p transition
            # => #<SCNR::Engine::Page::DOM::Transition:0x00007f50fc0739c0 @options={}, @event=:click, @element=<a data-scnr-engine-id="1270713017" href="#/popular">, @clock=nil, @time=0.036003384>
            p locator
            # => <a data-scnr-engine-id="1270713017" href="#/popular">
            p event
            # => :click
            p options
            # => {}
            p browser
            # => #<SCNR::Engine::BrowserPool::Worker pid= job=#<SCNR::Engine::BrowserPool::Jobs::DOMExploration::EventTrigger:7680 @resource=#<SCNR::Engine::Page::DOM:7620 @url="http://testhtml5.vulnweb.com/#/popular" @transitions=17 @data_flow_sinks=0 @execution_flow_sinks=0> time= timed_out=false> last-url="http://testhtml5.vulnweb.com/" transitions=17>
        end
        
    }

end
```

## Example

```bash
bin/scnr http://html5.vulnweb.com/ --checks=- --script=dom.rb
```
