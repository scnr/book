# Grid

A _Grid_ is simply a group of _Agents_ and its setup is as simple as specifying
an already running _Agent_ as a _peer_ to a future _Agent_.

The order in which you start or specify _peers_ is irrelevant, _Agents_
will reach convergence on their own and keep track of their connectivity status 
with each other.

After a _Grid_ is configured, when a `spawn` call is issued to any _Grid_
member it will be served by any of its _Agents_ based on the desired
distribution strategy and not necessarily by the one receiving it.

## Strategies

### Horizontal (default)

`spawn` calls will be served by the least burdened _Agent_, i.e. the 
_Agent_ with the least utilization of its _slots_.

This strategy helps to keep the overall _Grid_ health good by spreading the 
workload across as many nodes as possible.

### Vertical

`spawn` calls will be served by the most burdened _Agent_, i.e. the
_Agent_ with the most utilization of its _slots_.

This strategy helps to keep the overall _Grid_ size (and thus cost) low by 
utilizing as few _Grid_ nodes as possible.

It will also let you know if you have over-provisioned as extra nodes will not
be receiving any workload.

## Examples

### Server

In one terminal run:

```bash
bin/scnr_agent
```

In another terminal run:

```bash
bin/scnr_agent --port=7332 --peer=127.0.0.1:7331
```

In another terminal run:

```bash
bin/scnr_agent --port=7333 --peer=127.0.0.1:7332
```

(It doesn't matter who the peer is as long as it's part of the Grid.)

Now we have a _Grid_ of 3 _Agents_.

The point of course is to run each _Agent_ on a different machine in real life.

### Client

Same as [Agent client](/scanning/distributed/agent.md#client).
