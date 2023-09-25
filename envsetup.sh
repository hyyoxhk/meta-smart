#!/bin/bash -
unalias -a

_FORMAT_PATTERN='£-£'

#----------------------------------------------
# Set default layer root
#
if [ -z "$META_LAYER_ROOT" ]; then
    _META_LAYER_ROOT=layers/meta-board
else
    _META_LAYER_ROOT=$META_LAYER_ROOT
fi

#----------------------------------------------
# Set ROOTOE for oe sdk baseline
#
ROOTOE=$PWD
while test ! -d "${ROOTOE}/${_META_LAYER_ROOT}" && test "${ROOTOE}" != "/"
do
    ROOTOE=$(dirname ${ROOTOE})
done
if test "${ROOTOE}" == "/"
then
    echo "[ERROR] you're trying to launch the script outside oe sdk tree"
    return 1
fi


# Envsetup help
#
stoe_help() {
    echo "Usage:"
    echo "  source ${BASH_SOURCE#$PWD/} [OPTION]"
}

# init UI_CMD if needed
set_env_init() {
    if [ "$_ENABLE_UI" -eq 1 ] && [ -z "${UI_CMD}" ]; then
        # Init dialog box command if dialog or whiptail is available
        command -v dialog > /dev/null 2>&1 && UI_CMD='dialog'
        command -v whiptail > /dev/null 2>&1 && UI_CMD='whiptail'
    fi
}

