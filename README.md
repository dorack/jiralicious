# jiralicious

## Examples:

Before doing anything, you must configure your session:

    Jiralicious.configure do |config|
      # Leave out username and password
      config.username = "youruser"
      config.password = "yourpass"
      config.uri = "http://example.com/foo/bar"
      config.api_version = "latest"
      config.auth_type = :basic
    end

Default auth type is now Basic auth. Cookie auth is still available with the
following option:

    config.auth_type = :cookie

Search for issues:

    result = Jiralicious.search("key = HSP-1") # Any jql can be used here
    result.issues

Finding a single issue:

    issue = Jiralicious::Issue.find("HSP-1")
    issue.key => "HSP-1"

## Contributing to jiralicious

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Jason Stewart. See LICENSE for
further details.
