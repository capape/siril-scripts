#!/bin/bash

imageToResolve="${1}"
processed_folder="${2}"
   
filename=$(basename "${imageToResolve}")
rootfilename=$(echo "${filename%.*}")

cp "${imageToResolve}" /tmp
echo "Resolving ${filename}"
solve-field --overwrite "/tmp/${filename}" 2>/dev/null | tail -3

mv "/tmp/${rootfilename}-ngc.png" "${processed_folder}"
rm /tmp/"${rootfilename}"*    
