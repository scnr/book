# Options

```ruby
SCNR::Engine::API.run do

    Scan {
        Options {

            # Sets options.
            set({
                  url: 'http://testhtml5.vulnweb.com',
                  audit: {
                    parameter_values: true,
                    paranoia: :medium,
                    exclude_vector_patterns: [],
                    include_vector_patterns: [],
                    link_templates: []
                  },
                  device: {
                    visible: false,
                    width: 1600,
                    height: 1200,
                    user_agent: "Mozilla/5.0 (Gecko) SCNR::Engine/v1.0dev",
                    pixel_ratio: 1.0,
                    touch: false
                  },
                  dom: {
                    engine: :chrome,
                    local_storage: {},
                    session_storage: {},
                    wait_for_elements: {},
                    pool_size: 4,
                    job_timeout: 60,
                    worker_time_to_live: 250,
                    wait_for_timers: false
                  },
                  http: {
                    request_timeout: 20000,
                    request_redirect_limit: 5,
                    request_concurrency: 10,
                    request_queue_size: 50,
                    request_headers: {},
                    response_max_size: 500000,
                    cookies: {},
                    authentication_type: "auto"
                  },
                  input: {
                    values: {},
                    default_values: {
                      "name" => "scnr_engine_name",
                      "user" => "scnr_engine_user",
                      "usr" => "scnr_engine_user",
                      "pass" => "5543!%scnr_engine_secret",
                      "txt" => "scnr_engine_text",
                      "num" => "132",
                      "amount" => "100",
                      "mail" => "scnr_engine@email.gr",
                      "account" => "12",
                      "id" => "1"
                    },
                    without_defaults: false,
                    force: false
                  },
                  scope: {
                    directory_depth_limit: 10,
                    auto_redundant_paths: 15,
                    redundant_path_patterns: {},
                    dom_depth_limit: 4,
                    dom_event_limit: 500,
                    dom_event_inheritance_limit: 500,
                    exclude_file_extensions: [],
                    exclude_path_patterns: [],
                    exclude_content_patterns: [],
                    include_path_patterns: [],
                    restrict_paths: [],
                    extend_paths: [],
                    url_rewrites: {}
                  },
                  session: {},
                  checks: [
                    "*"
                  ],
                  platforms: [],
                  plugins: {},
                  no_fingerprinting: false,
                  authorized_by: nil
            })
            
        }
    }

end
```
