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

### Architecture

The application was initially built with the standard MVC architecture, but once
we released and we continue to add changes to the application, the controller
has become a dumping ground for lots of logic that is not well tested and hard
to reuse / debug / maintain.

To remedy the situation, various architectures have been considered including
MVP, MVVM, and lastly VIPER (https://www.objc.io/issues/13-architecture/viper/).
Ultimately, the goals of the architecture are:

1. Increase testability without dependencies to UI
2. Create a shared understanding within the team about how to structure a module
   so that when changes are needed, developer knows where to look
3. Increase reusability of components
4. Prevent class explosions and allow the use of out-of-box UIKit classes

Based on experimentation, it seems that VIPER was the best choice, except that
the naming of the architecture just does not vibe with me.  In place of the
Interactor, we chose the term Service, which is already an element inside the
app.  Purpose, however, is the same.  To manage the business logic around use
cases without references to UIKit.  The Presenter, which is not the same as the
Presenter in MVP, essentially manages the views and works with the Service to
enable the interaction for each module.  The Controller, lastly, is responsible
for setting up the presenter, services, view and then managing the navigation
between the controllers.