# extract requested VAR from conf files for BUILD_DIR provided
oe_config_read() {
    local builddir=$(readlink -f $1)
    local stoe_var=$2
    local findconfig=""
    local findconfig_append=""
    local toformat="NO"

    if ! [ -z "$(grep -Rs "^[ \t]*$stoe_var[ \t+]*=" $builddir/conf/*.conf)" ]; then
        # Config defined as "=" or "=+" in conf file
        if ! [[ -z $(grep -Rs "^[ \t]*$stoe_var[ \t+]*=" $builddir/conf/*.conf | grep -v -e "[ \t]*$stoe_var[ \t]*=+" -e "[ \t]*$stoe_var[ \t]*+=") ]]; then
            # Config defined as "=" in conf file
            findconfig=$(grep -Rs "^[ \t]*$stoe_var[ \t+]*=" $builddir/conf/*.conf | grep -v -e "[ \t]*$stoe_var[ \t]*=+" -e "[ \t]*$stoe_var[ \t]*+=")
            # If multiple config are set, select the one from local.conf file (same as bitbake preference order)
            [ "$(echo "$findconfig" | wc -l)" -gt 1 ] && findconfig=$(echo "$findconfig" | grep "local\.conf")
            # Manage to append any "+=" or "=+" to current defined config
            findconfig_append=$(grep -Rs -e "^[ \t]*$stoe_var[ \t]*+=" -e "^[ \t]*$stoe_var[ \t]*=+" $builddir/conf/*.conf)
            [ -z "$findconfig_append" ] || findconfig=$(echo -e "$findconfig\n$findconfig_append")
            toformat="YES"
        else
            # Config defined as "=+" or "+=" only in conf file
            # We do not want to handle such define
            findconfig="\<some-append-set-to-original-config\>"
        fi
    elif ! [[ -z $(grep -Rs "^[ \t]*$stoe_var[ \t?]*=" $builddir/conf/*.conf) ]]; then
        # Config defined as "?=" in conf file
        findconfig=$(grep -Rs "^[ \t]*$stoe_var[ \t?]*=" $builddir/conf/*.conf)
        # If multiple config are set, select the one from local.conf file (same as bitbake preference order)
        [ "$(echo "$findconfig" | wc -l)" -gt 1 ] && findconfig=$(echo "$findconfig" | grep "local\.conf")
        toformat="YES"
    elif ! [[ -z $(grep -Rs "^[#]*$stoe_var[ \t+?]*=" $builddir/conf/*.conf) ]]; then
        findconfig="\<disable\>"
    else
        # Config not found
        findconfig="\<no-custom-config-set\>"
    fi

    if [ "$toformat" = "YES" ]; then
        # Use tmp file to store formated config(s)
        TmpConfigFile=$(mktemp)
        # Format config
        echo "$findconfig" | sed -e 's|^.*"\([^"]*\)".*$|\1|g;s|\${TOPDIR}|\${builddir}|g' > $TmpConfigFile
        # Init new tmp file to store expanded config var(s)
        NewConfigFile=$(mktemp)
        # Expand config
        while read l
        do
            eval echo $l >> $NewConfigFile
        done < $TmpConfigFile
        # Export config
        cat $NewConfigFile
        rm -f $NewConfigFile $TmpConfigFile
    else
        # Expand and export config
        eval echo $findconfig
    fi
}

######################################################
# alias function: display current configuration
#
stoe_config_summary() {
    local builddir=""
    if [[ $# == 0 ]]; then
        # Override builddir in case of none argument provided
        builddir=$BUILDDIR
    elif [ $(readlink -f $1) ]; then
        # Use provided dir as builddir
        builddir=$(readlink -f $1)
    else
        echo "[ERROR] '$1' is not an existing BUILD_DIR."
        echo ""
        return 1
    fi
}

######################################################
# extract description for images provided
_vtoe_list_images_descr() {
    for l in $1;
    do
        local image=$(echo $l | sed -e 's#^.*/\([^/]*\).bb$#\1#')
        if [ ! -z "$(grep "^SUMMARY[ \t]*=" $l)" ]; then
            local descr=$(grep "^SUMMARY[ \t]*=" $l | sed -e 's/^.*"\(.*\)["\]$/\1/')
        else
            local descr=$(grep "^DESCRIPTION[ \t]*=" $l | sed -e 's/^.*"\(.*\)["\]$/\1/')
        fi
        if [ -z "$descr" ] && [ "$2" = "ERR" ]; then
            descr="[ERROR] No description available"
        fi
        printf "    %-33s  -   $descr\n" $image
    done
}

######################################################
# alias function: list all images available
#
stoe_list_images() {
    local metalayer=""
    if [ "$#" = "0" ]; then
        echo "[ERROR] missing layer path."
        return 1
    elif [ -e $(readlink -f $1)/conf/layer.conf ] || [ "$(readlink -f $1)" = "$(readlink -f ${ROOTOE}/${_META_LAYER_ROOT})" ]; then
        # Use provided dir as metalayer
        metalayer=$(readlink -f $1)
    else
        echo "[ERROR] '$1' is not an existing layer."
        echo ""
        return 1
    fi
    local err=$2
    local filter=$3

    local LIST=$(find $metalayer/ -type d \( -name '.git' -o -name 'source*' -o -name 'script*' \) -prune -o -type f -wholename '*/images/*.bb' -not -wholename '*/meta-skeleton/*' | grep '.*/images/.*\.bb' | sort)

    if [ "$filter" = "FILTER" ]; then
        local LAYERS_LIST=$(find $metalayer/ -type d \( -name '.git' -o -name 'source*' -o -name 'script*' \) -prune -o -type f -wholename '*/conf/layer.conf' -not -wholename '*/meta-skeleton/*' | grep '.*/conf/layer\.conf' | sed 's#/conf/layer.conf##' | sort)
        # Filter for layer available in current bblayers.conf file
        unset LAYERS_SET
        for l in ${LAYERS_LIST}; do
            if ! [[ -z $(grep "${l#$(dirname $BUILDDIR)/}[ '\"]" $BUILDDIR/conf/bblayers.conf) ]]; then
                LAYERS_SET+=(${l})
            fi
        done
        if [ -z "${#LAYERS_SET[@]}" ]; then
            echo "[WARNING] None of the layers from $metalayer are defined in current $(basename $BUILDDIR)/conf/bblayers.conf file."
            echo
            return
        fi
        # Filter images from enabled layers
        unset IMAGE_SET
        for ITEM in ${LAYERS_SET[@]}; do
            for i in ${LIST}; do
                if [ "${i#$ITEM/}" != "$i" ]; then
                    IMAGE_SET+=(${i})
                fi
            done
        done
        if [ -z "${#IMAGE_SET[@]}" ]; then
            echo "[WARNING] From the layers of $metalayer enable in your $(basename $BUILDDIR)/conf/bblayers.conf file, there is no image available for build."
            echo
            return
        fi
        LIST="${IMAGE_SET[@]}"
    fi

    echo ""
    echo "==========================================================================="
    echo "Available images for '$metalayer' layer are:"
    echo ""
    _vtoe_list_images_descr "$LIST" "$err"
    echo ""
}

######################################################
# Get distro code name to udpate DL and SSTATE path in site.conf
#
get_distrocodename()
{
    #get distro related folder from layer root
    local distro_dir=$(find ${ROOTOE}/$_META_LAYER_ROOT/ -type d \( -path '.git' -o -path '.repo' -o -path 'build*' -o -path 'source*' -o -path 'script*' \) -prune -o -type d -wholename '*/conf/distro')
    if [ -z "$distro_dir" ]; then
        echo ""
        echo "[WARNING] No */conf/distro folder available in $_META_LAYER_ROOT layer"
        echo "[WARNING] Init ST_OE_DISTRO_CODENAME to NONE"
        echo ""
        _DISTRO_CODENAME="NONE"
        return
    fi

    #gather DISTRO_CODENAME values
    _DISTRO_CODENAME=$(grep --exclude='.*' -Rs '^DISTRO_CODENAME' $distro_dir | sed 's|.*DISTRO_CODENAME[ \t]*=[ \t]*"\(.*\)"[ \t]*$|\1|g'| sort -u)

    #make sure that DISTRO_CODENAME is defined and has only one value
    if [ -z "$_DISTRO_CODENAME" ] ; then
        echo ""
        echo "[ERROR] No DISTRO_CODENAME definition found in folder:"
        echo "$distro_dir"
        echo ""
        return 1
    elif [ "$(echo $_DISTRO_CODENAME | wc -w)" -gt 1 ]; then
        echo ""
        echo "[ERROR] Found different DISTRO_CODENAME definition in $_META_LAYER_ROOT layer. Please cleanup/clarify:"
        echo "$_DISTRO_CODENAME"
        echo ""
        return 1
    fi
}

######################################################
# Apply configuration to local.conf file
#
conf_localconf()
{
    if [ -z "$(grep '^MACHINE =' conf/local.conf)" ]; then
        # Apply selected MACHINE in local conf file
        sed -e 's/^\(MACHINE.*\)$/#\1\nMACHINE = "'"$MACHINE"'"/' -i conf/local.conf
    else
        echo "[WARNING] MACHINE is already set in local.conf. Nothing done..."
    fi
    if [ -z "$(grep '^DISTRO =' conf/local.conf)" ]; then
        # Apply selected DISTRO in local conf file
        sed -e 's/^\(DISTRO.*\)$/#\1\nDISTRO = "'"$DISTRO"'"/' -i conf/local.conf
    else
        echo "[WARNING] DISTRO is already set in local.conf. Nothing done..."
    fi
}

######################################################
# Copy 'conf-notes.txt' from available template files to BUILDDIR
#
conf_notes()
{
    if [ -f ${_TEMPLATECONF}/conf-notes.txt ]; then
        cp ${_TEMPLATECONF}/conf-notes.txt conf
    elif [ -z "${_TEMPLATECONF}" ]; then
        # '_TEMPLATECONF' is empty when dealing with 'nodistro' use case
        # Copy then the default OE 'conf-notes.txt' file
        if [ -f ${ROOTOE}/$_BUILDSYSTEM/meta/conf/conf-notes.txt ]; then
            cp ${ROOTOE}/$_BUILDSYSTEM/meta/conf/conf-notes.txt conf
        fi
    fi
}

######################################################
# get folder to use for template.conf files
#
get_templateconf()
{
    if [ "$DISTRO" = "nodistro" ]; then
        #for nodistro choice use default sample files from openembedded-core
        echo ""
        echo "[WARNING] Using default openembedded template configuration files for '$DISTRO' setting."
        echo ""
        _TEMPLATECONF=""
    else
        #extract bsp path
        local distro_path=$(find ${ROOTOE}/$_META_LAYER_ROOT/ -type d \( -name '.git' -o -name '.repo' -o -name 'build*' -o -name 'source*' -o -name 'script*' \) -prune -o -type f -name "$DISTRO.conf" | grep "/distro/$DISTRO.conf" | sed 's|\(.*\)/conf/distro/\(.*\)|\1|')
        if [ -z "$distro_path" ]; then
            echo ""
            echo "[ERROR] No '$DISTRO.conf' file available in $_META_LAYER_ROOT"
            echo ""
            return 1
        fi
        #make sure path is single
        if [ "$(echo $distro_path | wc -w)" -gt 1 ]; then
            echo ""
            echo "[ERROR] Found multiple '$DISTRO.conf' file in $_META_LAYER_ROOT"
            echo ""
            return 1
        fi
        #configure _TEMPLATECONF path
        if [ -f $distro_path/conf/template/bblayers.conf.sample ]; then
            _TEMPLATECONF=$distro_path/conf/template
        else
            echo "[WARNING] default template configuration files not found in $_META_LAYER_ROOT layer: using default ones from openembedded"
            _TEMPLATECONF=""
        fi
    fi
}

######################################################
# Check last modified time for bblayers.conf from list of builddir provided and
# provide builddir that contains the latest bblayers.conf modified
#
default_config_get() {
    local list=$1
    TmpFile=$(mktemp)
    for l in $list
    do
        [ -f ${ROOTOE}/$l/conf/bblayers.conf ] && echo $(stat -c %Y ${ROOTOE}/$l/conf/bblayers.conf) $l >> $TmpFile
    done
    cat $TmpFile | sort -r | head -n1 | cut -d' ' -f2
    rm -f $TmpFile
}

######################################################
# Init timestamp on bblayers.conf for builddir set
#
_default_config_set() {
    [ -f $BUILDDIR/conf/bblayers.conf ] && touch $BUILDDIR/conf/bblayers.conf
}


######################################################
# Format DISTRO and MACHINE list from configuration file list applying the specific _FORMAT_PATTERN:
#  <CONFIG-NAME>|<_FORMAT_PATTERN>|<CONFIG-DESCRIPTION>
#
_choice_formated_configs() {
    local choices=$(find ${ROOTOE}/$_META_LAYER_ROOT/ -type d \( -name '.git' -o -name '.repo' -o -name 'build*' -o -name 'source*' -o -name 'script*' \) -prune -o -type f -wholename "*/conf/$1/*.conf" 2>/dev/null | grep ".*/conf/$1/.*\.conf" | sort | uniq)

    for ITEM in $choices; do
        if [ -z "$(grep '#@DESCRIPTION' $ITEM)" ]; then
            echo $ITEM | sed 's|^'"${ROOTOE}/$_META_LAYER_ROOT"'/\(.*\)/conf/'"$1"'/\(.*\)\.conf|\2'"${_FORMAT_PATTERN}"'[ERROR] No Description available (\1)|'
        else
            grep -H "#@DESCRIPTION" $ITEM | sed 's|^.*/\(.*\)\.conf:#@DESCRIPTION:[ \t]*\(.*$\)|\1'"${_FORMAT_PATTERN}"'\2|'
        fi
    done
    unset ITEM
}

######################################################
# Format BUILD_DIR list from applying the specific _FORMAT_PATTERN:
#  <DIR-NAME>|<_FORMAT_PATTERN>|<DISTRO-value and MACHINE-value>
#
choice_formated_dirs() {
    TmpFile=$(mktemp)
    for dir in $1
    do
        echo "${dir}${_FORMAT_PATTERN}DISTRO is '$(oe_config_read ${ROOTOE}/$dir DISTRO)' and MACHINE is '$(oe_config_read ${ROOTOE}/$dir MACHINE)'" >> $TmpFile
    done
    # Add new build config option
    echo "NEW${_FORMAT_PATTERN}*** SET NEW DISTRO AND MACHINE BUILD CONFIG ***" >> $TmpFile
    echo "$(cat $TmpFile)"
    rm -f $TmpFile
}

######################################################
# Make selection for <TARGET> requested from <LISTING> provided using shell or ui choice
#
_choice_shell() {
    local choice_name=$1
    local choice_list=$2
    local default_choice=$3
    #format list to have display aligned on column with '-' separation between name and description
    local options=$(echo "${choice_list}" | column -t -s "£")
    #change separator from 'space' to 'end of line' for 'select' command
    old_IFS=$IFS
    IFS=$'\n'
    local i=1
    unset LAUNCH_MENU_CHOICES
    for opt in $options; do
        printf "%3.3s. %s\n" $i $opt
        LAUNCH_MENU_CHOICES=(${LAUNCH_MENU_CHOICES[@]} $opt)
        i=$(($i+1))
    done
    IFS=$old_IFS
    # Item selection from list
    local selection=""
    while [ -z "$selection" ]; do
        echo -n "Which one would you like? [${default_choice}] "
        read -r -t $READTIMEOUT answer
        # Check that user has answered before timeout, else break
        [ "$?" -gt "128" ] && break

        if [ -z "$answer" ] && [ -n "$default_choice" ]; then
            selection=${default_choice}
            break
        fi
        if [[ $answer =~ ^[0-9]+$ ]]; then
            if [ $answer -gt 0 ] && [ $answer -le ${#LAUNCH_MENU_CHOICES[@]} ]; then
                selection=${LAUNCH_MENU_CHOICES[$(($answer-1))]}
                break
            fi
        fi
        echo "Invalid choice: $answer"
        echo "Please use numeric value between '1' and '$(echo "$options" | wc -l)'"
    done
    eval ${choice_name}=$(echo $selection | cut -d' ' -f1)
}

_choice_ui() {
    local choice_name=$1
    local choice_list=$2
    local default_choice=$3
    local target=""
    local _help_display=true
    #change separator from 'space' to 'end of line' to get full line
    old_IFS=$IFS
    IFS=$'\n'
    for ITEM in ${choice_list}; do
        local target_name=$(echo $ITEM | awk -F''"${_FORMAT_PATTERN}"'' '{print $1}')
        local target_desc=$(echo $ITEM | awk -F''"${_FORMAT_PATTERN}"'' '{print $NF}')
        local target_stat="OFF"
        # Set selection ON for default_choice
        [ "$target_name" = "$default_choice" ] && target_stat="ON"
        TARGETTABLE+=($target_name "$target_desc" $target_stat)
    done
    IFS=$old_IFS
    while [ -z "$target" ]
    do
        target=$(${UI_CMD} --title "Available ${choice_name}" --radiolist "Please choose a ${choice_name}" 0 0 0 "${TARGETTABLE[@]}" 3>&1 1>&2 2>&3)
        test -z $target || break
        if $_help_display; then
            #display dialog box to provide some help to user
            ${UI_CMD} --title "How to select ${choice_name}" --msgbox "Keyboard usage:\n\n'ENTER' to validate\n'SPACE' to select\n 'TAB'  to navigate" 0 0
            _help_display=false
        else
            break
        fi
    done
    unset TARGETTABLE
    unset ITEM
    eval ${choice_name}=$target
}

choice() {
    local __TARGET=$1
    local choices="$2"
    local default_choice=$3

    echo
    echo "[$__TARGET configuration]"
    if [[ $(echo "$choices" | wc -l) -eq 1 ]]; then
        eval $__TARGET=$(echo $choices | awk -F''"${_FORMAT_PATTERN}"'' '{print $1}')
    else
        if [ -z "$DISPLAY" ] || [ -z "${UI_CMD}" ]; then
            _choice_shell $__TARGET "$choices" $default_choice
        else
            _choice_ui $__TARGET "$choices" $default_choice
        fi
    fi
    echo "$__TARGET: $(eval echo \$$__TARGET)"
    echo ""
}

######################################################
# Check if current HOST is one of the Linux Distrib Release supported
#
linux_host_check() {
    # Set lsb-release file
    local lsb_release_file=/etc/lsb-release
    # Init host info
    local host_distrib="Not checked"
    local host_release="Not checked"
    if [ -f $lsb_release_file ]; then
        # Check for host Linux Distrib
        host_distrib=$(grep '^DISTRIB_ID=' $lsb_release_file | cut -d'=' -f2)
        # Check for host Linux Distrib Release
        host_release=$(grep '^DISTRIB_RELEASE=' $lsb_release_file | cut -d'=' -f2)
    fi
    # Display host checking info
    echo "Linux Distrib: $host_distrib"
    echo "Linux Release: $host_release"
}

######################################################
# Since this script is sourced, be careful not to pollute
# caller's environment with temp variables.
#
oe_unset() {
    unset BUILD_DIR
    unset DISTRO
    unset DISTRO_INIT
    unset MACHINE
    unset MACHINE_INIT
    unset _FORCE_RECONF
    unset _ENABLE_UI
    unset _INIT
    unset _BUILDSYSTEM
    unset _QUIET
    unset UI_CMD
    unset _TEMPLATECONF
    unset _DISTRO_CODENAME
    # Clean env from unwanted functions
    unset -f choice
    unset -f _choice_ui
    unset -f _choice_shell
    unset -f verify_env
    unset -f _choice_formated_configs
    unset -f get_templateconf
    unset -f conf_localconf
    unset -f conf_notes
    unset -f set_env_init
    unset -f default_config_get
    unset -f _default_config_set
    unset -f get_distrocodename
    # Delete File
    [ -f ${LISTDIR} ] && rm -f ${LISTDIR}
}

# Check if script is sourced as expected
#
verify_env() {
    local  __resultvar=$1
    if [ "$0" = "$BASH_SOURCE" ]; then
        echo "Error: You must source the script"
        if [[ "$__resultvar" ]]; then
            eval $__resultvar="ERROR_SOURCE"
        fi
        return
    fi
    # check that we are not root!
    if [ "$(whoami)" = "root" ]; then
        echo -e "\n[ERROR] do not use the BSP as root. Exiting..."
        if [[ "$__resultvar" ]]; then
            eval $__resultvar="ERROR_ROOT"
        fi
        return
    fi
    # check that we are where we think we are!
    local oe_tmp_pwd=$(pwd)
    # need to take care of build system available
    if [[ ! -d $oe_tmp_pwd/layers/openembedded-core ]] && [[ ! -d $oe_tmp_pwd/layers/poky ]]; then
        echo "PLEASE launch the envsetup script at root tree of your oe sdk"
        echo ""
        local oe_tmp_root=$oe_tmp_pwd
        while [ 1 ];
        do
            oe_tmp_root=$(dirname $oe_tmp_root)
            if [ "$oe_tmp_root" == "/" ]; then
                echo "[WARNING]: you try to launch the script outside oe sdk tree"
                break;
            fi
            if [[ -d $oe_tmp_root/layers/openembedded-core ]] || [[ -d $oe_tmp_root/layers/poky ]]; then
                echo "Normally at this location: $oe_tmp_root"
                break;
            fi
        done
        if [[ "$__resultvar" ]]; then
            eval $__resultvar="ERROR_OE"
        fi
        return
    else
        # Fix build system to use for init: default would be openembedded-core one
        [ -d $oe_tmp_pwd/layers/poky ] && _BUILDSYSTEM=layers/poky
        [ -d $oe_tmp_pwd/layers/openembedded-core ] && _BUILDSYSTEM=layers/openembedded-core
    fi
    if [[ "$__resultvar" ]]; then
        eval $__resultvar="NOERROR"
    fi
}

######################################################
# Main
# --
#

# Setup a signal handler to clear the environement in case of error
trap 'oe_unset' SIGHUP SIGINT SIGQUIT SIGABRT

# Make sure script has been sourced
#
verify_env ret
case $ret in
    ERROR_OE | ERROR_ROOT | ERROR_SOURCE)
        if [ "$0" != "$BASH_SOURCE" ]; then
            return 2
        else
            exit 2
        fi
        ;;
    *)
        ;;
esac

# Init parameters
_ENABLE_UI=${_ENABLE_UI:-1}
_FORCE_RECONF=${_FORCE_RECONF:-0}
_QUIET=${_QUIET:-0}
READTIMEOUT=${READTIMEOUT:-60}
TRIALMAX=${TRIALMAX:-100}

#----------------------------------------------
# parsing options
#
while test $# != 0
do
    case "$1" in
    --help)
        stoe_help
        return 0
        ;;
    --quiet)
        _QUIET=1
        ;;
    --reset)
        _FORCE_RECONF=1
        _INIT=0
        ;;
    --no-ui)
        _ENABLE_UI=0
        ;;
    -*)
        echo "Wrong parameter: $1"
        return 1
        ;;
    *)
        if [ -z "${BUILD_DIR}" ]; then
            # Change buildir directory
            if ! [[ $1 =~ ^build.* ]]; then
                echo "[ERROR] '$1' : please provide BUILD_DIR with 'build' prefix."
                return 1
            fi
            # We want BUILD_DIR without any '/' at the end
            BUILD_DIR=$(echo $1 | sed 's|[/]*$||')
        else
            echo "[ERROR] BUILD_DIR is already defined to '${BUILD_DIR}'. Please clarify if you really want to set it to '$1'"
            return 1
        fi
        ;;
    esac
    shift
