# Scan services

At the moment the are no specialized service crawlers, however auditing web
services is possible by first training the system via its `proxy` plugin.

## Training

### Initial

The best way to perform the initial training of the system is by running your
service test-suite and having its HTTP requests go through the proxy plugin.

#### Proxy plugin setup

You can setup the proxy like so:

    bin/scnr http://target-url --scope-page-limit=0 --checks=*,-passive/* --plugin=proxy --audit-jsons --audit-xmls

The default proxy URL will be: `http://localhost:8282`

The `--scope-page-limit=0` option tells the system to not do any sort of crawl 
and only use what has been made visible via the proxy.

The `--checks` option tells the system to load all but irrelevant checks for
service scans -- common files and directories and the like don't really apply in this case.

The `--audit-jsons --audit-xmls` options restrict the scan to only JSON and XML inputs.

#### Test-suite setup

Test-suite configurations vary, however you can usually export the proxy setting
as an environmental variable, prior to running your test-suite, like so:

```bash
export http_proxy=http://localhost:8282
```

If this global setting is ignored, you will need to explicitly configure your test-suite.

#### Exporting the input vectors

After running the test-suite, the system will have been trained with the input
vectors of the web service.
Thus, it would be a good idea to export that data, in order to avoid having to
run the training scenarios prior to each scan.

The data can be retrieved with:

```bash
http_proxy=http://localhost:8282 curl http://scnr.engine.proxy/panel/vectors.yml -o vectors.yml
```

#### Starting the scan

In order for the scan to start you will need to shutdown the proxy:

```bash
http_proxy=http://localhost:8282 curl http://scnr.engine.proxy/shutdown
```

### Re-using input vector data

Data exported via the proxy plugin can be imported via the `vector_feed` plugin, like so:

    bin/scnr http://target-url --scope-page-limit=0 --checks=*,-passive/* --plugin=vector_feed:yaml_file=vectors.yml

Thus, you only have to run your test-suite scenarios once, for the initial training
and then reuse the exported vector data for subsequent scans.

## Debugging

You can debug the proxy manually via simple `curl` commands, like so:

```bash
http_proxy=http://localhost:8282 curl -H "Content-Type: application/json" -X POST -d '{ "input": "value" }' http://target-url/my-resource
```

Then, in SCNR's terminal you'll see something like:

```
[*] Proxy: Requesting http://target-url/my-resource
[~] Proxy:  *  0 forms
[~] Proxy:  *  0 links
[~] Proxy:  *  0 cookies
[~] Proxy:  *  1 JSON
[~] Proxy:  *  0 XML
```

If you require further information, you can enable the `--output-debug` option;
acceptable verbosity values range from `1` to `3`, `1` being the default.
