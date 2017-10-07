#!/bin/bash

args_num=$#
args=$@
echo "args num:"$args_num
echo "args:"$args

projects="pahf|njhf|ilhf|onhf|lahf|itools|secure"
svn_common=(libs util)

lahf="sas_lahf als_web_la payment" 
pahf="sas_pahf als_web_pa payment ip_pos" 
njhf="sas_njhf als_web_nj payment ip_pos" 
onhf="payment ip_pos"
ilhf="payment" 
itools="payment"

base_path=/apache/dev
for param in $args ; do
    case $param in
        --force )
            is_force=1
            ;;
        --prefix=* )
            base_path=${param#--prefix=}
            # right trim tail '/'
            base_path=${base_path%/}
            ;;
        all )
            download_projects=${projects//|/ }
            ;;
        * )
            download_projects="$download_projects $param"
            ;;
    esac
done

secure_path=$base_path/secure
htdocs_path=$base_path/htdocs

echo "Download projects are: [$download_projects], is_force: [$is_force] to download. base path:[$base_path], secure path:[$secure_path], htdocs_path:[$htdocs_path]"

#  used to define local secure.tar.gz and preload.php path
install_codes_path=/opt/install/codes
svn_base="http://aohfashutil02.active.tan/svn/activehuntfish/"

svn_trunk_path()
{
    svn_proj=$1
    svn_branch=$2
    svn_branch_subdir=$4
    svn_path="$svn_base$svn_proj/$svn_branch/$svn_branch_subdir"
}

svn_branch_path()
{
    svn_proj=$1
    svn_branch=$2
    svn_version=$3
    svn_branch_subdir=$4
    svn_path="$svn_base$svn_proj/branches/${svn_branch}_r$svn_version/$svn_branch_subdir"
}
svn_checkout() {
    can_overwrite_folder $1
    can_checkout=$?

    if [[ can_checkout -eq 1 ]]; then
        # 1: local_path, 2: is_master, 3: svn project 4: branch name 5: branch version, 6: master subdir 7: master name
        if [[ $2 -eq 0 ]]; then
            #statements
            svn_branch_path $3 $4 $5 $6
        else
            svn_trunk_path  $3 $4 $5 $6
        fi
        echo "SVN checking out branch[$svn_path] to path[$1] with username[$SVN_USER]"
        svn checkout --username $SVN_USER --password $SVN_PSW --no-auth-cache $svn_path $1
        echo "SVN checkout done"
    else
        echo "The path[$1] existed, not need to svn checkout"
    fi
}
svn_backend_checkout() {
    can_overwrite_folder $1
    can_checkout=$?

    if [[ can_checkout -eq 1 ]]; then
        # 1: local_path, 2: is_master, 3: svn project 4: branch name 5: branch version, 6: master subdir 7: master name
        if [[ $2 -eq 0 ]]; then
            #statements
            svn_branch_path $3 $4 $5 $6
        elif [[ -n $7 ]]; then
            svn_trunk_path  $3 $7 $5 $6
        else
            svn_trunk_path  $3 $6 $5 $6
        fi
        echo "SVN checking out branch[$svn_path] to path[$1] with username[$SVN_USER]"
        svn checkout --username $SVN_USER --password $SVN_PSW --no-auth-cache $svn_path $1
        echo "SVN checkout done"
    else
        echo "The path[$1] existed, not need to svn checkout"
    fi
}
can_overwrite_folder() {
    tmp_path=$1
    if [[ $is_force -eq 1 ]]; then
        # right trim the last character /
        tmp_path=${tmp_path%/}
        mv $tmp_path "$tmp_path`date "+%Y%m%d%H%M%S"`"
        return 1
    fi
    if [[ "`ls -A $tmp_path 2>/dev/null`" = "" ]]; then
        return 1
    fi
    return 0
}

