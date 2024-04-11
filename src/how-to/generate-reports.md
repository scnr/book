# Generate reports

## Pro

You can export scan results in several formats from the "Export" tab of a successfully completed scan.

## CLI

There are 2 reference report format types that you may encounter when using SCNR:

1. `*.crf` -- Cuboid report file.
1. `*.ser` -- `SCNR::Engine` report.

Both of these files can be handled by the CLI `scnr_reporter` utility in order
to convert them to a multitude of formats or print the results to `STDOUT`.

For example, to generate an HTML report:

`bin/scnr_reporter --report=html:outfile=my_report.html.zip /home/user/.scnr/reports/report.ser`

Or, to just print the report to STDOUT:

`bin/scnr_reporter --report=stdout /home/user/.scnr/reports/report.ser`

At the time of writing, `bin/scnr_reporter --reporters-list` yields:

```
 [~] Available reports:

 [*] ap:
--------------------
Name:           AP
Description:
Awesome prints a scan report hash.

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1.1

 [*] html:
--------------------
Name:           HTML
Description:
Exports the audit results as a compressed HTML report.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2022-01-24 23_17_13 +0200.html.zip
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.4.4

 [*] json:
--------------------
Name:           JSON
Description:
Exports the audit results as a JSON (.json) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2022-01-24 23_17_13 +0200.json
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1.3

 [*] marshal:
--------------------
Name:           Marshal
Description:
Exports the audit results as a Marshal (.marshal) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2022-01-24 23_17_13 +0200.marshal
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1.1

 [*] stdout:
--------------------
Name:           Stdout
Description:
Prints the results to standard output.

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.3.3

 [*] txt:
--------------------
Name:           Text
Description:
Exports the audit results as a text (.txt) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2022-01-24 23_17_13 +0200.txt
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.2.1

 [*] xml:
--------------------
Name:           XML
Description:
Exports the audit results as an XML (.xml) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2022-01-24 23_17_13 +0200.xml
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.3.7

 [*] yaml:
--------------------
Name:           YAML
Description:
Exports the audit results as a YAML (.yaml) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2022-01-24 23_17_13 +0200.yaml
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.2
```
