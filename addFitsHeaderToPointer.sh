#!/bin/bash

imageInfoForAnnotation() {

    newfile="${1}"

    filter=$(echo "${newfile}" |  cut -f2 -d_)
    object=$(echo "${newfile}" |  cut -f3 -d_)
    dateImg=$(fitsheader "${newfile}" -k DATE-OBS | tail -1 | cut -f2 -d=|sed -e "s/\/.*//" | sed -e "s/'//g")
    comment="text 10,25 '${object} - Filter: ${filter} - Date: ${dateImg}'; text 10,10 '© Grup Supernoves l\'Astronòmica de Sabadell (AAS)'"
    echo ${comment}
}

#find . -name "GLX*fit"  | while read -r newfile; 
#do  
#    comment=$(imageInfoForAnnotation "${newfile}")
#    filejpg=$(echo "${newfile}" | sed -e "s/fit/-ca-gaia.jpg/")
#    echo "adding ${comment} to ${filejpg}"
#    convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${filejpg}" "${filejpg}" 
#done


find . -name  "ST*PROCESSED.fit" | while read -r newfile
do
 
 comment=$(imageInfoForAnnotation "${newfile}")

 filejpg=$(echo "${newfile}" | sed -e "s/fit/jpg/")
 #filejpg=$(echo "${newfile}" | sed -e "s/\.fit/-pointer.jpg/")
 #filejpg=$(echo "${newfile}" | sed -e "s/\.fit/-ngc.png/")

 echo "Adding to  ${filejpg}"
 convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${filejpg}" "${filejpg}" 

 # echo "Adding to  ${filepng}"
 # convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${filepng}" "${filepng}" 
done