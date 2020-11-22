#!/bin/bash -x
###############################################################################
#
# Shell functions to process data from supernovas images.
#
###############################################################################
flat_base_name="FFF"
dark_base_name="CDO"
galaxy_base_name="GLX"
supernova_base_name="GSN"
siril_script="sn_siril.ssf"

function info() {

    echo "Process files obtained in supernova group."

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
    
    exposition=${1}
    dark_src_folder=${2}
    tmp_dir=${3}
    dark_exposition_base_name="${dark_base_name}_${exposition}S_"
    stack_name=${4}
    
    for source_file in `find ${dark_src_folder} -name "${dark_exposition_base_name}*" -type f`;
    do
        cp ${source_file} ${siril_tmp_dir}/${tmp_dir}        
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
    
    exposition=${1}
    flat_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    flat_exposition_base_name="${flat_base_name}_${filter}_${exposition}S_"    
    stack_dark_flat=${5}
    
    for source_file in `find ${flat_src_folder} -name "${flat_exposition_base_name}*" -type f`;
    do
        cp ${source_file} ${siril_tmp_dir}/${tmp_dir}        
    done

    echo "cd $tmp_dir" >> ${siril_tmp_dir}/${siril_script}  
    echo "preprocess ${flat_exposition_base_name} -bias=../darkflats/${stack_dark_flat}" >> ${siril_tmp_dir}/${siril_script}  
    echo "stack pp_${flat_exposition_base_name} rej 3 3 -nonorm " >> ${siril_tmp_dir}/${siril_script}
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
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
 

    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    gsn_base_name="${supernova_base_name}_${filter}_${exposition}S_"
    stack_flat=${5}
    stack_dark=${6}
    
    

    
    for source_file in `find ${img_src_folder} -name "${supernova_base_name}*001.fit" -type f -printf "%f\n" | sed -s s/_${exposition}S_001.fit//`;
    do
       echo "#############################" >> ${siril_tmp_dir}/${siril_script}  
       echo "# generating gsn ${source_file}" >> ${siril_tmp_dir}/${siril_script}  
       echo "cd ${tmp_dir}" >> ${siril_tmp_dir}/${siril_script}  
       stack_name=${source_file}.fit
       mkdir ${siril_tmp_dir}/${tmp_dir}/${source_file}

       find ${img_src_folder} -name "${source_file}*.fit" -type f -exec cp "{}" ${siril_tmp_dir}/${tmp_dir}/${source_file} ";"

       echo "cd ${source_file}" >> ${siril_tmp_dir}/${siril_script}  

       sequence="${source_file}_${exposition}S_"
       echo "preprocess ${sequence} -dark=../../darks/${stack_dark} -flat =../../flats/${stack_flat} -cfa" >> ${siril_tmp_dir}/${siril_script}  
       echo "register pp_${sequence}" >> ${siril_tmp_dir}/${siril_script}  
       echo "stack r_pp_${sequence} rej 3 3 -norm=addscale " >> ${siril_tmp_dir}/${siril_script}  
       # echo "load ${stack_name}"
       echo 
       echo "savetiff ${supernova_base_name}_result"
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
function generating_glx() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating glx frames" >> ${siril_tmp_dir}/${siril_script}  
 

    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    glx_base_name="${galaxy_base_name}_${filter}_${exposition}S_"
    stack_flat=${5}
    stack_dark=${6}
    
    

    
    for source_file in `find ${img_src_folder} -name "${galaxy_base_name}*001.fit" -type f -printf "%f\n" | sed -s s/_${exposition}S_001.fit//`;
    do
       echo "#############################" >> ${siril_tmp_dir}/${siril_script}  
       echo "# generating glx ${source_file}" >> ${siril_tmp_dir}/${siril_script}  
       echo "cd ${tmp_dir}" >> ${siril_tmp_dir}/${siril_script}  
       stack_name=${source_file}.fit
       mkdir ${siril_tmp_dir}/${tmp_dir}/${source_file}

       find ${img_src_folder} -name "${source_file}*.fit" -type f -exec cp "{}" ${siril_tmp_dir}/${tmp_dir}/${source_file} ";"

       echo "cd ${source_file}" >> ${siril_tmp_dir}/${siril_script}  

       sequence="${source_file}_${exposition}S_"
       echo "preprocess ${sequence} -dark=../../darks/${stack_dark} -flat =../../flats/${stack_flat}  -cfa" >> ${siril_tmp_dir}/${siril_script}  
       echo "register pp_${sequence}" >> ${siril_tmp_dir}/${siril_script}  
       echo "stack r_pp_${sequence} rej 3 3 -norm=addscale -out=${stack_name}" >> ${siril_tmp_dir}/${siril_script}  
       echo "load ${stack_name}"
       echo 
       echo "savetiff ${galaxy_base_name}_result"

        echo "cd .." >> ${siril_tmp_dir}/${siril_script}
        echo "cd .." >> ${siril_tmp_dir}/${siril_script}
        echo "" >> ${siril_tmp_dir}/${siril_script}  
    done
    
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
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

echo "Generating galaxy supernova "
generating_gsn 60 ${1} R lights ${stack_r_flat} ${stack_dark}

echo "Generating galaxy "
generating_glx 60 ${1} DS lights ${stack_ds_flat} ${stack_dark}

echo "Running siril "
cd ${siril_tmp_dir} 
siril -s ${siril_script}
cd ..
