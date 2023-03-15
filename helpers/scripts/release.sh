#!/bin/sh
if [ "$(ps -p "$$" -o comm=)" != "bash" ]; then
    bash "$0" "$@"
    exit "$?"
fi
#
#ASSUME :1. all the release ready modules are tagged and branched (but not pushed)
#        2. dependencies are all updated properly and validated that there are no SNAPSHOT releases left in pom.xml
#

PLAN_NAME=$1

BAMBOO_DB_FOLDER=/home/ebuilder/bamboo_db
CI_PLANS_FILE=$BAMBOO_DB_FOLDER/ci_plans.properties
home_location="/app/bamboo_home/xml-data/build-dir/${PLAN_NAME}-JOB1"
#--------
#bamboo server plan variable : bamboo_build_number
#artifact -release_file will be used by the deployment plan 

#--------
read_property_value(){
    prop_file=$1
    prop_key=$2
    prop_value=$( grep -i "${prop_key}=" ${prop_file}  | cut -f2 -d"=" | cut -f1 -d"," )
    echo ${prop_value}
}


#---------- configuration settings -----

#JAVA_HOME=$(read_property_value "$CI_PLANS_FILE" "${PLAN_NAME}.JAVA_HOME")
JAVA_HOME="${bamboo_java_home}"

#MAVEN_HOME=$(read_property_value "$CI_PLANS_FILE" "${PLAN_NAME}.MAVEN_HOME")
MAVEN_HOME="${bamboo_maven_home}"
MAVAN_REPO_PATH="/home/bamboo/.m2"

#SETTINGS_XML=$(read_property_value "$CI_PLANS_FILE" "${PLAN_NAME}.SETTINGS_XML")
SETTINGS_XML="${bamboo_settings_xml}"
#Will be used in build/release process
export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# getting the global variable to TLS1.2
export "${bamboo.MAVEN_OPTS}"
echo "MAVEN_OPTS: ${MAVEN_OPTS}"

#---------------------------------------

module_release(){

        source_module="${bamboo_module_name}"
        #bamboo_var="bamboo_${bamboo_module_name}"
        release_version="${bamboo_module_version}"

        echo "${bamboo_module_name} -> $release_version"
        
        if [ -z "$release_version" ]; then
            echo "[ SKIPPED ] $source_module no need to release"

        else 
            #echo "$source_module need to release now"
                        
            cd "$home_location"

            cd "$source_module"
            #this should already in the branch and show it is so in the build logs if not there is a problem

            mvn ebuilder:clean-install -s "${MAVAN_REPO_PATH}/${SETTINGS_XML}"
            STATUS=$?
            if [ $STATUS -eq 0 ]; then
                echo "[ SUCCESS ] $source_module $release_version Build Successful"
                
            else
                echo -e "\e[01;31m[  FAILED ]\e[0m $source_module Build Failed"
                return 1
            fi


            echo $release_version | mvn ebuilder:make-release -s "${MAVAN_REPO_PATH}/${SETTINGS_XML}"
            STATUS=$?
            if [ $STATUS -eq 0 ]; then
                echo "[ SUCCESS ] $source_module $release_version Release Successful"
                
            else
                echo -e "\e[01;31m[  FAILED ]\e[0m $source_module Release Failed"
                return 1
            fi
    
        fi
        
        
}


#--- main ----


if [ "${bamboo_module_name}" == "-1" ];then
    echo "info module release skipped successfully"
else
  module_release
fi
