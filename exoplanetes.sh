#!/bin/bash 
###############################################################################
#
# Shell functions to process data from exos images.
#
###############################################################################
dark_flat_base_name="CDF"
flat_base_name="FFF"
dark_base_name="CDO"
bias_base_name="BIAS"
exo_base_name="EXO"
siril_script="exo_siril.ssf"

function info() {

    echo "Process files obtained in exoplanetes group."

}

###############################################################################
# $1: exposition in seconds
# $2: darks folder
# $3: tmp dir where to save stacked frame
###############################################################################
function generate_dark_frame() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating dark frames" >> ${siril_tmp_dir}/${siril_script}  
    
    exposition=${1}
    dark_src_folder=${2}
    tmp_dir=${3}
    dark_exposition_base_name="${dark_base_name}_${exposition}s_"
    
    for source_file in `find ${dark_src_folder} -iname "${dark_exposition_base_name}*" -type f`;
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
# $2: darks flat folder
# $3: tmp dir where to save stacked frame
# $4: stack_name
###############################################################################
function generate_dark_flat_frame() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating dark flats frames" >> ${siril_tmp_dir}/${siril_script}  
    
    exposition=${1}
    dark_src_folder=${2}
    tmp_dir=${3}
    dark_exposition_base_name="${dark_flat_base_name}_${exposition}s_"
    
    
    for source_file in `find ${dark_src_folder} -iname "${dark_exposition_base_name}*" -type f`;
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
# $2: bias folder
# $3: tmp dir where to save stacked frame
###############################################################################
function generate_bias_frame() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating bias frames" >> ${siril_tmp_dir}/${siril_script}  
    
    exposition=${1}
    bias_src_folder=${2}
    tmp_dir=${3}

    bias_exposition_base_name="${bias_base_name}_${exposition}s_"
    
    for source_file in `find ${bias_src_folder} -iname "${bias_exposition_base_name}*" -type f`;
    do
        cp ${source_file} ${siril_tmp_dir}/${tmp_dir}        
    done

    echo "cd $tmp_dir" >> ${siril_tmp_dir}/${siril_script}  
    echo "stack ${bias_exposition_base_name} median -nonorm  ">> ${siril_tmp_dir}/${siril_script}
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
}



###############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: R,DS,V
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
    flat_exposition_base_name="${flat_base_name}_${filter}_${exposition}s_"    
    stack_biases=${5}
    stack_dark_flats=${6}
    
    for source_file in `find ${flat_src_folder} -iname "${flat_exposition_base_name}*" -type f`;
    do

        cp ${source_file} ${siril_tmp_dir}/${tmp_dir}        
    done

    echo "cd $tmp_dir" >> ${siril_tmp_dir}/${siril_script}  
    echo "preprocess ${flat_exposition_base_name} -dark=../darkflats/${stack_dark_flats} -bias=../biases/${stack_biases}" >> ${siril_tmp_dir}/${siril_script}  
    echo "stack pp_${flat_exposition_base_name} rej 3 3 -nonorm " >> ${siril_tmp_dir}/${siril_script}
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
}


##############################################################################
# $1: exposition in seconds
# $2: flats folder
# $3: filter: V,R,DS
# $4: tmp dir where to save stacked frame
# $5: stack_name
###############################################################################
function generating_exo() {

    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating exo frames" >> ${siril_tmp_dir}/${siril_script}  
 

    exposition=${1}
    img_src_folder=${2}
    filter=${3}
    tmp_dir=${4}
    exo_base_name="${exo_base_name}_${filter}_"
    stack_flat=${5}
    stack_dark=${6}
    stack_bias=${7}
     

    echo "#############################" >> ${siril_tmp_dir}/${siril_script}  
    echo "# generating exo sequence ${source_file}" >> ${siril_tmp_dir}/${siril_script}  

    for source_file in `find ${img_src_folder} -iname "${exo_base_name}*.fit" -type f -maxdepth 1`;
    do
       # echo "# Copying file ${source_file}" >> ${siril_tmp_dir}/${siril_script}         
       cp ${source_file}  ${siril_tmp_dir}/${tmp_dir}
    done
    
    sequence=`find ${img_src_folder} -iname "${exo_base_name}*_001.fit" -type f -printf "%f\n" | sed -e "s/001.fit//"` 

    echo "cd $tmp_dir" >> ${siril_tmp_dir}/${siril_script} 
    echo "preprocess ${sequence} -bias=../biases/${stack_bias} -dark=../darks/${stack_dark} -flat=../flats/${stack_flat} -equalize_cfa -cfa " >> ${siril_tmp_dir}/${siril_script}  
    # echo "load ${stack_name}"
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
    echo "cd .." >> ${siril_tmp_dir}/${siril_script}
    echo "" >> ${siril_tmp_dir}/${siril_script}  
    
    
    echo "############################################################" >> ${siril_tmp_dir}/${siril_script}  
    echo "" >> ${siril_tmp_dir}/${siril_script}  
}





siril_tmp_dir="./siril_process"
echo "Creating ${siril_tmp_dir} folder for processing"
mkdir ${siril_tmp_dir}


echo "############################################################" >  ${siril_tmp_dir}/${siril_script}
echo "# Autogenerated siril process                              #" >>  ${siril_tmp_dir}/${siril_script}
echo "############################################################" >>  ${siril_tmp_dir}/${siril_script}


echo "Creating ${siril_tmp_dir}/biases folder for processing"
mkdir ${siril_tmp_dir}/biases

echo "Creating ${siril_tmp_dir}/darkflats folder for processing"
mkdir ${siril_tmp_dir}/darkflats

echo "Creating ${siril_tmp_dir}/flats folder for processing"
mkdir ${siril_tmp_dir}/flats

echo "Creating ${siril_tmp_dir}/darks folder for processing"
mkdir ${siril_tmp_dir}/darks

echo "Creating ${siril_tmp_dir}/lights folder for processing"
mkdir ${siril_tmp_dir}/lights


echo "Generating biases "
generate_bias_frame 0 ${1} biases
stack_biases=${bias_base_name}_0s_stacked.fit

echo "Generating dark flats "
generate_dark_flat_frame 10 ${1} darkflats
stack_dark_flat=${dark_flat_base_name}_10s_stacked.fit

echo "Generating V flats "
generate_flat_frame 10 ${1} V flats ${stack_biases} ${stack_dark_flat}
stack_flat="pp_${flat_base_name}_V_10s_stacked.fit"

echo "Generating darks "
generate_dark_frame 60 ${1} darks darks
stack_dark=${dark_base_name}_60s_stacked.fit

echo "Generating exoplanets files "
generating_exo 60 ${1} V lights ${stack_flat} ${stack_dark} ${stack_biases}

echo "Running siril "
cd ${siril_tmp_dir} 

siril -s ${siril_script}
cd ..
