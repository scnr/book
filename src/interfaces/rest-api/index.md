# REST

## Server

To start the REST server daemon:

```bash
bin/scnr_rest_server
```

To see REST server daemon options:

```bash
bin/scnr_rest_server -h
```


## API

### Scan

| Method   | Resource                          | Parameters            | Description          |
|----------|-----------------------------------|-----------------------|----------------------|
| `GET`    | `/instances/:id/scan/progress`    |                       | Get scan progress.   |
| `GET`    | `/instances/:id/scan/report.json` |                       | Get the scan report. |


### Instances

| Method   | Resource                     | Parameters            | Description                                                          |
|----------|------------------------------|-----------------------|----------------------------------------------------------------------|
| `GET`    | `/instances`                 |                       | List all _Instances_.                                                |
| `POST`   | `/instances`                 | Scan options (`Hash`) | Create a new _Instance_ with the given scan options.                 |
| `GET`    | `/instances/:id`             |                       | Get progress info for _Instance_.                                    |
| `PUT`    | `/instances/:id/scheduler`   |                       | If a _Scheduler_ has been set, put the _Instance_ under its purview. |
| `GET`    | `/instances/:id/report.crf`  |                       | Get a Cuboid report for the _Instance_.                              |
| `GET`    | `/instances/:id/report.json` |                       | Get a JSON report for the _Instance_.                                |
| `PUT`    | `/instances/:id/pause`       |                       | Pause the _Instance_.                                                |
| `PUT`    | `/instances/:id/resume`      |                       | Resume the _Instance_.                                               |
| `DELETE` | `/instances/:id`             |                       | Shutdown the _Instance_.                                             |

#### Scan options

```
{
  "url": "http://testhtml5.vulnweb.com",
  "session": {
  },
  "audit": {
    "parameter_values": true,
    "mode": "moderate",
    "exclude_vector_patterns": [

    ],
    "include_vector_patterns": [

    ],
    "link_templates": [

    ],
    "links": true,
    "forms": true,
    "cookies": true,
    "headers": true,
    "ui_inputs": true,
    "ui_forms": true
  },
  "scope": {
    "directory_depth_limit": 10,
    "auto_redundant_paths": 15,
    "redundant_path_patterns": {
    },
    "dom_depth_limit": 4,
    "dom_event_limit": 500,
    "dom_event_inheritance_limit": 500,
    "exclude_file_extensions": [
      "gif",
      "bmp",
      "tif",
      "tiff",
      "jpg",
      "jpeg",
      "jpe",
      "pjpeg",
      "png",
      "ico",
      "psd",
      "xcf",
      "3dm",
      "max",
      "svg",
      "eps",
      "drw",
      "ai",
      "asf",
      "rm",
      "mpg",
      "mpeg",
      "mpe",
      "3gp",
      "3g2",
      "avi",
      "flv",
      "mov",
      "mp4",
      "swf",
      "vob",
      "wmv",
      "aif",
      "mp3",
      "mpa",
      "ra",
      "wav",
      "wma",
      "mid",
      "m4a",
      "ogg",
      "flac",
      "zip",
      "zipx",
      "tar",
      "gz",
      "7z",
      "rar",
      "bz2",
      "bin",
      "cue",
      "dmg",
      "iso",
      "mdf",
      "vcd",
      "raw",
      "exe",
      "apk",
      "app",
      "jar",
      "pkg",
      "deb",
      "rpm",
      "msi",
      "ttf",
      "otf",
      "woff",
      "woff2",
      "fon",
      "fnt",
      "css",
      "js",
      "pdf",
      "docx",
      "xlsx",
      "pptx",
      "odt",
      "odp"
    ],
    "exclude_path_patterns": [

    ],
    "exclude_content_patterns": [

    ],
    "include_path_patterns": [

    ],
    "restrict_paths": [

    ],
    "extend_paths": [

    ],
    "url_rewrites": {
    }
  },
  "http": {
    "request_timeout": 20000,
    "request_redirect_limit": 5,
    "request_concurrency": 10,
    "request_queue_size": 50,
    "request_headers": {
    },
    "response_max_size": 500000,
    "cookies": {
    },
    "authentication_type": "auto"
  },
  "device": {
    "visible": false,
    "width": 1600,
    "height": 1200,
    "user_agent": "Mozilla/5.0 (Gecko) SCNR::Engine/v1.0dev",
    "pixel_ratio": 1.0,
    "touch": false
  },
  "dom": {
    "engine": "chrome",
    "local_storage": {
    },
    "session_storage": {
    },
    "wait_for_elements": {
    },
    "pool_size": 10,
    "job_timeout": 120,
    "worker_time_to_live": 1000,
    "wait_for_timers": false
  },
  "input": {
    "values": {
    }
  },
  "checks": [

  ],
  "platforms": [

  ],
  "plugins": {
  },
  "no_fingerprinting": false,
  "authorized_by": null
}
```

