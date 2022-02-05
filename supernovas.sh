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
siril_script="sn_siril.ssf"

function info() {

    echo "Process files obtained in supernova group."

}

function delete_tmp_files() {
    find . -name "r_pp*" -exec rm "{}" ";"
    find . -name "pp*" -exec rm "{}" ";"
    find . -name "*seq" -exec rm "{}" ";"
}

function normalize_file_name() {
    echo $1 | sed -s 's/_\([0-9]\+\)[s|S]_/_\1S_/' 
}


function copy_light_files_to_image_folder () {

    img_src_folder=${1}
    source_file=${2}
    destination=${3}
    
    for light_file in `find ${img_src_folder}  -maxdepth 1 -iname "${source_file}*.fit" -type f -exec basename "{}" ";"`
    do         
      normalized=`normalize_file_name ${light_file}`
      echo "Copying ${source_file} to ${destination}/${normalized}"
      cp ${light_file} ${destination}/${normalized}        
    done
}

###############################################################################
# $1: exposition in seconds
# $2: darks folder
# $3: tmp dir where to save stacked frame
# $4: stack_name
###############################################################################
function generate_dark_frame() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating dark frames" >> ${siril_tmp_dir}/${siril_script}  
    echo "requires 0.99.8" >> ${siril_tmp_dir}/${siril_script}  
    
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

   
    for source_file in `find ${dark_src_folder} -maxdepth 1   -iname "${dark_exposition_base_name}*" -type f -exec basename "{}" ";"`
    do
        destination="${siril_tmp_dir}/${tmp_dir}"
        normalized=`normalize_file_name ${source_file}`
        echo "Copying ${source_file} to ${destination}/${normalized}"
        cp ${source_file} ${destination}/${normalized}        
    done

    echo "cd $tmp_dir" >> ${siril_tmp_dir}/${siril_script}  
    echo "stack ${dark_exposition_base_name} rej 3 3 -nonorm  ">> ${siril_tmp_dir}/${siril_script}
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
    
   
}


###############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: R,DS
# $4: tmp dir where to save stacked frame
# $5: stack_name
###############################################################################
function generate_flat_frame() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating flat frames" >> ${siril_tmp_dir}/${siril_script}  
    echo "requires 0.99.8" >> ${siril_tmp_dir}/${siril_script}  

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

   
    for source_file in `find ${flat_src_folder}  -maxdepth 1  -iname "${flat_exposition_base_name}*" -type f -exec basename "{}" ";"`
    do
        destination="${siril_tmp_dir}/${tmp_dir}"
        normalized=`normalize_file_name ${source_file}`
        echo "Copying ${source_file} to ${destination}/${normalized}"
        cp ${source_file} ${destination}/${normalized}        
    done
    
    echo "cd $tmp_dir" >> ${siril_tmp_dir}/${siril_script}  
    echo "preprocess ${flat_exposition_base_name} -bias=../darkflats/${stack_dark_flat}" >> ${siril_tmp_dir}/${siril_script}  
    echo "stack pp_${flat_exposition_base_name} rej 3 3 -nonorm " >> ${siril_tmp_dir}/${siril_script}
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
    
}




function generating_object() {
     
    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}    
    stack_flat=${5}
    stack_dark=${6}
    object_name=${7}

    
    object_base_name="${object_name}_${filter}_${exposition}S_"
   
    echo "############################################################" 
    echo "# generating ${object_name} frames"
    echo "exposition.......: ${exposition}"
    echo "img_src_folder...: ${img_src_folder}"
    echo "filter...........: ${filter}"    
    echo "tmp_dir..........: ${tmp_dir}"
    echo "${object_name}_base_name....: ${object_base_name}"
    echo "stack_flat.......: ${stack_flat}"
    echo "stack_dark.......: ${stack_dark}"
    
    for source_file in `find ${img_src_folder} -maxdepth 1  -iname "${object_name}_${filter}*_${exposition}S_001.fit" -type f -printf "%f\n" | sed -s s/_${exposition}S_001.fit//i | sort -u`;
    do
       echo "#############################" >> ${siril_tmp_dir}/${siril_script}  
       echo "# generating ${object_name} ${source_file}" >> ${siril_tmp_dir}/${siril_script}  
       echo "cd ${tmp_dir}" >> ${siril_tmp_dir}/${siril_script}  
       stack_name=${source_file}_PROCESSED.fit
       destination="${siril_tmp_dir}/${tmp_dir}/${source_file}"
       mkdir ${destination} 
       
       copy_light_files_to_image_folder ${img_src_folder} ${source_file} ${destination}      
    

       echo "cd ${source_file}" >> ${siril_tmp_dir}/${siril_script}  

       sequence="${source_file}_${exposition}S_"
       echo "preprocess ${sequence} -dark=../../darks/${stack_dark} -flat=../../flats/${stack_flat}  -cfa" >> ${siril_tmp_dir}/${siril_script}  
       echo "register pp_${sequence}" >> ${siril_tmp_dir}/${siril_script}  
       echo "stack r_pp_${sequence} rej 3 3 -norm=addscale -out=${stack_name}" >> ${siril_tmp_dir}/${siril_script}  
       # echo "load ${stack_name}" >> ${siril_tmp_dir}/${siril_script}  
       # echo 
       # echo "savetiff ${source_file}_result.tiff"  >> ${siril_tmp_dir}/${siril_script}  
       echo "cd .." >> ${siril_tmp_dir}/${siril_script}
       echo "cd .." >> ${siril_tmp_dir}/${siril_script}
       echo "" >> ${siril_tmp_dir}/${siril_script}  
    done
    
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
    
}


