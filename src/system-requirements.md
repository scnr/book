# System requirements

| Operating System | Architecture | RAM | Disk | CPU         | 
|------------------|--------------|-----|------|-------------|
| Linux            | x86 64bit    | 4GB | 4GB  | Multicore   |

## Trial packages

The resource (mainly RAM) consumption on locked trial packages is not indicative
of the final resource usage.

Due to 3rd party software restrictions for package encryption these packages use
an older version of Ruby (2.7.5 vs 3.1.0) leading to high RAM usage.

For example, based on on a real-life scenario, where real RAM usage would 
approximately be 900MB, trial packages may require 3.5GB.

We're currently working with the 3rd party to resolve the situation.

However, should you require an unlocked package to better understand your 
provisioning needs please [contact us](mailto:tasos.laskos@gmail.com).

## Resource constrained environments

To optimize the resources a scan may use please consult:

* [Optimize scans](./how-to/optimize-scans.md)

In addition, _Agents_ and other servers can have their max-slots adjusted 
to a user-specified value, instead of the default, which is `auto` and based
on the aforementioned system requirements.

Please issue the `-h` flag to see available options for each executable in order
to examine the applicable overrides.
