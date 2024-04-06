# Issues

```ruby
SCNR::Application::API.run do

    Data {
        Issues {
            on :new do |issue|
                p issue
                # => #<SCNR::Engine::Issue:0x00007f8c50d825a0 @name="Allowed HTTP methods", @description="\nThere are a number of HTTP methods that can be used on a webserver (`OPTIONS`,\n`HEAD`, `GET`, `POST`, `PUT`, `DELETE` etc.).  Each of these methods perform a\ndifferent function and each have an associated level of risk when their use is\npermitted on the webserver.\n\nA client can use the `OPTIONS` method within a request to query a server to\ndetermine which methods are allowed.\n\nCyber-criminals will almost always perform this simple test as it will give a\nvery quick indication of any high-risk methods being permitted by the server.\n\nSCNR::Engine discovered that several methods are supported by the server.\n", @references={"Apache.org"=>"http://httpd.apache.org/docs/2.2/mod/core.html#limitexcept"}, @tags=["http", "methods", "options"], @severity=#<SCNR::Engine::Issue::Severity::Base:0x00007f8c50dccee8 @severity=:informational>, @remedy_guidance="\nIt is recommended that a whitelisting approach be taken to explicitly permit the\nHTTP methods required by the application and block all others.\n\nTypically the only HTTP methods required for most applications are `GET` and\n`POST`. All other methods perform actions that are rarely required or perform\nactions that are inherently risky.\n\nThese risky methods (such as `PUT`, `DELETE`, etc) should be protected by strict\nlimitations, such as ensuring that the channel is secure (SSL/TLS enabled) and\nonly authorised and trusted clients are permitted to use them.\n", @check={:name=>"Allowed methods", :description=>"Checks for supported HTTP methods.", :elements=>[SCNR::Engine::Element::Server], :cost=>1, :author=>"Tasos \"Zapotek\" Laskos <tasos.laskos@gmail.com>", :version=>"0.2", :shortname=>"allowed_methods"}, @vector=#<SCNR::Engine::Element::Server url="http://example.com/">, @proof="OPTIONS, GET, HEAD, POST", @referring_page=#<SCNR::Engine::Page:6560 @url="http://example.com/" @dom=#<SCNR::Engine::Page::DOM:6580 @url="http://example.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0>>, @platform_name=nil, @platform_type=nil, @page=#<SCNR::Engine::Page:6600 @url="http://example.com/" @dom=#<SCNR::Engine::Page::DOM:6620 @url="http://example.com/" @transitions=0 @data_flow_sinks=0 @execution_flow_sinks=0>>, @remarks={}, @trusted=true>
            end

            # Disables Issue storage.
            disable :storage
        }
    }

end
```

## Example

```bash
bin/scnr http://example.com/ --checks=allowed_methods --script=issues.rb
```
