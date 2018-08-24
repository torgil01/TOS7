#!/bin/bash

d0=$(find $1 -maxdepth 2 -mindepth 2 -type d)

sorted=/aa/bb/cc

for d in ${d0[@]}; do
    echo python dicomsort $d  ${sorted}
done
