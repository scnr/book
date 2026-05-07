# Generate reports

## Pro

You can export scan results in several formats from the "Export" tab of an aborted or completed revision scan.

## CLI

There are 2 reference report format types that you may encounter when using Spectre Scan:

1. `*.crf` -- Cuboid report file.
1. `*.ser` -- Spectre Scan report.

Both of these files can be handled by the CLI `spectre_reporter` utility in order
to convert them to a multitude of formats or print the results to `STDOUT`.

For example, to generate an HTML report:

`bin/spectre_reporter --report=html:outfile=my_report.html.zip /home/user/.spectre/reports/report.ser`

Or, to just print the report to STDOUT:

`bin/spectre_reporter --report=stdout /home/user/.spectre/reports/report.ser`

At the time of writing, `bin/spectre_reporter --reporters-list` yields:

```
 [~] Available reports:

 [*] ap:
--------------------
Name:           AP
Description:
Awesome prints a scan report hash.

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1.1
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/ap.rb

 [*] html:
--------------------
Name:           HTML
Description:
Exports the audit results as a compressed HTML report.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.html.zip
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.4.4
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/html.rb

 [*] json:
--------------------
Name:           JSON
Description:
Exports the audit results as a JSON (.json) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.json
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1.3
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/json.rb

 [*] markdown:
--------------------
Name:           Markdown
Description:
Exports the audit results as a Markdown (.md) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.md
 [~]    Required?:   false

 [~]    ai_friendly - Emit a flatter, compacter Markdown variant tuned for LLM ingestion (no TOC, blobs truncated, explicit section markers).
 [~]    Type:        bool
 [~]    Default:     false
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/markdown.rb

 [*] marshal:
--------------------
Name:           Marshal
Description:
Exports the audit results as a Marshal (.marshal) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.marshal
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.1.1
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/marshal.rb

 [*] pdf:
--------------------
Name:           PDF
Description:
Exports the audit results as a PDF (.pdf) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.pdf
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.5
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/pdf.rb

 [*] stdout:
--------------------
Name:           Stdout
Description:
Prints the results to standard output.

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.3.3
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/stdout.rb

 [*] txt:
--------------------
Name:           Text
Description:
Exports the audit results as a text (.txt) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.txt
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.2.1
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/txt.rb

 [*] xml:
--------------------
Name:           XML
Description:
Exports the audit results as an XML (.xml) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.xml
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.3.7
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/xml.rb

 [*] yaml:
--------------------
Name:           YAML
Description:
Exports the audit results as a YAML (.yaml) file.

Options:
 [~]    outfile - Where to save the report.
 [~]    Type:        string
 [~]    Default:     2026-05-07_13_45_31_+0300.yaml
 [~]    Required?:   false

Author:         Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
Version:        0.2
Path:   /home/zapotek/workspace/scnr/engine/components/reporters/yaml.rb
```
