#!/bin/bash 
###############################################################################
#
# Shell functions to process data from supernovas images.
#
###############################################################################
flat_base_name="FFF"
dark_base_name="CDO"
galaxy_base_name="GLX"
supernova_base_name="GSN"
nebulae_base_name="NP"
nebulae2_base_name="NEB"
globular_cluster_base_name="CG"
quasar_base_name="QUASAR"

siril_script="sn_siril.ssf"

fix_fff_images=1
fix_cdo_images=1
fix_light_images=1

info() {

    echo "Process files obtained in supernova group."

}

copy_master_files() {
    if [[ ! -d "${1}/master_files" ]]; then
        mkdir -p "${1}/master_files" 
    fi

    find . -name "*stack*" -exec cp "{}" "${1}/master_files" ";"
}

delete_tmp_files() {
   
    find . -name "r_pp*" -exec rm "{}" ";"
    find . -name "pp*" -exec rm "{}" ";"
    find . -name "*seq" -exec rm "{}" ";"
}

normalize_file_name() {
    echo "$1" | sed -s 's/_\([0-9]\+\)[s|S]_/_\1S_/' | sed -s 's/ /___/g'
}


copy_light_files_to_image_folder () {

    local img_src_folder="${1}"
    local source_file="${2}"
    local destination="${3}"
    local exposition="${4}"

    find "${img_src_folder}"  -maxdepth 1 -iname "${source_file}*${exposition}S*.fit" -type f -exec basename "{}" ";" | while read -r light_file
    do
      normalized=$(normalize_file_name "${light_file}")
      echo "Copying ${img_src_folder}/${light_file} to ${destination}/${normalized}"
      cp "${img_src_folder}/${light_file}" "${destination}"/"${normalized}"

      if [ ${fix_light_images} -eq 1 ] 
        then
            remove_bscale  "${destination}"/"${normalized}"
            remove_bzero  "${destination}"/"${normalized}"
      fi
    done


}

###############################################################################
# $1: exposition in seconds
# $2: darks folder
# $3: tmp dir where to save stacked frame
# $4: stack_name
###############################################################################
generate_dark_frame() {

    exposition=${1}
    dark_src_folder=${2}
    tmp_dir=${3}
    dark_exposition_base_name="${dark_base_name}_${exposition}S_"
    stack_name=${4}

    echo "############################################################"
    echo "# generating ${dark_exposition_base_name} frames"
    echo "exposition...................: ${exposition}"
    echo "dark_src_folder..............: ${dark_src_folder}"
    echo "tmp_dir......................: ${tmp_dir}"
    echo "dark_exposition_base_name....: ${dark_exposition_base_name}"
    echo "stack_name...................: ${stack_name}"

    ndarks=$(find "${dark_src_folder}" -maxdepth 1 -iname "${dark_exposition_base_name}*" -type f | wc -l )
    echo "Found ${ndarks} darks"
    if [ "${ndarks}" != "0" ]
    then

        echo "############################################################" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "# generating dark frames" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "requires 1.2.0" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "set16bits" >>  "${siril_tmp_dir}"/"${siril_script}"

        find "${dark_src_folder}" -maxdepth 1   -iname "${dark_exposition_base_name}*" -type f -exec basename "{}" ";" | while read -r source_file
        do
            destination="${siril_tmp_dir}"/"${tmp_dir}"
            normalized=$(normalize_file_name "${source_file}")
            echo "Copying ${dark_src_folder}/${source_file} to ${destination}/${normalized}"
            cp "${dark_src_folder}/${source_file}" "${destination}"/"${normalized}"

            if [ ${fix_cdo_images} -eq 1 ] 
            then
                remove_bscale  "${destination}"/"${normalized}"
                remove_bzero  "${destination}"/"${normalized}"
            fi
        done


        echo "cd $tmp_dir" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "stack ${dark_exposition_base_name} rej 3 3 -nonorm  ">> "${siril_tmp_dir}"/"${siril_script}"
        echo "cd .." >> "${siril_tmp_dir}"/"${siril_script}"
        echo "############################################################" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "" >> "${siril_tmp_dir}"/"${siril_script}"
    else
        echo ""
        echo ""
        echo ""
        echo "############################################################################"
        echo "WARN: There are not dark files. Not generatin stacked dark file"
        echo "############################################################################"
        echo ""
        echo ""
        echo ""
    fi

}


