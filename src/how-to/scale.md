# Scale

SCNR can be configured into a _Grid_, in order to combine the resources of multiple
nodes and thus perform large amounts of scans simultaneously or complete individual 
scans faster.

Its _Grid_ can distribute workload horizontally and vertically and can also easily
scale up and/or down.

In essence, _Grids_ are created by connecting multiple _Agents_ together, at which
point a mesh network of _Agents_ is formed.
Doing so require no configuration, other than specifying an already running _Agent_
when booting up a new one.

This allows for creating a private Cloud of scanners, with minimal configuration,
that can handle an indefinite amount of workload.

Prior to continuing, it would be best if took a look at SCNR's [distributed architecture](/deployment/distributed/index.md).

## Strategies

Scaling strategies can be configured via the `--strategy` option of _Agents_, 
like so:

```bash
bin/scnr_agent --strategy=horizonstal
```

```bash
bin/scnr_agent --strategy=vertical
```

### Horizontal (default)

SCNR _Instances_ will be provided by the least burdened _Agent_, i.e. the
_Agent_ with the least utilization of its _slots_.

This strategy helps to keep the overall _Grid_ health good by spreading the
workload across as many nodes as possible.

### Vertical

SCNR _Instances_ will be provided by the most burdened _Agent_, i.e. the
_Agent_ with the most utilization of its _slots_.

This strategy helps to keep the overall _Grid_ size (and thus cost) low by
utilizing as few _Grid_ nodes as possible.

It will also let you know if you have over-provisioned as extra nodes will not
be receiving any workload.

## Creating a Grid

In one terminal run:

```bash
bin/scnr_agent
```

This is the initial _Agent_.

### Scaling up

To scale up just boot more _Agents_ and specify a peer.

So, in another terminal run:

```bash
bin/scnr_agent --port=7332 --peer=127.0.0.1:7331
```

Lastly, in yet another terminal run:

```bash
bin/scnr_agent --port=7333 --peer=127.0.0.1:7332
```

(It doesn't matter who the peer is as long as it's part of the Grid.)

Now we have a _Grid_ of 3 _Agents_.

The point of course is to run each _Agent_ on a different machine in real life,
but this will do for now.


### Scaling down

You can scale down by _unplugging_ an _Agent_ from its _Grid_ using:

```bash
bin/scnr_agent_unplug 127.0.0.1:7332
```

## Running Grid scans

To start a scan that will be load-balanced across the _Grid_, simply issue
a `spawn` request on any of the _Grid_ members.

Like so:

```bash
bin/scnr_spawn --agent-url=127.0.0.1:7331 http://testhtml5.vulnweb.com
```

The above will run a scan with the default options against
[http://testhtml5.vulnweb.com](http://testhtml5.vulnweb.com), originating from
whichever node is optimal at any given time.

If the _Grid_ is out of _slots_ you will see the following message:

```
[~] Agent is at maximum utilization, please try again later.
```

In which case you can keep retrying until a _slot_ opens up.

### Running multi-Instance scans

The above is useful when you have multiple scans to run and you want to run them
at the same time; another cool feature of SCNR though is that it can parallelize
individual scans across the _Grid_ thus resulting in huge single-scan performance gains.

For example, this would be useful if you were to scan a site with tens of thousands,
hundreds of thousands or even millions of pages.

Even better, doing so is as easy as:

```bash
bin/scnr_spawn --agent-url=127.0.0.1:7331 http://testhtml5.vulnweb.com --multi-instances=5
```

The `--multi-instances=5` option will instruct SCNR to use 5 _Instances_ to run this
particular scan, with the aforementioned _Instances_ being of course load-balanced
across the _Grid_.
