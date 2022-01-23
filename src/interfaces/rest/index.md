# REST API

## Scan

| Method   | Resource                       | Parameters            | Description        |
|----------|--------------------------------|-----------------------|--------------------|
| `GET`    | `/instances/:id/scan/progress` |                       | Get scan progress. |


## Instances

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

## Dispatcher

| Method   | Resource          | Parameters   | Description                         |
|----------|-------------------|--------------|-------------------------------------|
| `GET`    | `/dispatcher/url` |              | Get the configured _Dispatcher_ URL. |
| `PUT`    | `/dispatcher/url` | URL (`String`) | Set the _Dispatcher_ URL.           |
| `DELETE` | `/dispatcher/url` |              | Remove the _Dispatcher_.         |


## Grid

| Method   | Resource            | Parameters | Description                                        |
|----------|---------------------|------------|----------------------------------------------------|
| `GET`    | `/grid`             |            | Get _Grid_ info.                                   |
| `GET`    | `/grid/:dispatcher` |            | Get info of _Grid_ member by URL.                  |
| `DELETE` | `/grid/:dispatcher` |            | Unplug _Dispatcher_ from the _Grid_ by URL. |


## Scheduler

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
