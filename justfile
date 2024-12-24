# https://github.com/casey/just
# https://github.com/casey/just/blob/master/examples/cross-platform.just
# https://just.systems/man/en/
# just -l # list all recipes by:
# just --help
# just --choose

# Running just with no arguments runs the first recipe in the justfile
# first recipe is the default recipe, this line also acts as RECIPE desc
default:
  @just --list --unsorted --justfile {{justfile()}} # --list-heading $'Customized header line\n' --list-prefix "..."
version:
  just --version
ls-vars:
  just --evaluate

# just prints each command to standard error before running it, which is why echo 'This is a recipe!' was printed.
hi:
	echo hi justfile

# show recipe definition
show recipe:
  just --show {{recipe}}