done

#----------------------------------------------
# Init env variable
#
set_env_init

#----------------------------------------------
# Check that HOST Linux Distrib is supported
#
linux_host_check

#----------------------------------------------
# Init BUILD_DIR variable
#
if [ -z ${BUILD_DIR} ] && ! [ -z $DISTRO ] && ! [ -z $MACHINE ]; then
    # In case DISTRO and MACHINE are provided use them to init BUILD_DIR
    BUILD_DIR="build-${DISTRO//-}-$MACHINE"
fi

if [ -z ${BUILD_DIR} ]; then
    # Get existing BUILD_DIR list from baseline
    LISTDIR=$(mktemp)
    for l in $(find "${ROOTOE}" -maxdepth 1 -wholename "*/build*"); do
        [ -f "${l}"/conf/local.conf ] && echo "${l#*${ROOTOE}/}" >> "${LISTDIR}"
    done
    # Select any existing BUILD_DIR from list
    if  [ -s "${LISTDIR}" ]; then
        choice BUILD_DIR "$(choice_formated_dirs "$(cat ${LISTDIR} | sort)")" $(default_config_get "$(cat ${LISTDIR} | sort)")
        [ -z "${BUILD_DIR}" ] && { echo "Selection escaped: exiting now..."; oe_unset; return 1; }
        # Check if we need to force or not INIT
        if [ "${BUILD_DIR}" = "NEW" ]; then
            _INIT=1
            # Reset BUILD_DIR for new config choice
            BUILD_DIR=""
        else
            _INIT=0
        fi
    else
        # None previous build dir found so force INIT
        _INIT=1
    fi
