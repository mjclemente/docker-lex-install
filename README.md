# docker-lex-install
### A CommandBox Module for preloading Lucee extensions (.lex) into your CommandBox Docker deployments.

_This is an early stage project that was initially developed for internal use. Feel free to use the issue tracker to report bugs or suggest improvements._

## What it does
This module automatically loads all provided Lucee extension (.lex) files into the CommandBox server's `/lucee-server/deploy` folder when the server starts. It's intended to be used by [CommandBox deployments](https://hub.docker.com/r/ortussolutions/commandbox/) of Lucee on Docker, in order to make Lucee extensions available while warming up a server, so that they're ready to use when the container is deployed.

There are other approaches to this issue, including the use of the [`LUCEE_EXTENSIONS` environment variable](https://labs.daemon.com.au/t/installing-the-memcached-extension-for-lucee-5-x/319), which you may find preferable, depending on your use case.

Using this module's approach to installing extensions can be particularly helpful when:
1. You want to install a specific version of an extension
2. You don't want to be reliant on HTTP calls to download the extensions from Lucee.org during your build.
3. You want to know exactly what extensions you're installing (instead of bothering with the extension GUIDs)
4. You're using a version of Lucee that doesn't support ENV extension installations.

## Using this module
This module doesn't just "work out of the box"; it it makes several assumptions about file/folder structure. Here's how to use it:

1. __It needs to be a dependency in your `box.json`__
  So, if you don't have a `box.json`, you'll need to add one. At it's most basic, it would look something like this:
    ```json
    {
      "name": "your-great-app",
      "version": "0.0.1",
      "dependencies":{
        "docker-lex-install" : "0.0.1"
      }
    }
    ```
    If you didn't want to depend on downloading and installing the package from [ForgeBox.io](https://www.forgebox.io/), you could load the folder into your container and replace `0.0.1` with the path to it.

2. __Extensions need to be in `/config/extensions`__
  The module runs `onServerStart()` and looks for `.lex` files the container's `/config/extensions`. Consequently, that's where you'll need to load the extensions that you want to use:
    ```
    └── config
        └── extensions
            ├── extension-loganalyzer-2.3.1.16.lex
            └── extension-memcached-3.0.2.29.lex
    ```
    Given this folder structure, your Dockerfile might include something along these lines:
    ```
    # Copy in our config file(s)
    # Our local /config folder should include /extensions
    COPY ./config/ /config/
    ```
    For what it's worth, I'm open to changing this convention if an alternative approach is preferable.
3. __`box install` needs to be run__
  Before warming up the server, you need to make sure the dependency is installed. You can do this in your Dockerfile:
    ```
    # Install our box.json dependencies. Needed to ensure the warmup runs the install process for the plugins
    WORKDIR $APP_DIR
    RUN box install
    ```
4. __The server needs to be warmed up__
  Warming up the server ensures that, among other things, Lucee has time to recognize and install the extensions. Again within the Dockerfile, you can use the script that comes with the CommandBox image to do this:
    ```
    # Warm up our server
    RUN ${BUILD_DIR}/util/warmup-server.sh
    ```


When set up correctly, this example would result in the CommandBox Lucee server starting with the Memcached and Log Analyzer extensions installed.

## Questions
For questions that aren't about bugs, feel free to hit me up on the [CFML Slack Channel](http://cfml-slack.herokuapp.com); I'm @mjclemente. You'll likely get a much faster response than creating an issue here.

## Contributing
:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

Before putting the work into creating a PR, I'd appreciate it if you opened an issue. That way we can discuss the best way to implement changes/features, before work is done.

Changes should be submitted as Pull Requests on the `develop` branch.