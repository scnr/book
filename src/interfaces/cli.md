# CLI

Command-line interface executables can be found under the `bin/` directory and
at the time of writing are:

1. `scnr` -- Direct scanning utility.
1. `scnr_console` -- A [REPL](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop) Ruby console running from the context of `SCNR::Engine`.
1. `scnr_spawn` -- Issues `disptch` calls to _Agents_ to start scans remotely.
1. `scnr_agent` -- Starts a _Agent_ daemon.
1. `scnr_agent_monitor` -- Monitors a _Agent_.
1. `scnr_agent_unplug` -- Unplugs a _Agent_ from its _Grid_.
1. `scnr_instance_connect` -- Utility to connect to an _Instance_.
1. `scnr_reporter` -- Generates reports from `.crf` (Cuboid report file) and `.ser` (SCNR Engine report) report files.
1. `scnr_reproduce` -- Reproduces an issue(s) from a given report.
1. `scnr_rest_server` -- Starts a REST server daemon.
1. `scnr_restore` -- Restores a suspended scan based on a snapshot file.
1. `scnr_scheduler` -- Starts a _Scheduler_ daemon.
1. `scnr_scheduler_attach` -- Attaches a detached _Instance_ to the given _Scheduler_.
1. `scnr_scheduler_clear` -- Clears the _Scheduler_ queue.
1. `scnr_scheduler_detach` -- Detaches an _Instance_ from the _Scheduler_.
1. `scnr_scheduler_get` -- Retrieves information for a scheduled scan.
1. `scnr_scheduler_list` -- Lists information about all scans under the _Scheduler_'s control.
1. `scnr_scheduler_push` -- Scheduled a scan.
1. `scnr_scheduler_remove` -- Removes a scheduled scan from the queue.
1. `scnr_script` -- Runs a Ruby script under the context of `SCNR::Engine`.
1. `scnr_shell` -- Starts a Bash shell under the package environment.
1. `scnr_system_info` -- Presents system information about the host.
