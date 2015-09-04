# Sense iOS App [![Circle CI](https://circleci.com/gh/hello/suripu-ios/tree/develop.svg?style=svg&circle-token=976651c2b892bd2d9c8265e2efc060fa1904dbc5)](https://circleci.com/gh/hello/suripu-ios/tree/develop)

## Development

### Gettings started

Run `make bootstrap` to install development tools, and ensure Xcode
development tools are installed via `xcode-select --install`

* [Activity/Bug Tracker](https://trello.com/b/5zO3TPUz/sense-ios)

* [Continuous Integration](https://circleci.com/gh/hello/suripu-ios)

### Branching

We are using [git flow](http://nvie.com/posts/a-successful-git-branching-model/).

All new code is added to branches forked from the `develop` branch, which is where everyday action happens. When releases are immiment, develop is merged into `master` and tagged with the latest version.

### Code Style

We are using a modified version of [WebKit style](http://www.webkit.org/coding/coding-style.html), detailed in the [style specification file](https://github.com/hello/suripu-ios/blob/develop/.clang-format). Notable differences are "attach" (same line) style for braces, a space in pointers, and allowing inlining of short statements. Explanation for the options in the specification file can be found [here](http://clang.llvm.org/docs/ClangFormatStyleOptions.html#configurable-format-style-options).

### Deployment 

We are using [deliver](https://github.com/KrauseFx/deliver#quick-start)
for build deployment. `deliver init` will configure your credentials.

To upload to iTunes Connect, run `make deploy`.