else
    # Make sure BUILD_DIR is uniq
    [ "$(echo ${BUILD_DIR} | wc -w)" -eq 1 ] || { echo "[ERROR] Provided BUILD_DIR is not uniq. Please make sure to set only one build dir." ; oe_unset; return 1; }
    # Check if configuration files exist to force or not INIT
    if [ -f ${ROOTOE}/${BUILD_DIR}/conf/bblayers.conf ] && [ -f ${ROOTOE}/${BUILD_DIR}/conf/local.conf ]; then
        _INIT=0
    else
        _INIT=1
    fi
fi

if [ "$_INIT" -eq 1 ]; then
    # Set DISTRO
    if [ -z "$DISTRO" ]; then
        DISTRO_CHOICES=$(_choice_formated_configs distro)
        [ "$?" -eq 1 ] && { echo "$DISTRO_CHOICES"; oe_unset; return 1; }
        # Add nodistro option
        DISTRO_CHOICES=$(echo -e "$DISTRO_CHOICES\nnodistro${_FORMAT_PATTERN}*** DEFAULT OPENEMBEDDED SETTING : DISTRO is not defined ***")
        choice DISTRO "$DISTRO_CHOICES"
        [ -z "$DISTRO" ] && { echo "Selection escaped: exiting now..."; oe_unset; return 1; }
    fi
    # Set MACHINE
    if [ -z "$MACHINE" ]; then
        MACHINE_CHOICES=$(_choice_formated_configs machine)
        [ "$?" -eq 1 ] && { echo "$MACHINE_CHOICES"; oe_unset; return 1; }
        choice MACHINE "$MACHINE_CHOICES"
        [ -z "$MACHINE" ] && { echo "Selection escaped: exiting now..."; oe_unset; return 1; }
    fi

    # Init BUILD_DIR if not yet set
    [ -z "${BUILD_DIR}" ] && BUILD_DIR="build-${DISTRO//-}-$MACHINE"

    # Check if BUILD_DIR already exists to use previous config (i.e. set _INIT to 0)
    if [ -f ${ROOTOE}/${BUILD_DIR}/conf/bblayers.conf ] && [ -f ${ROOTOE}/${BUILD_DIR}/conf/local.conf ]; then
        _INIT=0
    fi

