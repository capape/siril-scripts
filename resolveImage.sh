#!/bin/bash

imageToResolve="${1}"

if  [ $# -lt  2 ] 
then 
    processed_folder="."
else
    processed_folder="${2}"
fi
   
filename=$(basename "${imageToResolve}")
rootfilename=$(echo "${filename%.*}")

cp "${imageToResolve}" /tmp
echo "Resolving ${filename}"
solve-field --overwrite "/tmp/${filename}" 2>/dev/null | tail -3

mv "/tmp/${rootfilename}-ngc.png" "${processed_folder}"
rm /tmp/"${rootfilename}"*    