### Agent

| Method   | Resource          | Parameters   | Description                         |
|----------|-------------------|--------------|-------------------------------------|
| `GET`    | `/agent/url` |              | Get the configured _Agent_ URL. |
| `PUT`    | `/agent/url` | URL (`String`) | Set the _Agent_ URL.           |
| `DELETE` | `/agent/url` |              | Remove the _Agent_.         |


### Grid

| Method   | Resource            | Parameters | Description                                        |
|----------|---------------------|------------|----------------------------------------------------|
| `GET`    | `/grid`             |            | Get _Grid_ info.                                   |
| `GET`    | `/grid/:agent` |            | Get info of _Grid_ member by URL.                  |
| `DELETE` | `/grid/:agent` |            | Unplug _Agent_ from the _Grid_ by URL. |


### Scheduler

| Method   | Resource                      | Parameters            | Description                                              |
|----------|-------------------------------|-----------------------|----------------------------------------------------------|
| `GET`    | `/scheduler`                  |                       | Get _Scheduler_ info.                                    |
| `GET`    | `/scheduler/url`              |                       | Get _Scheduler_ URL.                                     |
| `PUT`    | `/scheduler/url`              | URL (`String`)        | Set the _Scheduler_ URL.                                 |
| `DELETE` | `/scheduler/url`              |                       | Remove the configured _Scheduler_.                       |
| `GET`    | `/scheduler/running`          |                       | Get running _Instances_.                                 |
| `GET`    | `/scheduler/completed`        |                       | Get completed _Instances_.                               |
| `GET`    | `/scheduler/failed`           |                       | Get failed _Instances_.                                  |
| `GET`    | `/scheduler/size`             |                       | Get queue size.                                          |
| `DELETE` | `/scheduler/`                 |                       | Clear _Scheduler_ queue.                                 |
| `POST`   | `/scheduler/`                 | Scan options (`Hash`) | Push a scan to the _Scheduler_ queue.                    |
| `GET`    | `/scheduler/:instance`        |                       | Get _Instance_ info.                                     |
| `PUT`    | `/scheduler/:instance/detach` |                       | Detach the given _Instance_ from the _Scheduler_.        |
| `DELETE` | `/scheduler/:instance`        |                       | Remove queued _Instance_ job from the _Scheduler_ queue. |

## Examples

### Starting the REST server

Start the server by issuing the following command:

`bin/scnr_rest_server`

### Client

```ruby
#!/usr/bin/env ruby

require 'pp'
require_relative 'http-helpers'

# Create a new scanner Instance (process) and run a scan with the following options.
request :post, 'instances', {

  # Scan this URL.
  url:    'http://testhtml5.vulnweb.com',

  # Audit all element types.
  audit:  {
    elements: [:links, :forms, :cookies, :headers, :jsons, :xmls, :ui_inputs, :ui_forms]
  },

  # Load all active checks.
  checks: 'active/*'
}

# The ID is used to represent that instance and allow us to manage it from here on out.
instance_id = response_data['id']

while sleep( 1 )
  request :get, "instances/#{instance_id}/scan/progress", {
    # Get the hash-map representation of native objects, like issues.
    as_hash: true,
    # Include these types of objects only.
    with: [:issues, :sitemap, :errors]
  }

  # Print out instance progress.
  pp response_data

  # Continue looping while instance status is 'busy'.
  request :get, "instances/#{instance_id}"
  break if !response_data['busy']
end

puts '*' * 88

# Get the scan report.
request :get, "instances/#{instance_id}/scan/report.json"
# Print out the report.
pp response_data

# Shutdown the Instance.
request :delete, "instances/#{instance_id}"
```

#### HTTP helpers

This client example included some helpers for the HTTP requests:

```ruby
require 'json'
require 'tmpdir'
require 'typhoeus'

def response
  if @last_response.headers['Content-Type'].include? 'json'
    data = JSON.load( @last_response.body )
  else
    data = @last_response.body
  end
  {
    code: @last_response.code,
    data: data
  }
end

def response_data
  response[:data]
end

def request( method, resource = nil, parameters = nil )
  options = {}

  if parameters
    if method == :get
      options[:params] = parameters
    else
      options[:body] = parameters.to_json
    end
  end

  options[:cookiejar]  = "#{Dir.tmpdir}/cookiejar.txt"
  options[:cookiefile] = options[:cookiejar]

  @last_response = Typhoeus.send(
    method,
    "http://127.0.0.1:7331/#{resource}",
    options
  )
end
```
