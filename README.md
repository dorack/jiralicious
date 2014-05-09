# jiralicious

[![Build Status](https://travis-ci.org/jstewart/jiralicious.png)](https://travis-ci.org/jstewart/jiralicious)

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

Session configuration is also available via YAML:

    jira:
      username: youruser
      password: yourpass
      uri: https://example.com/


    Jiralicious.load_yml(File.expand_path("/path/to/jira.yml"))

Search for issues:

    result = Jiralicious.search("key = HSP-1") # Any jql can be used here
    result.issues

Finding a single issue:

    issue = Jiralicious::Issue.find("HSP-1")
    issue.key => "HSP-1"


## Deprecation Warning

Default auth type is now Basic auth. Cookie auth will be deprecated in the next version.

## Changes in 0.4.2

* Opened up HTTParty to any version.
* Issue.new now works if provided a hash set.
* Error is thrown if the Jira key is invalid.
* Error is thrown if issue cannot be created during new opperation.

## Changes from 0.4.0 to 0.4.1

* Initial implementation of OAuth.
** Note: the system does not support webhooks at this time. **

## Changes from 0.3.0

* User and Avatars are now supported.

## Changes from 0.2.2

* For more flexible error handling, Return the full HTTParty response instead of parsing errorMessages. **NOTE: This API change may break exising error handling code. Please update your application code to parse the response from JiraError, TransitionError, and IssueNotFound.**


## Changes from 0.1.0

* Issues can be created, updated, or deleted as needed. This includes most components such as comments, transitions, and assignees.
* Projects can now be accessed as well as related issues
* A Field class has been added to allow proper access to the meta data for create, edit, and update requests. This data is searchable via Hash or dot notation
* Some sections can now be lazy loaded
* Configuration can be loaded via yaml


## Contributors

* Stanley Handschuh (dorack)
* Mike Fiedler (miketheman)
* Girish Sonawane (girishso)
* Jan Lindblom (janlindblom)

## Contributing to jiralicious

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2013 Jason Stewart. See LICENSE for
further details.
