#!/usr/bin/env bash

echo "Formatting gdscript with gdformat"
gdformat .
echo "Linting gdlint with gdlint"
gdlint .
echo "Formatting Markdown with prettier"
prettier --write .
echo "Linting Markdown with markdownlint-cli2"
markdownlint-cli2 ./**/*.md
