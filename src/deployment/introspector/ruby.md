# Ruby -- Rack, Ruby on Rails, etc.

## Installation

```
gem install scnr-introspector
```

## Use

```ruby
require 'scnr/introspector'

use SCNR::Introspector, scope: {
  path_start_with: File.dirname( __FILE__ ),
  path_end_with:   '.rb',

  path_include_patterns: /new-features/,
  path_exclude_patterns: /old-features/
}
```