###############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: R,DS
# $4: tmp dir where to save stacked frame
# $5: stack_name
###############################################################################
generate_flat_frame() {


    exposition=${1}
    flat_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    flat_exposition_base_name="${flat_base_name}_${filter}_${exposition}S_"
    stack_dark_flat=${5}

    echo "############################################################"
    echo "# generating ${flat_base_name}_${filter} frames"
    
    echo "exposition...................: ${exposition}"
    echo "flat_src_folder..............: ${flat_src_folder}"
    echo "filter.......................: ${filter}"
    echo "tmp_dir......................: ${tmp_dir}"
    echo "flat_exposition_base_name....: ${flat_exposition_base_name}"
    echo "stack_dark_flat..............: ${stack_dark_flat}"

    nflats=$(find "${flat_src_folder}" -maxdepth 1 -iname "${flat_exposition_base_name}*" -type f | wc -l )
    echo "Found ${nflats} darks"
    if [ "${nflats}" != "0" ]
    then
        echo "############################################################" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "# generating flat frames" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "requires 1.2.0" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "set16bits" >>  "${siril_tmp_dir}"/"${siril_script}"

        find "${flat_src_folder}"  -maxdepth 1  -iname "${flat_exposition_base_name}*" -type f -exec basename "{}" ";" | while read -r source_file
        do
            destination="${siril_tmp_dir}"/"${tmp_dir}"
            normalized=$(normalize_file_name "${source_file}")
            echo "Copying flat ${flat_src_folder}/${source_file} to ${destination}/${normalized}"
            cp "${flat_src_folder}/${source_file}" "${destination}"/"${normalized}"

            if [ ${fix_fff_images} -eq 1 ] 
            then
                remove_bscale  "${destination}"/"${normalized}"
                remove_bzero  "${destination}"/"${normalized}"
            fi
        done


        echo "cd $tmp_dir" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "calibrate ${flat_exposition_base_name} -bias=../darkflats/${stack_dark_flat}" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "stack pp_${flat_exposition_base_name} rej 3 3 -nonorm " >> "${siril_tmp_dir}"/"${siril_script}"
        echo "cd .." >> "${siril_tmp_dir}"/"${siril_script}"
        echo "############################################################" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "" >> "${siril_tmp_dir}"/"${siril_script}"

    else
        echo ""
        echo ""
        echo ""
        echo "############################################################################"
        echo "WARN: There are not ${flat_exposition_base_name} files. Not generating flats"
        echo "############################################################################"
        echo ""
        echo ""
        echo ""
    fi
}




generating_object() {

    local exposition="${1}"
    local img_src_folder="${2}"
    local filter="${3}"
    local tmp_dir="${4}"
    local stack_flat="${5}"
    local stack_dark="${6}"
    local object_name="${7}"
    local process_folder="${8}"


    local normalized_object_name="${object_name}"
    local object_base_name="${normalized_object_name}_${filter}_${exposition}S_"

    echo "############################################################"
    echo "# generating ${normalized_object_name} frames"
    echo "exposition.......: ${exposition}"
    echo "img_src_folder...: ${img_src_folder}"
    echo "filter...........: ${filter}"
    echo "tmp_dir..........: ${tmp_dir}"
    echo "${object_name}_base_name....: ${object_base_name}"
    echo "stack_flat.......: ${stack_flat}"
    echo "stack_dark.......: ${stack_dark}"
    echo "process_folder...: ${process_folder}"
    echo "siril_tmp_dir...: ${siril_tmp_dir}"
    echo "Current folder...: $(pwd)"

   

    [ ! -d "${img_src_folder}" ] && echo "Error:  ${img_src_folder} does not exits" && return
  
    

    find "${img_src_folder}" -maxdepth 1  -iname "${object_name}_${filter}*_${exposition}S_001.fit" -type f -printf "%f\n" | sed -s "s/_${exposition}S_001.fit//i" | sort -u | while read -r real_source_file
    do
        {
        local source_file
        source_file=$(normalize_file_name "${real_source_file}")
        echo "${source_file} vs ${real_source_file}"
        local dest_filename="${source_file}_PROCESSED"
        local stack_name="${dest_filename}.fit"
        destination="${process_folder}/${tmp_dir}/${source_file}"
        mkdir "${destination}"

        object_script="${destination}"/"${siril_script}"

        copy_light_files_to_image_folder "${img_src_folder}" "${real_source_file}" "${destination}" "${exposition}"
        local nlights
        nlights=$(find "${destination}" -type f | wc -l )
        if [ "${nlights}" -lt 2 ]
        then
           echo "Not enough lights to stack"

        else

            echo "############################################################" >> "${object_script}"
            echo "# generating ${normalized_object_name} frames" >> "${object_script}"
            echo "requires 1.2.0" >> "${object_script}"
            echo "set16bits" >>  "${object_script}"

            echo "USANDO ${source_file}"

            echo "#############################" >> "${object_script}"
            echo "# generating ${normalized_object_name} ${source_file}" >> "${object_script}"
            echo "cd ${tmp_dir}" >> "${object_script}"


            echo "cd ${source_file}" >> "${object_script}"

            local sequence
            sequence="${source_file}_${exposition}S_"
            echo "calibrate ${sequence} -dark=../../darks/${stack_dark} -flat=../../flats/${stack_flat}  -cfa" >> "${object_script}"
            echo "register pp_${sequence}" >> "${object_script}"
            echo "stack r_pp_${sequence} rej 3 3 -norm=addscale -out=${stack_name}" >> "${object_script}"
            echo "load ${stack_name}" >> "${object_script}"
            echo "autostretch -linked -2.8 0.1" >> "${object_script}"
            #echo "asinh -human 100" >> "${object_script}"
            echo "savejpg ${dest_filename}"  >> "${object_script}"
            echo "cd .." >> "${object_script}"
            echo "cd .." >> "${object_script}"
            echo "" >> "${object_script}"
        fi
        }
    done

    echo "" >> "${process_folder}"/"${siril_script}"

}



