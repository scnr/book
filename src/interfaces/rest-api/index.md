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

| Method   | Resource                       | Parameters            | Description        |
|----------|--------------------------------|-----------------------|--------------------|
| `GET`    | `/instances/:id/scan/progress` |                       | Get scan progress. |


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
  "url": "http://example.com",
  "session": {},
  "audit": {
    "paranoia": "medium",
    "exclude_vector_patterns": [],
    "include_vector_patterns": [],
    "link_templates": []
  },
  "scope": {
    "directory_depth_limit": 10,
    "auto_redundant_paths": 15,
    "redundant_path_patterns": {},
    "dom_depth_limit": 4,
    "dom_event_limit": 500,
    "dom_event_inheritance_limit": 500,
    "exclude_file_extensions": [],
    "exclude_path_patterns": [],
    "exclude_content_patterns": [],
    "include_path_patterns": [],
    "restrict_paths": [],
    "extend_paths": [],
    "url_rewrites": {}
  },
  "http": {
    "request_timeout": 20000,
    "request_redirect_limit": 5,
    "request_concurrency": 10,
    "request_queue_size": 50,
    "request_headers": {},
    "response_max_size": 500000,
    "cookies": {},
    "authentication_type": "auto"
  },
  "device": {
    "visible": false,
    "width": 1600,
    "height": 1200,
    "user_agent": "Mozilla/5.0 (Gecko) SCNR::Engine/v1.0dev",
    "pixel_ratio": 1,
    "touch": false
  },
  "dom": {
    "engine": "chrome",
    "local_storage": {},
    "session_storage": {},
    "wait_for_elements": {},
    "pool_size": 10,
    "job_timeout": 120,
    "worker_time_to_live": 1000,
    "wait_for_timers": false
  },
  "input": {
    "values": {},
    "default_values": {
      "name": "scnr_engine_name",
      "user": "scnr_engine_user",
      "usr": "scnr_engine_user",
      "pass": "5543!%scnr_engine_secret",
      "txt": "scnr_engine_text",
      "num": "132",
      "amount": "100",
      "mail": "scnr_engine@email.gr",
      "account": "12",
      "id": "1"
    },
  },
  "checks": [],
  "platforms": [],
  "plugins": {},
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
