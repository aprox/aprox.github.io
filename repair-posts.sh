#!/bin/bash

for f in ./jekyll/_posts/*; do sed -i '1,3d;8,9d' $f; done
