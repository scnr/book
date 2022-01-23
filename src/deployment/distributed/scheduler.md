# Scheduler

To start a _Scheduler_ run the `scnr_scheduler` CLI executable.

To see all available options run:

```bash
bin/scnr_scheduler -h
```

The main role of the _Scheduler_ is to:

1. Queue scans based on their assigned priority.
2. Run them if there is an available _slot_.
3. Monitor their progress.
4. Grab and store reports once scans complete.

## Default

By default, scans will run on the same machine as the _Scheduler_.

## With Dispatcher

When a _Dispatcher_ has been provided, `dispatch` calls are going to be issued
in order to acquire _Instances_ to run the scans.

### Grid

In the case where the given _Dispatcher_ is a _Grid_ member, scans will be 
load-balanced across the _Grid_ according the the configured _strategy_.

## Examples

### Server

In one terminal run:

```bash
bin/scnr_scheduler
```

### Client

#### Pushing 

In another terminal run:

```bash
bin/scnr_scheduler_push --scheduler-url=localhost:7331 http://testhtml5.vulnweb.com
```

Then you should see something like:

```
 [~] Pushed scan with ID: 5fed6c50f3699bacb841cc468cc97094
```

#### Monitoring

To see what the _Scheduler_ is doing run:

```bash
bin/scnr_scheduler_list localhost:7331
```

Then you should see something like:

```
 [~] Queued [0]


 [*] Running [1]

[1] 5fed6c50f3699bacb841cc468cc97094: 127.0.0.1:3390/070116f5e2c0acaa0a6432acdcc7230a

 [+] Completed [0]


 [-] Failed [0]
```

If you run the same command after a while and the scan has completed:

```
 [~] Queued [0]


 [*] Running [0]


 [+] Completed [1]

[1] 5fed6c50f3699bacb841cc468cc97094: /home/username/.cuboid/reports/5fed6c50f3699bacb841cc468cc97094.crf

 [-] Failed [0]
```
