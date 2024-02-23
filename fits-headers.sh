#!/bin/bash
find . -name "*001.fit" -exec fitsheader -t ascii.csv -k DATE-LOC "{}" ";"  |  grep -v filename | awk  'BEGIN{ FS=",";}{print $4 $1;}' |sort