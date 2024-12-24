# System requirements

| Operating System | Architecture | RAM | Disk | CPU         | 
|------------------|--------------|-----|------|-------------|
| Linux            | x86 64bit    | 2GB | 4GB  | Multicore   |

## Resource constrained environments

To optimize the resources a scan may use please consult:

* [Optimize scans](./how-to/optimize-scans.md)

In addition, _Agents_ and other servers can have their max-slots adjusted 
to a user-specified value, instead of the default, which is `auto` and based
on the aforementioned system requirements.

Please issue the `-h` flag to see available options for each executable in order
to examine the applicable overrides.