set_default_values() {
    echo "setfindstar -sigma=0.4 -roundness=0.5" >> "${siril_tmp_dir}"/"${siril_script}"
}


remove_bzero() {
   
    
    bzero=$(readHeader "${1}" BZERO)    

    if [ "${bzero}" == "0.0" ] 
    then
        remove-header "${1}" BZERO
    fi
    
}

remove_bscale() {
 

    bscale=$(readHeader "${1}" BSCALE)

    if [ "${bscale}" == "1.0" ]
    then
        remove-header "${1}" BSCALE
    fi
    
}

readHeader() {

    
   fitsheader -k "${2}" "${1}" | tail -1 | grep "${2}" > /dev/null 
    
    if [ $? -ne  0 ]
    then
        echo ""    
    else
        value=$(fitsheader -k "${2}" "${1}" | tail -1  | grep "${2}" | cut -f2 -d= | sed -s 's/ //g')
        echo "${value}"
    fi
}

generate_objects_with_exp() {

    local img_src_folder="${1}"
    local exp="${2}"
    local flat_r="${3}"
    local flat_ds="${4}"
    local dark="${5}"
    local process_folder="${6}"


    echo "Generating galaxy supernova "
    generating_object "${exposition}" "${img_src_folder}" "R" "lights" "${flat_r}" "${dark}" "${supernova_base_name}" "${process_folder}"

    echo "Generating galaxy "
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "${galaxy_base_name}" "${process_folder}"

    echo "Generating nebulae "
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "${nebulae_base_name}" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "${nebulae2_base_name}" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "NPN" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "NBP" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "CUM+NEB" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "NEB+CUM" "${process_folder}"
    

    echo "Generating globular cluster "
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "${globular_cluster_base_name}" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "CO_NB" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "CO" "${process_folder}"
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "CMO" "${process_folder}"

    echo "Generating quasar "
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "${quasar_base_name}" "${process_folder}"

    echo "Generating planets "
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "NEPTU" "${process_folder}"

    echo "Generating COMETS "
    generating_object "${exposition}" "${img_src_folder}" "DS" "lights" "${flat_ds}" "${dark}" "COM" "${process_folder}"

    echo "Generating STARS "
    generating_object "${exposition}" "${img_src_folder}" "R" "lights" "${flat_ds}" "${dark}" "ST" "${process_folder}"


}

commentImage() {
 
 image="${1}"
 comment="${2}"
 convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${image}" "${image}" 

}

imageInfoForAnnotation() {

    newfile="${1}"

    filter=$(echo "${newfile}" |  cut -f2 -d_)
    object=$(echo "${newfile}" |  cut -f3 -d_)
    dateImg=$(fitsheader "${newfile}" -k DATE-OBS | tail -1 | cut -f2 -d=|sed -e "s/\/.*//" | sed -e "s/'//g")
    comment="text 10,25 '${object} - Filter: ${filter} - Date: ${dateImg}'; text 10,10 '© Grup Supernoves l\'Astronòmica de Sabadell (AAS)'"
    echo ${comment}
}

resolveImage() {

    imageToResolve="${1}"
    processed_folder="${2}"
    
    filename=$(basename "${imageToResolve}")
    rootfilename=$(echo "${filename%.*}")

    cp "${imageToResolve}" /tmp
    echo "Resolving ${filename}"
    solve-field --overwrite "/tmp/${filename}" 2>/dev/null | tail -3

    mv "/tmp/${rootfilename}-ngc.png" "${processed_folder}"
    rm /tmp/"${rootfilename}"*    
}


