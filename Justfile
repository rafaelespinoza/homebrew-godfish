#!/usr/bin/env -S just -f

GO := "go"
MAIN := justfile_directory() / "bin" / "make-formulae-templates"

# List available recipes
@default:
    {{ justfile() }} --list --unsorted

# compile executable for generating formula files
[group("templates")]
buildbin:
  mkdir -pv {{ parent_directory(MAIN) }}
  {{ GO }} -C generator build -o {{ MAIN }} .

alias b := buildbin

# execute compiled binary for generating formula files
[group("templates")]
runbin *args:
  {{ MAIN }} {{ args }}

alias r := runbin

# clean up go dependencies
[group("templates")]
modtidy:
  {{ GO }} -C generator mod tidy

[group("brew")]
testinstall driver *args:
  #!/bin/sh
  driver='{{ clean(driver) }}'
  if [ "${driver}" = 'all' ]; then
    brew install --build-from-source {{ args }} rafaelespinoza/godfish/godfish
  else
    brew install --build-from-source {{ args }} "rafaelespinoza/godfish/godfish_${driver}"
  fi
