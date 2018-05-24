#!/bin/bash
cd $(dirname $0)
if [[ -e .texpath ]]; then
    source .texpath
fi
if [[ ! -x ./bin/perl ]]; then
    echo "You must symlink $PWD/bin/perl to the perl binary of your choice." >&2
    exit 1
fi
exec ./bin/perl app.psgi "$@"
