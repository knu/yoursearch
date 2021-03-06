# YourSearch -- Build OpenSearch plugins your way

This is a tiny web app to provide
[OpenSearch](http://www.opensearch.org/) plugins written in Ruby with
Sinatra.  You can run it on your local host to improve your browser
experience with search.

## List of Plugins

Currently the following plugins are implemented:

- Twitter

    Jump instantly to a specified user, search on Twitter, or search
    using Topsy.

- GitHub

    Jump instantly to a specified user or repository, or search for
    Users, Repositories, Code and Issues.

- RubyGems

    Suggest gems which name start with a given prefix.  This plugin
    builds a local database indexing the official gem list.  It seems
    the RubyGems API is too slow to serve as suggestion data source
    when Firefox has a hard limit of 0.500 seconds as response
    timeout.

    Run the following command periodically to keep your local database
    up-to-date:

        bin/runner Suggestions::Rubygems.fetch_index

- Wikipedia Universal

    Search across multiple Wikipedias in parallel.

## Configuration

Use `.env.example` as a template for creating your own `.env`.

## Author

Copyright (c) 2014 Akinori MUSHA.

Licensed under the 2-clause BSD license.  See `LICENSE.txt` for
details.

Visit [GitHub Repository](https://github.com/knu/yoursearch) for the
latest information and feedback.
