
                                    mix help

Prints documentation for tasks, aliases, modules, and applications.

## Examples

Without an explicit argument, this task lists tasks/aliases:

    $ mix help                  - prints all aliases, tasks and their short descriptions
    $ mix help --search PATTERN - prints all tasks and aliases that contain PATTERN in the name
    $ mix help --names          - prints all task names and aliases (useful for autocompletion)
    $ mix help --aliases        - prints all aliases

You can access documentation for a given task/alias:

    $ mix help TASK/ALIAS       - prints full docs for the given task/alias

But also for modules, functions, and applications:

    $ mix help MODULE           - prints the definition for the given module
    $ mix help MODULE.FUN       - prints the definition for the given module+function
    $ mix help app:APP          - prints a summary of all public modules in application

## Colors

When possible, `mix help` is going to use coloring for formatting the help
information. The formatting can be customized by configuring the Mix
application either inside your project (in `config/config.exs`) or by using the
local config (in `~/.mix/config.exs`).

For example, to disable color, one may use the configuration:

    [mix: [colors: [enabled: false]]]

The available color options are:

  * `:enabled`         - shows ANSI formatting (defaults to
    `IO.ANSI.enabled?/0`)
  * `:doc_code`        - the attributes for code blocks (cyan, bright)
  * `:doc_inline_code` - inline code (cyan)
  * `:doc_headings`    - h1 and h2 (yellow, bright)
  * `:doc_title`       - the overall heading for the output (reverse,
    yellow, bright)
  * `:doc_bold`        - (bright)
  * `:doc_underline`   - (underline)

Location: /Users/rj/.asdf/installs/elixir/1.19.2-otp-28/lib/mix/ebin
