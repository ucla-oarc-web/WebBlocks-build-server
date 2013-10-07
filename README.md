# WebBlocks Build Server

**WebBlocks** is a toolkit for building full-featured, responsive sites. Beyond it's library of structural components, interface elements and Javascript libraries, it is also highly configurable, modular and extensible. To achieve this, it is built around a compiler that leverages Compass/SASS and other Ruby and Node.js tools. Unfortunately, this can prove alienating to some developers and designers. 

**WebBlocks Build Server** is a stand-alone application that provides a remote build service for WebBlocks. Through a web service API, one may submit jobs that define compiler configuration, SASS variable settings and SASS sources to be compiled down into WebBlocks. It is intended to be used with the Builder tool in the WebBlocks documentation, but its generic interface may be called in other ways as well. Additionally, it also provides a web interface for accessing completed builds.

[![Build Status](https://travis-ci.org/ucla/WebBlocks-build-server.png)](https://travis-ci.org/ucla/WebBlocks-build-server)

*For more information on WebBlocks, see the project's [repository](https://github.com/ucla/WebBlocks) and [documentation](http://ucla.github.io/WebBlocks).*

### License

WebBlocks is open-source software licensed under the BSD 3-clause license. The full text of the license may be found in the `LICENSE` file on [online in the GitHub repository](https://github.com/ucla/WebBlocks-build-server/blob/master/LICENSE).

### Credits

The WebBlocks Build Server is written and maintained by Eric Bollens @ebollens.

This server is a component of the [WebBlocks](https://github.com/ucla/WebBlocks) initiative, an open-source collaboration involving the University of California, the Mobile Web Framework community, and others.

This software is powered by a number of outstanding packages including [Ruby](http://www.ruby-lang.org), [RubyGems](http://rubygems.org), [Bundler](http://gembundler.com), [Node.js](http://nodejs.org), [npm](https://npmjs.org), [Rake](http://rake.rubyforge.org), [Rack](http://rack.github.io), [Thin](http://code.macournoyer.com/thin/), [Sinatra](http://www.sinatrarb.com), [Foreman](http://ddollar.github.io/foreman/), [Resque](https://github.com/resque/resque), [Redis](http://redis.io), [Ruby/Git](https://github.com/schacon/ruby-git), [Rubyzip](https://github.com/aussiegeek/rubyzip), [JSON-JRuby](http://json-jruby.rubyforge.org), [multi_json](https://github.com/intridea/multi_json) and [systemu](https://github.com/ahoward/systemu).

## Installation

### Setting up the Environment

Before installing the WebBlocks Build Server, one must first install:

* Ruby: http://www.ruby-lang.org
* RubyGems: http://rubygems.org
* Bundler: http://gembundler.com
* Node.js and npm: http://nodejs.org
* Git: http://git-scm.com
* Redis: http://redis.io

Note that Bundler may be installed as follows once RubyGems is installed:

```ruby
gem install bundler
```

Further note that Node.js and npm are not used directly by the build server, but they are requisites to run the WebBlocks compiler, hence their inclusion in this list.

### Installing the Server

First, clone (or download) the WebBlocks Build Server, such as:

```bash
git clone https://github.com/ucla/WebBlocks-build-server.git 
```

Next, from within the build server directly, invoke Bundler:

```bash
bundle install
```

Finally, you may want to modify `settings.yml` to use your own fork or reference, define resource limitations, cache expirations and directory structure:

```yaml
### PUBLIC SERVER SETTINGS

public_config:
  
  ### WEBBLOCKS SETTINGS
  
  # Repository from which WebBlocks will be retrieved.
  repository: https://github.com/ucla/WebBlocks.git
  
  # Reference to tag or commit ID in Git repository. Do NOT set this value to 
  # a branch name, or the build server may end up with stale builds in its 
  # cache.
  reference: v1.0.08
  
### PRIVATE SERVER SETTINGS

private_config:
    
  ### RESOURCE SETTINGS (when launched with rackup)
    
  # Number of child processes allowed in the fork mode. When the number of 
  # build jobs currently running excede this value, additional job requests 
  # will recieve a 503 Service Unavailable response until one or more of the 
  # current jobs complete.
  child_processes_limit: 3
  
  ### CLEANUP SETTINGS
  
  # Seconds between wake ups of the scheduler to handle tasks like workspace 
  # and build expiration cleanup.
  cleanup_frequency: 300
  
  # Seconds from build completion time until workspace will be expired from 
  # server. Set this value to -1 to never expire workspaces. Generally, this
  # value should be set to 0 to expire workspaces immediately.
  workspace_expiration: 0
  
  # Seconds from build completion time until build will be expired from server. 
  # Set this value to -1 to never expire builds, such as if the server is being 
  # used as a third-party provider for other site's CSS, JS and image assets.
  build_expiration: -1
  
  # Seconds before an incomplete workspace (such as one queued or hung) is 
  # expired. This should be longer than it takes the build server to run a 
  # successful build, as it will cause the submitted job to abort. Set this 
  # value to -1 to never expire incomplete workspaces. 
  workspace_incomplete_expiration: 7200
  
  ### DIRECTORY SETTINGS
  
  # Temporary directory used during build jobs.
  workspace_dir: workspace
  
  # Directory used to store completed build runs.
  build_dir: build
  
  ### ALLOWED OPERATIONS SETTINGS
  
  allow:
    
    # If false, throw 403 for GET builds/(:id) and GET builds/(:id)/metadata 
    # requests.
    builds_metadata: true
    
    # If false, throw 403 for GET builds/(:id)/raw/.. request.
    builds_raw: true
    
    # If false, throw 403 for GET builds/(:id)/zip request.
    builds_zip: true
    
    # If false, throw 403 for GET jobs/create and POST api/jobs requests.
    jobs_create: true
    
    # If false, throw 403 for GET api/jobs/(:id)/delete request.
    jobs_delete: true
    
    # If false, throw 403 for GET api/jobs/(:id) request.
    jobs_status: true
```

In most cases, the default values in `settings.yml` should be sufficient.

**WARNING** The value for `reference` should always refer to a tag name or commit ID. It should never refer to a branch. If it refers to  branch, stale builds may end up in the build cache. 

**WARNING** The value for `child_processes_limit` only applies when running in the `fork` concurrency mode (launched via `rackup`).

### Starting the Server

There are two primary ways to use the WebBlocks Build Server.

* `rackup` launches the build server in stand-alone mode
* `foreman` launches the build server with [Resque](https://github.com/resque/resque) and [Redis](http://redis.io)

The `rackup` launch is simpler, but the `foreman` launch includes a queue manager so that, when all resources are currently in use, rather than rejecting the build request, it will be queued until a resource becomes available.

#### Using `rackup` to Start the Server

To start the server with `rackup`, navigate to the root directory and type:

```bash
rackup config.ru
```

The `rackup` launch defaults to port 9292. To change the port that the server listens on, use the `-p` option:

```bash
rackup config.ru -p 80
```

Using `rackup` is the simplest method for launching the WebBlocks Build Server; however, it has a caveat that, if there are `child_processes_limit` builds currently in progress, the server will reject additional the request with a 503 Service Unavailable response until one of the current builds complete. This is because it does not include a queue manager (see *Using `foreman` to Start the Server* for an alternative that does not have this constraint).

Before launching the server, you may want to tune `child_processes_limit`. When the WebBlocks compiler is running, the associated process will use up to 100% CPU, so this value should likely exceed one less than the number of available cores. This value defaults to 3, but it can be modified in `settings.yml`.

#### Using `foreman` to Start the Server

In most production scenarios, rather than rejecting a request when all resources are in use, it may be better to queue the request. Launching WebBlocks with `foreman` achieves this by launching the WebBlocks Build Server in conjunction with [Resque](https://github.com/resque/resque) and [Redis](http://redis.io). Under this scheme, rather than rejecting requests when all build resources are in use, they will be queued for later processing when a worker becomes available.

To start the server with `foreman`, navigate to the root directory and type:

```bash
foreman start
```

The `rackup` launch defaults to port 5000. To change the port that the server listens on, use the `-p` option:

```bash
foreman start -p 80
```

This launch method does *not* use `child_processes_limit` to determine the number of workers; instead, this value is set in `.foreman` under the `concurrency` option. As with `child_processes_limit`, it is likely that the number of workers launched with `foreman` should not exceed one less than the number of available cores. In addition to specifying the number of workers in `.foreman`, it may also be set during launch:

```bash
foreman start -p 80 -c worker=3,web=1,redis=1
```

**WARNING** The values of `web=1` and `redis=1` should not need to be modified, and they must be included.

### First Run

On first run of the WebBlocks Web Server, the server will:

* Set up `build/:reference`
* Set up `workspace/:reference`
* Check out `repository` into `workspace/:reference/_WebBlocks`
* Initialize and update the Git submodules for `workspace/:reference/_WebBlocks`
* Run the Bundler install for `workspace/:reference/_WebBlocks`

This process may take a bit of time, but future starts of the build server will proceed far more swiftly, except when the `reference` value is changed in `settings.yml`, when this process will again occur in full.

Startup completion is denoted in stdout by:

```none
>> Build server is ready
```

### Testing

The WebBlocks Build Server includes a suite of unit tests to ensure that the application is functioning properly. Any change made to the WebBlocks Build Server must pass all unit tests, and any new functionality added to the WebBlocks Build Server must include tests.

The full unit test suite may be invoked via `rake test`.

Temporary data generated by the unit tests may be removed via `rake test:clean`.

Partial tests are also available:

* `rake test:app:routes` tests all external interfaces

## Usage

### POST /api/jobs to initiate a job

Generally, builds are invoked by way of a POST request to `/api/jobs`. This POST request may include the following parameters:

* `rakefile-config` - Multi-level JSON object of WebBlocks compiler settings
* `src-sass-variables` - Single-level JSON object of WebBlocks SASS variables
* `src-sass-blocks` - SASS/CSS to be compiled into the `blocks.css` file
* `src-sass-blocks-ie` - SASS/CSS to be compiled into the `blocks-ie.css` file 

For testing and experimentation purposes, a GET request to `/jobs/create` will respond with a form that may be used to enter this data; however, in production cases, the POST to `/api/jobs` should usually come from a Javascript routine, as the response will be a JSON object that notes the current status of the job.

### Response from /api/jobs

When a POST is made to `/api/jobs`, the server will reply with a JSON-encoded response that includes, at minimum, the following fields:

* `id` - A unique identifier for the parameters specified for the build
* `status` - A code of either `running`, `completed` or `failed`.
* `build` - The JSON-encoded set of properties passed to the server.
* `server` - The public configuration details for the build.

Usually, unless the request is replaying an earlier request with the same post data, the `status` of this response will be `running`; however, if a build with identical post data to the initiating request has already been performed, it may also return `complete` or `failed` immediately. Details on processing these latter statuses may be found in *GET /api/jobs/:id to query job status*.

##### Status `running`

The `running` status means that, asynchronous to the web server response, a WebBlocks compile process has been initiated based on the data posted to `/api/jobs`.

*Why not respond with the completed build?* Running on average hardware, the WebBlocks compile process takes between 10 and 30 seconds depending on build configuration settings. If the build server is limited in cycles and memory, it may take even longer. Because timeouts on web requests are often set in the range of 2 to 10 seconds, it is thus not viable to perform the build synchronously to the web server thread.

### GET /api/jobs/:id to query job status

Using the `id` field in the response from the POST request to `/api/jobs`, a client may query a job's status via a GET request to `/api/jobs/:id`; alternatively, the client may also simply replay the POST request to `/api/jobs`, but the GET request preferred due to its lesser complexity.

##### Status `running`

If the build job is still running, a GET request to `/api/jobs/:id` will return with the same response as provided for the initial POST request to `/api/jobs`. Usually, a client is polling `/api/jobs/:id` waiting for a change in the status field, but the rest of these properties may be useful to a client regarding the properties of the job.

Once a build is complete, the status field will change to `failed` or `complete`. At this point, the client should stop polling `/api/jobs/:id` as the build is now in its final state.

##### Status `failed`

The `failed` status indicates that the server was unable to compile a build based on the properties of the initiating POST request to `/api/jobs`.  a `failed` response will also include an `error` property

In addition to the keys in a `running` response, a `failed` response will also include an `error` property that is itself a JSON-encoded object with: `message` describing the step in the process when the build failed, `output` including all standard output from the step that failed, and `error` including all standard error from the step that failed. These details may be useful for debugging purposes.

##### Status `complete`

The `complete` status indicates that the server was able to compile a build based on the initiating POST request to `/api/jobs`. It implies that the build is now ready to be downloaded and/or viewed.

In addition to the keys in a `running` response, a `complete` response will include an additional `url` property that is a JSON-encoded object with: `download`, specifying a URL where a zip of the build may be found, and `browse`, specifying a URL where the build details and the static files themselves may be viewed.

### GET /builds/:id to view job details

When a job is in the `complete` state, its `id` may be used to access a human-readable interface that provides a download link to a zip file, a set of links to a web-accessible copy of the build products and metadata about the build itself.

The data presented on this page is all available via a GET request to `/api/jobs/:id`, and some clients may completely forego ever presenting an end user with this page, but there may be cases where the page is useful.

NOTE: This will throw a 403 Forbidden error if `allow['builds_metadata']` in `settings.yml` is false.

### GET /builds/:id/zip to download build

When a job is in the `complete` state, it's `id`, plus the additional route segment `/zip`, may be used to initiate the download of a compressed version of the assets built by the job. This is the final build product that most end users will seek when initiating a job on the build server.

The `download` parameter within the `url` property of `/api/jobs/:id` is a link to this location; however, a client may also generate this link by inference from the `id` of the build.

NOTE: This will throw a 403 Forbidden error if `allow['builds_zip']` in `settings.yml` is false.

### GET /builds/:id/raw/* to access static build files

When a job is in the `complete` state, in addition to providing a zip for download, the build server also exposes the final build products as relatively pathed under the additional route segment `/raw`. For example, to access the blocks.css file, one could simply reference `/builds/:id/raw/css/blocks.css`.

While some end users will want to download a zip file and deploy the assets within their own web root, in other cases it may be sufficient to simply reference the raw version of the file directly from the server.

NOTE: This will throw a 403 Forbidden error if `allow['builds_raw']` in `settings.yml` is false.

## Service API

### GET /api/config

Returns a JSON structure containing all variables set in the `public` section of `settings.yml`.

##### Success Response: 200 OK

```json
{"repository":"https://github.com/ucla/WebBlocks.git","reference":"v1.0.08"}
```

### POST /api/jobs

Request initiates a build job, based on post data fields, and returns a JSON structure containing details about the current state of the job.

Accepts the following post data fields:

* `rakefile-config` - Multi-level hash of WebBlocks compiler config settings
* `src-sass-variables` - Key-value pairs of WebBlocks SASS variables
* `src-sass-blocks` - SASS/CSS to be compiled into the `blocks.css` file
* `src-sass-blocks-ie` - SASS/CSS to be compiled into the `blocks-ie.css` file 

In all cases, this call responds with a JSON-encoded object containing the properties:

* `status` - Current state of the job, including `running`, `complete` or `failed`
* `id` - Unique id for the parameters that initiated the job
* `build` - JSON-encoded object of post data that initiated the request
* `server` - JSON-encoded object of the public server config when the request was initiated

If the status is `complete`, the response will additionally include:

* `url` - JSON-encoded object including:
 * `download` - a URL where a zip of the build can be retrieved
 * `browse` - a URL where build details and raw files may be accessed

If the status is `failed`, the response will additionally include:

* `error` - A JSON-encoded object including:
 * `messages` - A human-readable description of the build step that failed
 * `output` - Standard output from the build step that failed
 * `error` - Standard error from the build step that failed

##### Request

`rakefile-config` post data field:

```json
{"build":{"packages":[":jquery",":modernizr",":respond",":selectivizr",":efx"],"debug":false},"src":{"adapter":["bootstrap"],"modules":["Base","Compatibility","Entity","Extend/Base"]},"package":{"bootstrap":{"scripts":[]}}}
```

`src-sass-variables` post data field:

```json
{"color-body-background":"#111","color-body-background-text":"#eee"}
```

`src-sass-blocks` post data field:

```none
.my-hidden-class {
    @include -base-visibility-hide;
}
```

`src-sass-blocks-ie` post data field:

```none
.not-ie {
    display: none;
}
```

##### Success Responses: 200 OK

See the *GET /api/jobs/:id - Example Response: 200 OK with `running` status* section.

##### Error Response: 403 Forbidden

If `allow['jobs_create']` in `settings.yml` is false, this will always be thrown:

```none
Jobs delete support not available.
```

##### Error Response: 503 Service Unavailable

If the server is running with in the `fork` concurrency mode and the number of current jobs is already at the limit set by `child_processes_limit`:

```none
The server is currently busy processing other jobs. Please try again later.
```

A client should wait for some period of time and may then resubmit the build request.

### GET /api/jobs/:id

This call responds with a JSON-encoded object minimally containing the properties:

* `status` - Current state of the job, including `running`, `complete` or `failed`
* `id` - Unique id for the parameters that initiated the job
* `build` - JSON-encoded object of post data that initiated the request
* `server` - JSON-encoded object of the public server config when the request was initiated

If the status is `complete`, the response will additionally include:

* `url` - JSON-encoded object including:
 * `download` - a URL where a zip of the build can be retrieved
 * `browse` - a URL where build details and raw files may be accessed

If the status is `failed`, the response will additionally include:

* `error` - A JSON-encoded object including:
 * `messages` - A human-readable description of the build step that failed
 * `output` - Standard output from the build step that failed
 * `error` - Standard error from the build step that failed

##### Success Response: 200 OK (example with `running` status)

```json
{"status":"running","id":"c668b6b22bd09a171560e33c766ea36c","build":{"rakefile-config":"{\"build\":{\"packages\":[\":jquery\",\":modernizr\",\":respond\",\":selectivizr\",\":efx\"],\"debug\":false},\"src\":{\"adapter\":[\"bootstrap\"],\"modules\":[\"Base\",\"Compatibility\",\"Entity\",\"Extend/Base\"]},\"package\":{\"bootstrap\":{\"scripts\":[]}}}","src-sass-variables":"{\"color-body-background\":\"#111\",\"color-body-background-text\":\"#eee\"}","src-sass-blocks":".my-hidden-class {\r\n    @include -base-visibility-hide;\r\n}","src-sass-blocks-ie":".not-ie {\r\n    display: none;\r\n}"},"server":{"repository":"https://github.com/ucla/WebBlocks.git","reference":"v1.0.08"}}
```

##### Success Response: 200 OK (example with `complete` status)

```json
{"status":"complete","id":"c668b6b22bd09a171560e33c766ea36c","url":{"download":"http://localhost:9292/builds/c668b6b22bd09a171560e33c766ea36c/zip","browse":"http://localhost:9292/builds/c668b6b22bd09a171560e33c766ea36c"},"build":{"rakefile-config":"{\"build\":{\"packages\":[\":jquery\",\":modernizr\",\":respond\",\":selectivizr\",\":efx\"],\"debug\":false},\"src\":{\"adapter\":[\"bootstrap\"],\"modules\":[\"Base\",\"Compatibility\",\"Entity\",\"Extend/Base\"]},\"package\":{\"bootstrap\":{\"scripts\":[]}}}","src-sass-variables":"{\"color-body-background\":\"#111\",\"color-body-background-text\":\"#eee\"}","src-sass-blocks":".my-hidden-class {\r\n    @include -base-visibility-hide;\r\n}","src-sass-blocks-ie":".not-ie {\r\n    display: none;\r\n}"},"server":{"repository":"https://github.com/ucla/WebBlocks.git","reference":"v1.0.08"}}
```

##### Success Response: 200 OK (example with `failed` status)

```json
{"status":"failed","id":"5e5b96b11f1ab55f32adea07ef0cab13","error":{"message":"Build failed","output":"[Dispatcher] Executing task: before_init\n[Dispatcher] Executing task: init\n[Dispatcher] Executing task: after_init\n[Dispatcher] Executing task: before_preprocess\n[Dispatcher] Executing task: preprocess\n[Dispatcher] Executing task: after_preprocess\n[Dispatcher] Executing task: before_link\n[Dispatcher] Executing task: link\n[Dispatcher] Executing task: after_link\n[Dispatcher] Executing task: before_compile\n[Dispatcher] Executing task: compile\n","error":"rake aborted!\nCompass compile error: \ndirectory css/compiled/ \n   create css/compiled/blocks-ie.css \n    error blocks.scss (Line 2: Undefined mixin '-does-not-exist'.)\n\nSass::SyntaxError on line [\"2\"] of workspace/v1.0.08/5e5b96b11f1ab55f32adea07ef0cab13/src/sass/blocks.scss: Undefined mixin '-does-not-exist'.\nRun with --trace to see the full backtrace\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:58:in `failure'\nworkspace/v1.0.08/_WebBlocks/lib/Build/WebBlocks.rb:142:in `block (2 levels) in compile_css'\nworkspace/v1.0.08/_WebBlocks/lib/Build/WebBlocks.rb:134:in `chdir'\nworkspace/v1.0.08/_WebBlocks/lib/Build/WebBlocks.rb:134:in `block in compile_css'\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:50:in `block in task'\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:97:in `scope'\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:49:in `task'\nworkspace/v1.0.08/_WebBlocks/lib/Build/WebBlocks.rb:129:in `compile_css'\nworkspace/v1.0.08/_WebBlocks/lib/Build/WebBlocks.rb:123:in `compile'\nworkspace/v1.0.08/_WebBlocks/lib/Build/Dispatcher.rb:44:in `block (3 levels) in execute'\nworkspace/v1.0.08/_WebBlocks/lib/Build/Dispatcher.rb:42:in `each'\nworkspace/v1.0.08/_WebBlocks/lib/Build/Dispatcher.rb:42:in `block (2 levels) in execute'\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:44:in `block in system'\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:97:in `scope'\nworkspace/v1.0.08/_WebBlocks/lib/Logger.rb:43:in `system'\nworkspace/v1.0.08/_WebBlocks/lib/Build/Dispatcher.rb:39:in `block in execute'\nworkspace/v1.0.08/_WebBlocks/lib/Build/Dispatcher.rb:38:in `each'\nworkspace/v1.0.08/_WebBlocks/lib/Build/Dispatcher.rb:38:in `execute'\nworkspace/v1.0.08/_WebBlocks/lib/Rake/Task/build.rb:13:in `block in <top (required)>'\n/Users/ebollens/.rvm/gems/ruby-1.9.3-p392/bin/ruby_noexec_wrapper:14:in `eval'\n/Users/ebollens/.rvm/gems/ruby-1.9.3-p392/bin/ruby_noexec_wrapper:14:in `<main>'\nTasks: TOP => default => build\n(See full trace by running task with --trace)\n"},"build":{"rakefile-config":"{\"build\":{\"packages\":[\":jquery\",\":modernizr\",\":respond\",\":selectivizr\",\":efx\"],\"debug\":false},\"src\":{\"adapter\":[\"bootstrap\"],\"modules\":[\"Base\",\"Compatibility\",\"Entity\",\"Extend/Base\"]},\"package\":{\"bootstrap\":{\"scripts\":[]}}}","src-sass-variables":"{\"color-body-background\":\"#111\",\"color-body-background-text\":\"#eee\"}","src-sass-blocks":".my-hidden-class {\r\n    @include -does-not-exist;\r\n}","src-sass-blocks-ie":".not-ie {\r\n    display: none;\r\n}"},"server":{"repository":"https://github.com/ucla/WebBlocks.git","reference":"v1.0.08"}}
```

##### Error Response: 403 Forbidden

If `allow['jobs_status']` in `settings.yml` is false, this will always be thrown:

```none
Jobs status support not available.
```

### GET /api/jobs/:id/delete

##### Success Response: 200 OK

```json
{"status":"deleted","id":"c668b6b22bd09a171560e33c766ea36c","url":{"download":"http://localhost:9292/builds/c668b6b22bd09a171560e33c766ea36c/zip","browse":"http://localhost:9292/builds/c668b6b22bd09a171560e33c766ea36c"},"build":{"rakefile-config":"{\"build\":{\"packages\":[\":jquery\",\":modernizr\",\":respond\",\":selectivizr\",\":efx\"],\"debug\":false},\"src\":{\"adapter\":[\"bootstrap\"],\"modules\":[\"Base\",\"Compatibility\",\"Entity\",\"Extend/Base\"]},\"package\":{\"bootstrap\":{\"scripts\":[]}}}","src-sass-variables":"{\"color-body-background\":\"#111\",\"color-body-background-text\":\"#eee\"}","src-sass-blocks":".my-hidden-class {\r\n    @include -base-visibility-hide;\r\n}","src-sass-blocks-ie":".not-ie {\r\n    display: none;\r\n}"},"server":{"repository":"https://github.com/ucla/WebBlocks.git","reference":"v1.0.08"}}
```

##### Error Response: 403 Forbidden

If `allow['jobs_delete']` in `settings.yml` is false, this will always be thrown:

```none
Jobs delete support not available.
```

##### Error Response: 404 Not Found

If a build does not exist:

```none
Cannot delete. Build #c668b6b22bd09a171560e33c766ea36c does not exist.
```

This may be the result of a replay, and a 404 may be interpreted by a client as a successful deletion.

##### Error Response: 409 Conflict

If a build is currently in progress:

```none
Cannot delete. Build #c668b6b22bd09a171560e33c766ea36c is currently in progress.
```

This is the result of trying to delete a build that is still in the `running` status.
