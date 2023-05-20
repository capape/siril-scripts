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

info() {

    echo "Process files obtained in supernova group."

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
        echo "requires 0.99.8" >> "${siril_tmp_dir}"/"${siril_script}"

        find "${dark_src_folder}" -maxdepth 1   -iname "${dark_exposition_base_name}*" -type f -exec basename "{}" ";" | while read -r source_file
        do
            destination="${siril_tmp_dir}"/"${tmp_dir}"
            normalized=$(normalize_file_name "${source_file}")
            echo "Copying ${dark_src_folder}/${source_file} to ${destination}/${normalized}"
            cp "${dark_src_folder}/${source_file}" "${destination}"/"${normalized}"
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
        echo "requires 0.99.8" >> "${siril_tmp_dir}"/"${siril_script}"


        find "${flat_src_folder}"  -maxdepth 1  -iname "${flat_exposition_base_name}*" -type f -exec basename "{}" ";" | while read -r source_file
        do
            destination="${siril_tmp_dir}"/"${tmp_dir}"
            normalized=$(normalize_file_name "${source_file}")
            echo "Copying flat ${flat_src_folder}/${source_file} to ${destination}/${normalized}"
            cp "${flat_src_folder}/${source_file}" "${destination}"/"${normalized}"
        done


        echo "cd $tmp_dir" >> "${siril_tmp_dir}"/"${siril_script}"
        echo "preprocess ${flat_exposition_base_name} -bias=../darkflats/${stack_dark_flat}" >> "${siril_tmp_dir}"/"${siril_script}"
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

        copy_light_files_to_image_folder "${img_src_folder}" "${real_source_file}" "${destination}" "${exposition}"
        local nlights
        nlights=$(find "${destination}" -type f | wc -l )
        if [ "${nlights}" -lt 2 ]
        then
           echo "Not enough lights to stack"

        else

            echo "############################################################" >> "${process_folder}"/"${siril_script}"
            echo "# generating ${normalized_object_name} frames" >> "${process_folder}"/"${siril_script}"
            echo "requires 0.99.8" >> "${process_folder}"/"${siril_script}"


            echo "USANDO ${source_file}"

            echo "#############################" >> "${process_folder}"/"${siril_script}"
            echo "# generating ${normalized_object_name} ${source_file}" >> "${process_folder}"/"${siril_script}"
            echo "cd ${tmp_dir}" >> "${process_folder}"/"${siril_script}"


            echo "cd ${source_file}" >> "${process_folder}"/"${siril_script}"

            local sequence
            sequence="${source_file}_${exposition}S_"
            echo "preprocess ${sequence} -dark=../../darks/${stack_dark} -flat=../../flats/${stack_flat}  -cfa" >> "${process_folder}"/"${siril_script}"
            echo "register pp_${sequence}" >> "${process_folder}"/"${siril_script}"
            echo "stack r_pp_${sequence} rej 3 3 -norm=addscale -out=${stack_name}" >> "${process_folder}"/"${siril_script}"
            echo "load ${stack_name}" >> "${siril_tmp_dir}"/"${siril_script}"
            echo "autostretch -linked -2.8 0.1" >> "${siril_tmp_dir}"/"${siril_script}"
            # echo "savetif ${dest_filename}"  >> "${process_folder}"/"${siril_script}"
            echo "savejpg ${dest_filename}"  >> "${process_folder}"/"${siril_script}"
            echo "cd .." >> "${process_folder}"/"${siril_script}"
            echo "cd .." >> "${process_folder}"/"${siril_script}"
            echo "" >> "${process_folder}"/"${siril_script}"
        fi
        }
    done

    echo "" >> "${process_folder}"/"${siril_script}"

}



set_default_values() {
    echo "setfindstar -sigma=0.4 -roundness=0.5" >> "${siril_tmp_dir}"/"${siril_script}"
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


}


if  [ $# -lt  2 ] || [ $# -gt 2 ]
then
    echo "Usage: supernovas.sh img_folder exp"
    echo "  img_folder: Image root folder"
    echo "  exp:  seconds of image exposure"
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
stack_dark_flat=${dark_base_name}_5S_stacked.fit

echo "Generating R flats "
generate_flat_frame 5 "${img_folder}" R flats ${stack_dark_flat}
stack_r_flat="pp_${flat_base_name}_R_5S_stacked.fit"

echo "Generating DS flats "
generate_flat_frame 5 "${img_folder}" DS flats ${stack_dark_flat}
stack_ds_flat="pp_${flat_base_name}_DS_5S_stacked.fit"


echo "Generating darks "
generate_dark_frame "${exp}" "${img_folder}" darks darks
stack_dark="${dark_base_name}_${exp}S_stacked.fit"

echo "Adding config"
set_default_values

generate_objects_with_exp "${img_folder}" "${exp}" "${stack_r_flat}" "${stack_ds_flat}" "${stack_dark}" "${siril_tmp_dir}"
#generating_object "${exp}" "${img_folder}" "DS" "lights" "${stack_ds_flat}" "${stack_dark}" "NBP" "${siril_tmp_dir}"

echo "Running siril "
cd "${siril_tmp_dir}"
siril -d . -s "${siril_script}"
delete_tmp_files
cd ..
mkdir processed
find  "${siril_tmp_dir}"  -name "*PROCESSED*" -exec cp "{}" processed ";"

rm -rf "${siril_tmp_dir}"
