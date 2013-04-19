#!/usr/bin/env bash

function eb_template {
  perl -p -e 's/\{(\w+)\}/defined $ENV{$1} ? $ENV{$1} : $&/eg' $1
}