else
    # Get DISTRO and MACHINE from configuration file
    DISTRO_INIT=$(oe_config_read ${ROOTOE}/${BUILD_DIR} DISTRO)
    MACHINE_INIT=$(oe_config_read ${ROOTOE}/${BUILD_DIR} MACHINE)

    # If DISTRO value is not set in conf file, then default to nodistro
    [[ ${DISTRO_INIT} =~ \< ]] && DISTRO_INIT="nodistro"

    # Set DISTRO
    if [ -z "$DISTRO" ]; then
        DISTRO=${DISTRO_INIT}
    elif [ "$DISTRO" != "${DISTRO_INIT}" ]; then
        # User has defined a wrong DISTRO for current BUILD_DIR configuration
        echo "[ERROR] DISTRO $DISTRO does not match "${DISTRO_INIT}" already set in ${BUILD_DIR}"
        oe_unset
        return 1
    fi
    # Set MACHINE
    if [ -z "$MACHINE" ]; then
        MACHINE=${MACHINE_INIT}
    elif [ "$MACHINE" != "${MACHINE_INIT}" ]; then
        # User has defined a wrong MACHINE for current BUILD_DIR configuration
        echo "[ERROR] MACHINE $MACHINE does not match "${MACHINE_INIT}" already set in ${BUILD_DIR}"
        oe_unset
        return 1
    fi
