#!/bin/sh

copy_object() {

    
    object_name="${1}"
    path_to_search="${2}"
    target_path="${3}"


    find "${path_to_search}" -type f -name "*${object_name}*PROCESSED.fit" | sort | while read -r imageFile
    do
        
        filename=$(basename "${imageFile}")
        folder=$(dirname "${imageFile}")
        parent=$(dirname "${folder}")
        session_date=$(basename "${parent}")

        echo "Found ${filename} in ${session_date}"

        cp "${imageFile}" "${target_path}"/"${session_date}-${filename}"
    done
}

copy_object $1 $2 $3