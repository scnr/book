# Scan

Encapsulates functionality that has to do with the scan.

```ruby
SCNR::Application::API.run do

    Scan {
        Options {}
        Scope {}
        Sesion {}
        
        # Called before each page audit.
        before :page do |page|
        end

        # Called on page audit.
        on :page do |page|
        end

        # Called after a page audit.
        after :page do |page|
        end
        
        # Perform the scan.
        run! do |report, statistics|
        end

        # Perform the scan.
        report, statistics = self.run
        
        # Get scan progress.
        progress = self.progress

        # Get scan progress updates for session :my_session (any user-provided session ID will do).
        progress = self.session_progress( :my_session )
        
        sitemap = self.sitemap

        status = self.status

        issues = self.issues

        statistics = self.statistics

        is_running  = self.running?
        is_scanning = self.scanning?

        # Pauses the scan.
        self.pause!
        # Resumes the scan.
        self.resume!
        # Aborts the scan.
        self.abort!
        # Suspends the scan.
        self.suspend!
        
        is_pausing    = self.pausing?
        is_paused     = self.paused?
        is_suspending = self.suspending?
        is_suspended  = self.suspended?
        
        # Restores a scan.
        self.restore!( snapshot_path )
        
        # Get a scan report.
        report = self.generate_report
    }

end
```

## Example

```ruby
SCNR::UI::CLI::Output.mute

api = SCNR::Application::API.new

api.scan.options.set url: 'http://testhtml5.vulnweb.com',
                     checks: %w(allowed_methods interesting_responses)

api.state.on :change do |state|
    puts "Status:"
    ap state.status
end

api.data.sitemap.on :new do |entry|
    puts "Sitemap entry:"
    ap entry
end
api.data.issues.on :new do |issue|
    puts "New issue:"
    ap issue
end

scan_thread = Thread.new { api.scan.run }

while scan_thread.alive?
    puts "Progress update:"
    ap api.scan.session_progress( :session )
    sleep 1
end

ap api.scan.generate_report
```

Assuming the above is saved as `html5.scanner.rb`:

```
bin/scnr_script html5.scanner.rb
```