if  [ $# -lt  2 ] || [ $# -gt 3 ]
then
    echo "Usage: supernovas.sh img_folder exp [dest_folder]"
    echo "  img_folder: Image root folder"
    echo "  exp:  seconds of image exposure"
    echo "  dest_folder: Optional. Name of folder to place results"
    exit 0
fi

img_folder=${1}
[ ! -d "${img_folder}" ]  && echo "Image source folder ${img_folder} doest not exist" && exit 1


exp=60
if [[ -n ${2} ]]
then
    exp=${2}
fi
echo "Exposition ${exp}"


if [ -z "$3" ]
then
    processed_folder="processed"
else 
    processed_folder="${3}"
fi



siril_tmp_dir="./siril_process"


[ -d ${siril_tmp_dir} ] && echo "Processing folder ${siril_tmp_dir} already exists" && exit 1
[ -d ${siril_tmp_dir} ] && echo "Processing folder ${siril_tmp_dir} already exists" && exit 1

echo "Creating ${siril_tmp_dir} folder for processing"
mkdir ${siril_tmp_dir}


echo "############################################################" >  "${siril_tmp_dir}"/"${siril_script}"
echo "# Autogenerated siril process" >>  "${siril_tmp_dir}"/"${siril_script}"
echo "############################################################" >>  "${siril_tmp_dir}"/"${siril_script}"



echo "Creating ${siril_tmp_dir}/darkflats folder for processing"
mkdir "${siril_tmp_dir}"/darkflats

echo "Creating ${siril_tmp_dir}/flats folder for processing"
mkdir "${siril_tmp_dir}"/flats

echo "Creating ${siril_tmp_dir}/darks folder for processing"
mkdir "${siril_tmp_dir}"/darks

echo "Creating ${siril_tmp_dir}/lights folder for processing"
mkdir "${siril_tmp_dir}"/lights


echo "Generating dark flats "
generate_dark_frame 5 "${img_folder}" darkflats darkflat.fit
stack_dark_flat="${dark_base_name}_5S_stacked.fit"


echo "Generating R flats "
generate_flat_frame 5 "${img_folder}" R flats "${stack_dark_flat}"
stack_r_flat="pp_${flat_base_name}_R_5S_stacked.fit"

echo "Generating DS flats "
generate_flat_frame 5 "${img_folder}" DS flats "${stack_dark_flat}"
stack_ds_flat="pp_${flat_base_name}_DS_5S_stacked.fit"


echo "Generating darks "
generate_dark_frame "${exp}" "${img_folder}" darks darks
stack_dark="${dark_base_name}_${exp}S_stacked.fit"

echo "Adding config"
set_default_values

generate_objects_with_exp "${img_folder}" "${exp}" "${stack_r_flat}" "${stack_ds_flat}" "${stack_dark}" "${siril_tmp_dir}"

echo "Running siril "
cd "${siril_tmp_dir}"
siril -d . -s "${siril_script}" >process.log 2>/dev/null 

find lights -name "*ssf" | sort | while read -r script_object
do
  
    siril -d . -s "${script_object}"  > process.log 2>/dev/null
    if [ $? -eq 0 ]
    then 
        echo "Processing ${script_object} OK"
    else
        echo "Processing ${script_object} FAILED"
    fi
done


cp process.log /tmp/process.log
copy_master_files ..

delete_tmp_files
cd ..


mkdir "${processed_folder}"
find  "${siril_tmp_dir}"  -name "*PROCESSED*" -exec cp "{}" "${processed_folder}" ";"


#qrencode "(c) Grupo Supernovas L'Astronòmica de Sabadell" -o qrcode-supernovas.jpeg


find "${processed_folder}" -name  "*PROCESSED.jpg" | sort | while read -r newfile
do
  resolveImage "${newfile}" "${processed_folder}"  
done

find "${processed_folder}" -name  "*PROCESSED.fit" | sort | while read -r newfile
do
 
 comment=$(imageInfoForAnnotation "${newfile}")

 filejpg=$(echo "${newfile}" | sed -e "s/fit/jpg/")
 filepng=$(echo "${newfile}" | sed -e "s/\.fit/-ngc.png/")

 convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${filejpg}" "${filejpg}" 
 convert  -gravity southwest -font Helvetica -pointsize 9  -fill cyan -draw "${comment}" "${filepng}" "${filepng}" 
done


echo "Borrar temporales"
rm -rf "${siril_tmp_dir}"