##############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: R,DS
# $4: tmp dir where to save stacked frame
# $5: stack_name
###############################################################################
function generating_gsn() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating gsn frames" >> ${siril_tmp_dir}/${siril_script}  
    echo "requires 0.99.8" >> ${siril_tmp_dir}/${siril_script}  

    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    gsn_base_name="${supernova_base_name}_${filter}_${exposition}S_"
    stack_flat=${5}
    stack_dark=${6}
    
    generating_object "${exposition}" "${img_src_folder}" "${filter}" "${tmp_dir}" "${stack_flat}" "${stack_dark}" "${supernova_base_name}"
    echo "############################################################" 
    echo ""
    
}

##############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: R,DS
# $4: tmp dir where to save stacked frame
# $5: stack_name
###############################################################################
function generating_glx() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating glx frames" >> ${siril_tmp_dir}/${siril_script}  
    echo "requires 0.99.8" >> ${siril_tmp_dir}/${siril_script}  

    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}    
    stack_flat=${5}
    stack_dark=${6}
    
    generating_object "${exposition}" "${img_src_folder}" "${filter}" "${tmp_dir}" "${stack_flat}" "${stack_dark}" "${galaxy_base_name}"
    echo "############################################################" 
    echo ""
}


##############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: R,DS
# $4: tmp dir where to save stacked frame
# $5: stack_name
###############################################################################
function generating_nebulae() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating neb frames" >> ${siril_tmp_dir}/${siril_script}  
    echo "requires 0.99.8" >> ${siril_tmp_dir}/${siril_script}  

    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    neb_base_name="${nebulae_base_name}_${filter}_${exposition}S_"
    stack_flat=${5}
    stack_dark=${6}
    
    generating_object "${exposition}" "${img_src_folder}" "${filter}" "${tmp_dir}" "${stack_flat}" "${stack_dark}" "${nebulae_base_name}"
    echo "############################################################" 
    echo ""
    
}



function set_default_values() {
    echo "setfindstar 0.5 0.4" >> ${siril_tmp_dir}/${siril_script}
}


siril_tmp_dir="./siril_process"
echo "Creating ${siril_tmp_dir} folder for processing"
mkdir ${siril_tmp_dir}


echo "############################################################" >  ${siril_tmp_dir}/${siril_script}
echo "# Autogenerated siril process" >>  ${siril_tmp_dir}/${siril_script}
echo "############################################################" >>  ${siril_tmp_dir}/${siril_script}


echo "Creating ${siril_tmp_dir}/darkflats folder for processing"
mkdir ${siril_tmp_dir}/darkflats

echo "Creating ${siril_tmp_dir}/flats folder for processing"
mkdir ${siril_tmp_dir}/flats

echo "Creating ${siril_tmp_dir}/darks folder for processing"
mkdir ${siril_tmp_dir}/darks

echo "Creating ${siril_tmp_dir}/lights folder for processing"
mkdir ${siril_tmp_dir}/lights




echo "Generating dark flats "
generate_dark_frame 5 ${1} darkflats darkflat.fit
stack_dark_flat=${dark_base_name}_5S_stacked.fit

echo "Generating R flats "
generate_flat_frame 5 ${1} R flats ${stack_dark_flat}
stack_r_flat="pp_${flat_base_name}_R_5S_stacked.fit"

echo "Generating DS flats "
generate_flat_frame 5 ${1} DS flats ${stack_dark_flat}
stack_ds_flat="pp_${flat_base_name}_DS_5S_stacked.fit"


echo "Generating darks "
generate_dark_frame 60 ${1} darks darks
stack_dark=${dark_base_name}_60S_stacked.fit

echo "Adding config"
set_default_values

echo "Generating galaxy supernova "
generating_gsn 60 ${1} R lights ${stack_r_flat} ${stack_dark}

echo "Generating galaxy "
generating_glx 60 ${1} DS lights ${stack_ds_flat} ${stack_dark}

echo "Generating nebulae "
generating_nebulae 60 ${1} DS lights ${stack_ds_flat} ${stack_dark}


echo "Running siril "
cd ${siril_tmp_dir} 
siril -s ${siril_script} 
delete_tmp_files
cd ..
