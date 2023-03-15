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

read_property_value(){
    prop_file=$1
    prop_key=$2
    prop_value=$( grep -i "${prop_key}=" ${prop_file}  | cut -f2 -d"=" )
    echo ${prop_value}
}

purge_repos(){
       
       source_module=$1
       
       echo "Initiate repository clean-up"
       cd "$home_location"
       
       rm -rf $home_location/$source_module/
       
        if [ $? -eq 0 ]; then
                  echo "old module revisions removed"    
        fi
}

#checkout module given a name 
checkout_module(){

    source_module=$1
    source_branch=$2
    echo "checkout --> $source_module - $source_branch"
        
    cd "$home_location"
                        
    git clone "ssh://bamboo@brink.ebuilder.com/home/git/repositories/$source_module.git"

    echo "switching to branch $source_branch"
    git checkout "$source_branch"


}

verify_modules(){
    
    # entire workspace removed in previous task
	#purge_repos

        if [ -z "$bamboo_mwaf_web_branch" ]; then
            #echo "$source_module no need to release"
              echo "[  SKIPPED ]    $source_module need not be checkout now"
        else 

            checkout_module "mwaf-web" "$bamboo_mwaf_web_branch"

            cd "$home_location/"
    
       fi
    
}

#----- main script ------
if [ "${bamboo_mwaf_web_branch}" == "-1" ];then
    echo "info mwaf Web Checkout module skipped successfully"
else
    verify_modules
fi
