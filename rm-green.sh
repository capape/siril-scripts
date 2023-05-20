#!/bin/sh

echo "requires 0.99.8 "  > rmgreen.ssf
find . -name "${1}" |  while read -r image
do
    {
        
        echo "load ${image}"
        echo "rmgreen 0"
        echo "save ${image}"
    } >> rmgreen.ssf
done

siril -s rmgreen.ssf