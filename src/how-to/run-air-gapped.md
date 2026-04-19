# Run air-gapped

In order to run Codename SCNR in an air-gapped environment you need to:

* Place the license file at: `~/.scnr/license.key`
  * Either by copying it over from a previous activation on an Internet-enabled machine, or;
  * by [activating on-line](https://license.ecsypno.com/scnr).
* Run an instance of `bin/scnr_check_server` in your local network -- Provides functionality needed for SSRF types of checks.
  * Set the `SCNR_CHECK_SERVER` environment variable to the check server URL -- ex. `http://10.1.1.1:9292`.
