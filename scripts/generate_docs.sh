#!/usr/bin/env bash

cp -R screenshots docs/
asciidoctor -b html5 -a linkcss! README.adoc
mv README.html docs/index.html