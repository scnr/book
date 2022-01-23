# Introduction

## Description

SCNR is a modular, distributed, high-performance 
[DAST](https://en.wikipedia.org/wiki/Dynamic_application_security_testing) web
application security scanner framework, capable of analyzing the behavior and
security of modern web applications and web APIs.

You can access SCNR via multiple interfaces, such as:

* [CLI](./interfaces/cli.md)
* Web -- Work in progress.
* [Ruby API](./interfaces/ruby-api/index.md)
* [RPC API]()
* [REST API](./interfaces/rest-api/index.md)

## DOM/Javascript

Even though SCNR is a black-box testing tool, this changes when is comes to the
DOM/JS environment of each page, as it then injects a custom environment to
monitor JS objects and APIs in order to trace execution and data flows and thus 
provide in-depth reports as to how a security issue was identified which also 
greatly assists in its remediation.

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

## Scriptability

Furthermore, scripted scans allow for the creation of basically tailor made
scans by moving decision making points and configuration to user-specified
methods and can extend to even creating a custom scanner for any web application
backed by the SCNR engine.

The API is tidy and simple and easily allows you to plug-in to key API[^dsel] scan points
in order to get the best results from any scan.

Scripts are written in Ruby and can thus be stored in your favorite CVS, this
enables you to work side-by-side with the web application development team and
have the right script revision alongside the respective web application revision.

## Distribution

Finally, its sophisticated distributed architecture[^cuboid] allows for simple
creation of self-healing, load-balanced (vertically and horizontally) scanner grids.
This basically allows the creation of private scanner clouds in either yours or
a Cloud provider's infrastructure.

## Conclusion

Thus, SCNR can in essence fit into any SDLC with great grace, ease and little care.

[^dsel]: API/script functionality is provided by [DSeL](https://github.com/qadron/DSeL).

[^cuboid]: Distributed functionality is provided by [Cuboid](https://github.com/qadron/cuboid).
