#!/bin/bash
    
fitsheader -k "${2}" "${1}" | tail -1 | grep "${2}" > /dev/null 
    
if [ $? -ne  0 ]
then
    echo ""    
else
    value=$(fitsheader -k "${2}" "${1}" | tail -1  | grep "${2}" | cut -f2 -d= | sed -s 's/ //g')
    echo "${value}"
fi