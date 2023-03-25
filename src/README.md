# Introduction

## Description

SCNR is a modular, distributed, high-performance 
[DAST](https://en.wikipedia.org/wiki/Dynamic_application_security_testing) web
application security scanner framework, capable of analyzing the behavior and
security of modern web applications and web APIs.

You can access SCNR via multiple interfaces, such as:

* [CLI](./interfaces/cli.md)
* [Ruby API](./interfaces/ruby-api/index.md)
* [Web UI (Pro)](./interfaces/web/index.md)
* [REST API (Enterprise)](./interfaces/rest-api/index.md)

## Back-end support

A wide range of back-end technologies is supported, including:

1. Operating systems
   1. BSD
   2. Linux
   3. Unix
   4. Windows
   5. Solaris
2. Databases
   1. SQL
      1. MySQL
      2. PostreSQL
      3. MSSQL
      4. Oracle
      5. SQLite
      6. Ingres
      7. EMC
      8. DB2
      9. Interbase
      10. Informix
      11. Firebird
      12. MaxDB
      13. Sybase
      14. Frontbase
      15. HSQLDB
      16. Access
   2. NoSQL
      1. MongoDB
3. Web servers
   1. Apache
   2. IIS
   3. Nginx
   4. Tomcat
   5. Jetty
   6. Gunicorn
4. Programming languages
   1. PHP
   2. ASP
   3. ASPX
   4. Java
   5. Python
   6. Ruby
   7. Javascript
5. Frameworks
   1. Rack
   2. CakePHP
   3. Rails
   4. Django
   5. ASP.NET MVC
   6. JSF
   7. CherryPy
   8. Nette
   9. Symfony
   10. NodeJS
   11. Express

This list keeps growing but new platforms or failure to fingerprint supported 
ones don't disable the SCNR framework, they merely force it to be more extensive in its scan.

Upon successful identification or configuration of platform types, the scan will 
be much more focused, less resource intensive and require less time to complete.

## Front-end support

HTML5, modern Javascript APIs and modern DOM APIs are supported by basing their
execution and analysis on Chrome (via chromedriver -- default) or Firefox (via geckodriver).

By using those modern and cutting edge browsers you can count on modern and cutting
edge continued support.

Furthermore, even though SCNR is a black-box testing tool, this changes when is 
comes to the DOM/JS environment of each page, as it will injects a custom environment
to monitor JS objects and APIs in order to trace execution and data flows and thus 
provide highly in-depth reporting as to how a client-side security issue was 
identified which also greatly assists in its remediation.

## Machine learning/behavioral analysis

SCNR will study the web application/service to identify how each input interacts
with the front and back ends and tailor the audit for each specific input's characteristics.

This results in highly self-optimized scans using less resources and requiring
less time to complete, as well as less server stress.

Training also continues during the audit process and new inputs that may appear
during that time will be incorporated into the scan in whole.

## Extendability

Its modular architecture allows for easy augmentation when it comes to security checks,
arbitrary custom functionality in the form of plugins and bespoke reporting.

Entities which perform tasks crucial to the operation of a web scanner have
been abstracted to be components, more to be easily added by anyone in order to
extend functionality.

Components are split into the following types:

* Checks -- Security checks.
  * Active -- They actively engage the web application via its inputs.
  * Passive -- They passively look for objects.
* Plugins -- Add arbitrary functionality to the system, accept options and run in parallel to the scan.
* Reporters -- They export the scan results in several formats.
* Path extractors -- They extract paths for the crawler to follow.
* Fingerprinters -- They identify OS version, platforms, servers, etc.

## Customization

Furthermore, scripted scans allow for the creation of basically tailor made
scans by moving decision making points and configuration to user-specified
methods and can extend to even creating a custom scanner for any web application
backed by the SCNR engine.

The API is tidy and simple and easily allows you to plug-in to key API[^dsel] scan points
in order to get the best results from any scan.

Scripts are written in Ruby and can thus be stored in your favorite CVS, this
enables you to work side-by-side with the web application development team and
have the right script revision alongside the respective web application revision.

## Scalability

No dependencies, no configuration; SCNR can build a cloud of itself that allows
you to scale both horizontally and vertically.

Scale up by plugging more nodes to its _Grid_, or down by unplugging them.

Furthermore, with multi-_Instance_ scans you can not only distribute multiple 
scans across nodes, but also individual scans, for super fast scanning of large sites.

Finally, with its quick suspend-to-disk/restore feature, running scans can easily be moved from node
to node, accommodating highly optimized load-balancing and cost saving policies.

## Deployment

Deployment options range from command-line utilities for direct scans, 
scripted scans (for configuration and custom scanners) as well as distributed 
deployments to perform scans from remote hosts and Grid/cloud/SaaS setups.

Its simple distributed architecture[^cuboid] allows for easy creation of self-healing,
load-balanced (vertically and horizontally) scanner grids; basically allowing for
the creation of private scanner clouds in either yours or a Cloud provider's infrastructure.

## Conclusion

Thus, SCNR can in essence fit into any SDLC with great grace, ease and little care.

[^dsel]: API/script functionality is provided by [DSeL](https://github.com/qadron/DSeL).

[^cuboid]: Distributed functionality is provided by [Cuboid](https://github.com/qadron/cuboid).