fi

#----------------------------------------------
# Init baseline for full INIT if required
#
if [ "$_FORCE_RECONF" -eq 1 ] && [ "$_INIT" -eq 0 ]; then
    echo ""
    echo "[Removing current config from ${ROOTOE}/${BUILD_DIR}/conf]"
    rm -fv ${ROOTOE}/${BUILD_DIR}/conf/*.conf ${ROOTOE}/${BUILD_DIR}/conf/*.txt
    echo ""
    # Force init to generate configuration files
    _INIT=1
fi

#----------------------------------------------
# Standard Openembedded init
#
get_templateconf
[ "$?" -eq 1 ] && { oe_unset; return 1; }
TEMPLATECONF_relative=$( realpath -m --relative-to=${ROOTOE}/$BUILD_DIR/conf $_TEMPLATECONF)
TEMPLATECONF=${TEMPLATECONF_relative} source ${ROOTOE}/$_BUILDSYSTEM/oe-init-build-env ${BUILD_DIR} >> /dev/null

[ "$?" -eq 1 ] && { oe_unset; return 1; }

#----------------------------------------------
# Init DISTRO CODE NAME to use for DL_DIR and SSTATE_DIR path
#
get_distrocodename
[ "$?" -eq 1 ] && { rm -rf $BUILDDIR/conf/*; oe_unset; return 1; }

#----------------------------------------------
# Apply specific configurations
#
if [ "$_INIT" -eq 1 ]; then
    # Configure local.conf with specific settings
    conf_localconf
    # Copy specific 'conf-notes.txt' file from templateconf to BUILDDIR
    conf_notes
fi

#----------------------------------------------
# Display when no quiet mode required
#
if ! [ "$_QUIET" -eq 1 ]; then
    # Display current configs
    stoe_config_summary $BUILDDIR

    # Display available images
    if [ -f $BUILDDIR/conf/conf-notes.txt ]; then
        cat $BUILDDIR/conf/conf-notes.txt
    else
        stoe_list_images ${ROOTOE}/${_META_LAYER_ROOT} NOERR FILTER
        [ "$?" -eq 1 ] && { oe_unset; return 1; }
    fi
    echo ""
    echo "You can now run 'bitbake <image>'"
    echo ""
fi

#----------------------------------------------
# Init timestamp for default builddir choice
#
_default_config_set

#----------------------------------------------
# Clear user's environment from temporary variables
#
oe_unset

# Set default return code
return 0
