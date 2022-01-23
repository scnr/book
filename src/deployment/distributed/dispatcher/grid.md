# Grid

A _Grid_ is simply a group of _Dispatchers_ and its setup is as simple as specifying
an already running _Dispatcher_ as a _neighbour_ to a future _Dispatcher_.

The order in which you start or specify _neighbours_ is irrelevant, _Dispatchers_
will reach convergence on their own and keep track of their connectivity status 
with each other.

After a _Grid_ is configured, when a `dispatch` call is issued to any _Grid_
member it will be served by any of its _Dispatchers_ based on the desired
distribution strategy and not necessarily by the one receiving it.

## Strategies

### Horizontal (default)

`dispatch` calls will be served by the least burdened _Dispatcher_, i.e. the 
_Dispatcher_ with the least utilization of its _slots_.

This strategy helps to keep the overall _Grid_ health good by spreading the 
workload across as many nodes as possible.

### Vertical

`dispatch` calls will be served by the most burdened _Dispatcher_, i.e. the
_Dispatcher_ with the most utilization of its _slots_.

This strategy helps to keep the overall _Grid_ size (and thus cost) low by 
utilizing as few _Grid_ nodes as possible.

It will also let you know if you have over-provisioned as extra nodes will not
be receiving any workload.

## Examples

### Server

In one terminal run:

```bash
bin/scnr_dispatcher
```

In another terminal run:

```bash
bin/scnr_dispatcher --port=7332 --neighbour=127.0.0.1:7331
```

In another terminal run:

```bash
bin/scnr_dispatcher --port=7333 --neighbour=127.0.0.1:7332
```

(It doesn't matter who the neighbour is as long as it's part of the Grid.)

Now we have a _Grid_ of 3 _Dispatchers_.

The point of course is to run each _Dispatcher_ on a different machine in real life.

### Client

Same as [Dispatcher client](/scanning/distributed/dispatcher.md#client).
