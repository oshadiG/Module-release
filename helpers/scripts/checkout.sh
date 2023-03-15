#!/bin/sh
#checkout_modules.sh last modified : 14-09-2019
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then
    bash "$0" "$@"
    exit "$?"
fi

PLAN_NAME=$1
#PLAN_NAME="SINGLE-MODULE-BUILD"

BAMBOO_DB_FOLDER=/home/ebuilder/bamboo_db
CI_PLANS_FILE=$BAMBOO_DB_FOLDER/ci_plans.properties
home_location="/app/bamboo_home/xml-data/build-dir/${PLAN_NAME}-JOB1"


purge_repos(){
       
       echo "Initiate repository clean-up"
       cd "$home_location"
       
       rm -rf $home_location/*
       
        if [ $? -eq 0 ]; then
                  echo "old module revisions removed"    
        fi
}

#checkout module given a name 
checkout_module(){

    source_module=$1
    echo "checking out --> $source_module"
        
    cd "$home_location"
                        
    git clone "ssh://bamboo@brink.ebuilder.com/home/git/repositories/$source_module.git"
    cd "$source_module"
    git checkout "${bamboo_module_branch}"
    echo "checkout --> $source_module module. Branch ${bamboo_module_branch}"
}


verify_modules(){
    
    #bamboo_build_number=10
    
    #bulildNum=`printf "%05d" ${bamboo_build_number}`
    #echo "Build Number -> ${bamboo_build_number}"
    purge_repos
    
    source_module="${bamboo_module_name}"
    #bamboo_var="bamboo_${bamboo_module_name}"
    release_version="${bamboo_module_version}"
    module_branch="${bamboo_module_branch}"

        if [ -z "$module_branch" ]; then
            echo "[  SKIPPED ]    $source_module module cannot verify.No brach info given"
        else 
            checkout_module "$source_module"
        fi

}

#----- main script ------
if [ "${bamboo_module_name}" == "-1" ];then
    echo "info Checkout modules skipped successfully"
else
    verify_modules
fi