link_file() {
    #echo "link_file:$@"

    if [[ -z $1 ]]; then
        return 1
    fi
    if [[ -z $2 ]]; then
        return 1
    fi
    tmp_source_path=${1%/}
    tmp_target_path=${2%/}
    # return if source file does not exist
    if [[ ! -e $tmp_source_path ]]; then
        echo "The source file[$tmp_source_path] does not exist, not need to link to target file[$tmp_target_path]."
        return 1
    fi

    # return if target file exist.
    if [[ -e $tmp_target_path ]]; then
        echo "The target file[$tmp_target_path] existed already, not need to link from source file[$tmp_source_path]."
        return 1
    fi

    # return if target file is link
    if [[ -L $tmp_target_path ]]; then
        echo "The target file[$tmp_target_path] is a link already, not need to link from source file[$tmp_source_path]."
        return 1
    fi

    tmp_target_dir=${tmp_target_path%/*}
    # if is directory, mkdir parent folder
    if [[ "x$tmp_target_dir" != "x$tmp_target_path" ]]; then
        mkdir -p $tmp_target_dir && cd $tmp_target_dir
    fi

    if [[ -n $3 ]]; then
        ln_source=$3
    else
        ln_source=$tmp_source_path
    fi

    if [[ -n $4 ]]; then
        ln_target=$4
    else
        ln_target=$tmp_target_path
    fi

    ln -s $ln_source $ln_target 

    echo "link_file, target dir:[$tmp_target_dir], source:[$ln_source], target:[$ln_target]"
    return 0
}

for arg in $download_projects; do
    arg_lower=`echo $arg | tr 'A-Z' 'a-z'`
    if [[ "x$arg_lower" = "xsecure_local" ]]; then
        is_master=0
        project_lower=${arg_lower}
        version=local
        echo "Project:"$project_lower", ismaster:"$is_master", version:"$version

    elif [[ `echo $arg_lower | grep -E "^($projects)_r[0-9\.]+$"` ]]; then
        is_master=0
        project_lower=${arg_lower%%_r*}
        version=${arg_lower#*_r}
        echo "Project:"$project_lower", ismaster:"$is_master", version:"$version

    elif [[ `echo $arg_lower | grep -E "^($projects)$"` ]]; then
        is_master=1
        project_lower=$arg_lower
        version=master
        echo "Project:"$project_lower", ismaster:"$is_master
    fi

    if [[ -n $project_lower ]]; then
        project_upper=`echo $project_lower | tr 'a-z' 'A-Z'`
        project_base=${project_lower%%hf}
        project_base_path="$htdocs_path/web_$project_base"

        if [[ "x$project_lower" = "xsecure" ]]; then
            project_path=$secure_path
            svn_checkout $project_path $is_master $project_upper $project_lower $version $project_base

        elif [[ "x$project_lower" = "xsecure_local" ]]; then
            project_path=$secure_path
            can_overwrite_folder $project_path
            can_copy=$?
            if [[ can_copy -eq 1 ]]; then
                mkdir -p $secure_path
                if [[ -e "$install_codes_path/secure.tar.gz" ]]; then
                    tar -zxvf "$install_codes_path/secure.tar.gz" -C "$project_path"
                    echo "tar the local file[$install_codes_path/secure.tar.gz] to the path[$project_path]"
                else
                    echo "Note: The local secure[$install_codes_path/secure.tar.gz] does not exist"
                fi
            else
                echo "The path[$project_path] existed, not need to copy the codes."
            fi

        else
            project_path="$project_base_path/$project_base"
            svn_checkout $project_path $is_master "${project_upper}_WEB" $project_lower $version $project_base

            for var in ${svn_common[@]}; do
                var_path="$project_base_path/$var"
                #if [[ ! -d $var_path ]]; then
                var_upper=`echo $var | tr 'a-z' 'A-Z'`
                svn_backend_checkout $var_path $is_master "${var_upper}_WEB" $project_lower $version $var
            done
        fi

        for var in ${!project_lower} ; do
            case $var in
                als_* )
                    var_path="$project_base_path/$project_base/ALS"
                    ;;
                sas|sas_[_a-z]* )
                    var_path="$htdocs_path/sas/$project_base"
                    ;;
                *)
                    var_path="$project_base_path/$var"
                    ;;
            esac

            var_upper=`echo $var | tr 'a-z' 'A-Z'`
            case $var in
                payment|ip_pos )
                    svn_backend_checkout $var_path $is_master "${var_upper}_WEB" $project_lower $version $var
                    ;;
                sas|sas_[_a-z]* )
                    svn_backend_checkout $var_path $is_master $var_upper $project_lower $version sas
                    ;;
                als_* ) 
                    svn_backend_checkout $var_path $is_master $var_upper $project_lower $version ALS als_web
                    ;;
            esac

        done
    fi

    if [[ -d $project_path ]]; then
        if [[ `echo $arg_lower | grep -E "^(secure|secure_local)$"` ]]; then
            cd $project_path
            if [[ ! -e $project_path/preload.php ]]; then
                if [[ -e $install_codes_path/preload.php ]]; then
                    cp $install_codes_path/preload.php $project_path/preload.php
                else
                    echo "Note: The preload file[$install_codes_path/preload.php] does not exit."
                fi
            fi
            link_file $project_path/dev_config1_vegas.inc $project_path/config.inc dev_config1_vegas.inc config.inc

            link_file $project_path/dev_web1_system_vegas.inc $project_path/system.inc dev_web1_system_vegas.inc system.inc

            link_file $project_path/rbac/rbac.inc.php $project_path/rbac.inc.php rbac/rbac.inc.php rbac.inc.php

            link_file $project_path/bdbug/dbugConfig.inc $project_path/bdbug/bugConfig.inc dbugConfig.inc bugConfig.inc

        elif [[ -n $project_lower ]]; then
            # set up links for libs
            case $project_base in
                itools )
                    ;;
                * ) # LA, PA
                    link_file $project_base_path/libs $project_path/libs ../libs libs
                    ;;
            esac

            # setup links for utils
            case $project_base in
                *) # 
                    #if [[ ! -L $project_path/util ]]; then
                    #ln -s ../util util
                    #fi 
                    ;;
            esac

            # set up pdf
            case $project_base in
                itools )
                    mkdir -p $base_path/pdf/assist
                    link_file $base_path/pdf/assist $project_path/assist/pdf
                    ;;
                * ) # LA, PA

                    mkdir -p $base_path/pdf/$project_base
                    link_file $base_path/pdf/$project_base $project_path/pdf
                    ;;
            esac

            # set up ALS xajax
            case $project_base in
                on )
                    link_file $project_base_path/util/xajax $project_path/xajax ../util/xajax xajax
                    ;;
                nj )
                    link_file $project_base_path/util/xajax $project_path/ALS/xajax ../../util/xajax xajax
                    link_file $project_base_path/util/xajax $project_path/ALS/console/xajax ../../../util/xajax xajax
                    ;;
                la|pa ) # LA
                    link_file $project_base_path/util/xajax $project_path/ALS/xajax ../../util/xajax xajax
                    ;;
            esac

            # set up ALS images
            case $project_base in
                la ) # LA
                    link_file $project_base_path/util/p801/images $project_path/ALS/images ../../util/p801/images images
                    ;;
            esac

            # set up datamax_*.exe
            case $project_base in
                la|pa|nj ) # LA
                    link_file $project_base_path/util/p801/datamax_6_9_1_m_0.exe $project_path/ALS/datamax_6_9_1_m_0.exe ../../util/p801/datamax_6_9_1_m_0.exe datamax_6_9_1_m_0.exe
                    ;;
                il|on )
                    link_file $project_base_path/util/p801/datamax_6_9_1_m_0.exe $project_path/datamax_6_9_1_m_0.exe ../util/p801/datamax_6_9_1_m_0.exe datamax_6_9_1_m_0.exe
                    ;;
            esac

            # set up barcodeGen.php
            case $project_base in
                il|on )
                    link_file $project_path/util/barcode/Image_Barcode/barcodeGen.php $project_path/barcodeGen.php ../util/barcode/Image_Barcode/barcodeGen.php barcodeGen.php
                    ;;
                pa )
                    link_file $project_path/util/barcode/Image_Barcode/barcodeGen.php $project_path/ALS/barcodegen/barcodeGen.php ../../../util/barcode/Image_Barcode/barcodeGen.php barcodeGen.php
                    ;;
            esac

            if [[ "x$project_base" = "xitools" ]]; then
                link_file $project_path/deployment_dev/deployment_dev.sh $project_path/deployment_dev/deployment.sh deployment_dev.sh deployment.sh
                link_file $project_path/rbac/users.php $project_path/rbac/index.php users.php index.php
            fi
        fi
    else
        echo "The project path[$project_path] does not created successfully!"
    fi
done
