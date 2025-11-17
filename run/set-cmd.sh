#!/bin/sh
# set -e
# https://www.geeksforgeeks.org/linux-unix/shell-scripting-set-command/
# The Set -e command does not work with piped commands.
set -eo pipefail
set -x
set -u
# set
# set -o
# set +o

# test by: run/script/set-cmd a b 

set -- abc "$@"
echo "\$@=$@"

# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html