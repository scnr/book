# Run air-gapped

In order to run Spectre Scan in an air-gapped environment you need to:

* Place the encrypted license file as `license` inside `~/.spectre/` (or `$SPECTRE_HOME/` if you've overridden the home dir).
  * Either by copying it over from a previous activation on an Internet-enabled machine — copy `~/.spectre/license` (and, if present, the plaintext `~/.spectre/license.key` next to it), or;
  * by [activating on-line](https://license.ecsypno.com/spectre).
* Run an instance of `bin/spectre_check_server` in your local network -- Provides functionality needed for SSRF types of checks.
  * Set the `SPECTRE_CHECK_SERVER` environment variable to the check server URL -- ex. `http://10.1.1.1:9292`.
