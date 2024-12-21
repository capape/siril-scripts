#!/bin/bash

orig="${1}"
dest="$(basename "${orig%.*}")-web.jpg"

dateImage="${2}"
place="${3}"


date="text 25,25 '${dateImage}'"
convert  -gravity northwest -font Courier-10-Pitch-Bold -pointsize 24  -fill white -draw "${date}" "${orig}" "${dest}" 

location="text 25,50 'Antonio Capapé'; text 25,25 '${place}'"
convert  -gravity southwest -font Courier-10-Pitch-Bold-Italic -pointsize 18  -fill white -draw "${location}" "${dest}" "${dest}" 

