#!/bin/bash


for i in `find . -type d -name "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" `; 
do  
    
    echo "cd ${i}"
    cd ${i}
    supernovas.sh . 60 processed_20230521; 
    cd -
    pwd
done

for image in `find . -name *jpg`; do 
    if [[ "${image}" == *"processed_20230521"* ]]
    then 
        echo "${image}"
        target="$(echo "${image}" | sed -e 's/\/processed_20230521.*//')"/processed
        mv ${image} ${target}
    fi; 
done
