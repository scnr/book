# Dispatcher

To start a _Dispatcher_ run the `scnr_dispatcher` CLI executable.

To see all available options run:

```bash
bin/scnr_dispatcher -h
```

Each _Dispatcher_ should run on a different machine and its main role is to
provide _Instances_ to clients; each _Instance_ is a scanner process.

The _Dispatcher_ will also split the available resources of the machine on which
it runs into _slots_, with each _slot_ corresponding to enough space for one
_Instance_.

(To see how many slots a machine has you can use the `scnr_system_info` utility.)

# Example

## Server

In one terminal run:

```bash
bin/scnr_dispatcher
```

The default port at the time of writing is `7331`, so you should see something like:

```
I, [2022-01-23T09:54:21.849679 #1121060]  INFO -- System: RPC Server started.
I, [2022-01-23T09:54:21.849730 #1121060]  INFO -- System: Listening on 127.0.0.1:7331
```

## Client

To start a scan originating from that _Dispatcher_ you must issue a `dispatch`
call in order to obtain an _Instance_; this can be achieved using the `scnr_dispatch`
CLI executable.

In another terminal run:

```bash
bin/scnr_dispatch --dispatcher-url=127.0.0.1:7331 http://testhtml5.vulnweb.com
```

The above will run a scan with the default options against
[http://testhtml5.vulnweb.com](http://testhtml5.vulnweb.com), originating from
the _Dispatcher_ node.

The `scnr_dispatch` utility largely accepts the same options as `scnr`.

If a the _Dispatcher_ is out of _slots_ you will see the following message:

```
[~] Dispatcher is at maximum utilization, please try again later.
```

In which case you can keep retrying until a _slot_ opens up.
