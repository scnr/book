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
