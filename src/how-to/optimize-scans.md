# Optimize scans

Left to its own devices, Codename SCNR will try to optimize itself to match any given
circumstance, but there are limitations to what it can do automatically.

If a scan is taking too long, chances are that there are ways to make it go much 
faster by taking a couple of minutes to configure the system to closer match your needs.

In addition to performance, the following options also affect resource usage so
you can experiment with them to better match your available resources as well.

1. [Only enable security checks that concern you](#only-enable-security-checks-that-concern-you)
2. [Tailor the audit process to the platforms of the web application](#tailor-the-audit-process-to-the-platforms-of-the-web-application)
3. [Ensure server responsiveness](#ensure-server-responsiveness)
4. [Balance RAM consumption and performance](#balance-ram-consumption-and-performance)
5. [Reduce RAM consumption by avoiding large resources](#reduce-ram-consumption-by-avoiding-large-resources)
6. [Don't follow redundant pages](#dont-follow-redundant-pages)
7. [Adjust the amount of browser workers](#adjust-the-amount-of-browser-workers)
8. [Pick the audit mode that suits you best](#pick-the-audit-mode-that-suits-you-best)

## Only enable security checks that concern you

By default, SCNR will load **all** checks, which may not be what you want.

If you are interested in high severity vulnerabilities or don't care for things
like discovery of common files and directories, and the like, you should disable
the superfluous checks.


You can enable only `active` checks with:

    --checks=active/* 

Or skip the inefficient `passive` ones with:

    --checks=*,-common_*,-backup_*,-backdoors

## Tailor the audit process to the platforms of the web application

By default, the system will fingerprint the web application in order to deduce
what platforms power it, thus enabling it to only send applicable payloads
(instead of everything) which results in less server stress and bandwidth usage.

However, it is a good idea to explicitly set the platforms, if you know them,
so as to play it safe and get the best possible results -- especially since 
database platforms can't be fingerprinted prior to the audit and their payloads
are a large part of the overall scan.

You can specify platforms with:

    --platforms=linux,mysql,php,apache

## Ensure server responsiveness

By default, SCNR will monitor the response times of the server and throttle
itself down if it detects that the server is getting stressed. 
This happens in order to keep the server alive and responsive and maintain a
stable connection to it.

However, there are times with weak servers when they die before SCNR gets a
chance to adjust itself.

You can bring up the scan statistics on the CLI screen by hitting `Enter`, in
which case you'll see something like:

```
 [~] Currently auditing          http://testhtml5.vulnweb.com/ajax/popular?offset=0                                 
 [~] Burst response time sum     6.861 seconds                                                                      
 [~] Burst response count        29                                                                                 
 [~] Burst average response time 1.759 seconds                                                                      
 [~] Burst average               0 requests/second                                                              
 [~] Original max concurrency    10                                                                                 
 [~] Throttled max concurrency   2                                                                                                                                             
```

We can see that the server is having a hard time from the following values:

* Burst average: 3 requests/second
* Burst average response time  1.759
* Burst average: 0 requests/second
* Throttled max concurrency: 2

The response times were so high (1.75 seconds) that SCNR had to throttle its
HTTP request concurrency from 10 requests to 2 requests, which would result in a
drastically increased scan time.

You can lower the default HTTP concurrency and try again to make sure that the
server at no point gets a stressful load:

    --http-request-concurrency=5

## Balance RAM consumption and performance

Most excessive RAM consumption issues are caused by large (or a lot of) HTTP requests,
which need to be temporarily stored in memory in order for them to later be scheduled
in a way that achieves optimal network concurrency.

To cut this short, having a lot of HTTP requests in the queue allows SCNR to
be better at performing a lot of them at the same time, and thus makes better 
use of your available bandwidth. So, a large queue means better network performance.

However, a large queue can lead to some serious RAM consumption, depending on 
the website and type of audit and a lot of other factors.

As a compromise between preventing RAM consumption issues but still getting 
decent performance, the default queue size is set to `50`.
You can adjust this number to better suit your needs depending on the situation.

You can adjust the HTTP request queue size via the `--http-request-queue-size` option.

## Reduce RAM consumption by avoiding large resources

SCNR performs a large number of analysis operations on each web page.
This is usually not a problem, except for when dealing with web pages of large sizes.

If you are in a RAM constrained environment, you can configure SCNR to not 
download and analyze pages which exceed a certain size limit -- by default, that
limit is 500KB.

You can adjust the maximm allows size of HTTP response via the `--http-response-max-size` option.

## Don't follow redundant pages

A lot of websites have redundant pages like galleries, calendars, directory 
listings etc. which are basically the same page with the same inputs but just
presenting different data.

Auditing the first (or first few) of such pages is
often enough and trying to follow and audit them all can sometimes result in an
infinite crawl, as can be the case with calendars.

SCNR provides 2 features to help deal with that:

* Redundancy filters: Specify `pattern` and `counter` pairs, pages matching the
  `pattern` will be followed the amount of times specified by the `counter`.
  * `--scope-redundant-path-pattern`
* Auto-redundant: Follow URLs with the same combinations of query parameters a
  limited amount of times.
  * `--scope-auto-redundant` -- Default is `10`.

## Adjust the amount of browser workers

SCNR uses real browsers to support technologies such as HTML5, AJAX and DOM
manipulation and perform deep analysis of client-side code.

Even though browser operations are performed in parallel using a pool of workers,
the default pool size is modest and operations can be time consuming.

By increasing the amount of workers in the pool, scan durations can be dramatically shortened,
especially when scanning web applications that make heavy use of client-side technologies.

Finding the optimal pool size depends on the resources of your machine (especially 
the amount of CPU cores) and will probably require some experimentation; on average,
1-2 browsers for each logical CPU core serves as a good starting point.

However, do keep in mind that more workers may lead to higher RAM consumption as
they will also accelerate workload generation. 

You can set this option via `--dom-pool-size`.
The default is calculated based on the amount of available CPU cores your system has.

## Pick the audit mode that suits you best

This is a _Time_ vs _Thoroughness_ balancing option.

`--audit-mode`:

* `quick` -- For a quick scan, complex or rare payloads will be omitted.
* `moderate` (default) -- Balanced payloads.
* `super` -- All payloads, more DOM probing, disabled attack optimization heuristics.
