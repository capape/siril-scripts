#!/bin/bash

imageInfoForAnnotation() {

    newfile="${1}"

    filter=$(echo "${newfile}" |  cut -f2 -d_)
    object=$(echo "${newfile}" |  cut -f3 -d_)
    dateImg=$(fitsheader "${newfile}" -k DATE-OBS | tail -1 | cut -f2 -d=|sed -e "s/\/.*//" | sed -e "s/'//g")
    comment="text 10,25 '${object} - Filter: ${filter} - Date: ${dateImg}'; text 10,10 '© Grup Supernoves l\'Astronòmica de Sabadell (AAS)'"
    echo ${comment}
}

fitsImage="${1}"
imageToAnotate="${2}"
 
comment=$(imageInfoForAnnotation "${fitsImage}")

echo "Adding to  ${imageToAnotate}"
convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${imageToAnotate}" "${imageToAnotate}" 
