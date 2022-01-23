# Browserpool

```ruby
SCNR::Engine::API.run do

    Browserpool {
      
        # When a job is queued.
        on :job do |job|
            p job
            # => #<SCNR::Engine::BrowserPool::Jobs::DOMExploration:6140 @resource=#<SCNR::Engine::Page::DOM:6160 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0> time= timed_out=false>
        end

        # When a job has completed.
        on :job_done do |job|
            p job
            # => #<SCNR::Engine::BrowserPool::Jobs::DOMExploration:6140 @resource=#<SCNR::Engine::Page::DOM:6160 @url="http://testhtml5.vulnweb.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0> time=2.805975399 timed_out=false>
        end
        
        # When a job has yielded a result.
        on :result do |result|
            p result
            # => #<SCNR::Engine::BrowserPool::Jobs::DOMExploration::Result:0x00007f51a167c218 @page=#<SCNR::Engine::Page:7340 @url="http://testhtml5.vulnweb.com/ajax/popular?offset=0" @dom=#<SCNR::Engine::Page::DOM:7360 @url="http://testhtml5.vulnweb.com/ajax/popular?offset=0" @transitions=1 @data_flow_sinks=0 @execution_flow_sinks=0>>, @job=#<SCNR::Engine::BrowserPool::Jobs::DOMExploration:7320 @resource= time= timed_out=false>>
        end
    }

end
```

## Example

```bash
bin/scnr http://html5.vulnweb.com/ --checks=- --script=browserpool.rb
```
