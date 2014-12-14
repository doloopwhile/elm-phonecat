#!/bin/bash
rm -rf ghp
mkdir ghp

cp -R static_files ghp
for d in step-*; do
  cp -R $d ghp
done

pandoc -f markdown_github -t html < README.md > ghp/index.html

for d in ghp/step-*; do
  pushd $d > /dev/null
    rake build
    rake clean
  popd > /dev/null
done
