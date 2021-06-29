#!/bin/bash

#####################################
# Generic syn and p&r utilities     #
# run-syn-pnr.sh                    #
# University of Tennessee Knoxville #
# John Murray                       #
# 2021                              #
#                                   #
# Rev:           v0.65              #
# Last mofified: 2021/06/09         #
#####################################


# Get parent dir for this script, regardless of where it's called from
set +o posix
if [ -n "$BASH_SOURCE" ] ; then
  SCRIPT_FILE=$BASH_SOURCE
elif [ -n "$ZSH_VERSION" ] ; then
  setopt function_argzero
  SCRIPT_FILE=$0
else
  echo 1>&2 "Unsupported shell. Please use bash or zsh."
  exit 2
fi
export SCRIPT_DIR="$(cd "$(dirname "${SCRIPT_FILE}")" > /dev/null 2>&1 && pwd)"


# Source design list from modified file or template
if [[ -f "${SCRIPT_DIR}/user_designs" ]]; then
  source "${SCRIPT_DIR}/user_designs"
else
  source "${SCRIPT_DIR}/user_designs.template"
fi

# Source config from modified file or template
if [[ -f "${SCRIPT_DIR}/user_cfg" ]] ; then
  source "${SCRIPT_DIR}/user_cfg"
else
  source "${SCRIPT_DIR}/user_cfg.template"
fi


### For now, leave this alone ###
PDK_NAME="cmos10lpe"


# Pure-logic or clock based
if [[ -z "${DC_CLK_NETS}" ]] ; then
  export DES_HAS_CLK="0"
else
  export DES_HAS_CLK="1"
fi


### Directories and files
CWD="${SCRIPT_DIR}"
export USER_SRCS_DIR="${CWD}/srcs"

CORE_DIR="${CWD}/core"
CFG_DIR="${CORE_DIR}/cfg"
BASE_SRCS_DIR="${CORE_DIR}/base-srcs"
TEMPLATES_DIR="${CORE_DIR}/templates"

WORK_DIR="${SCRIPT_DIR}/work"

GEN_DIR="${CWD}/generated"
GEN_OUTPUT_DIR="${GEN_DIR}/output"
GEN_SCRIPT_DIR="${GEN_DIR}/scripts"
GEN_LOG_DIR="${GEN_DIR}/logs"

DCSCRIPT_TEMPLATE="${TEMPLATES_DIR}/dc-generic.tcl"
DCSCRIPT_PREFIX="dc-run-gen"

IVSCRIPT_TEMPLATE="${TEMPLATES_DIR}/iv-generic.tcl"
IVSCRIPT_PREFIX="iv-run-gen"

MMCSCRIPT_TEMPLATE="${TEMPLATES_DIR}/mmc-generic.mmc"
MMCSCRIPT_PREFIX="mmc-run-gen"


# Only source toolsenv if its actually necessary
if [[ "${RUN_DC}" -eq "1" || "${RUN_IV}" -eq "1" ]] ; then
  # Source "toolsenv"
  source "${HOME}/cadence/ravens/${PDK_NAME}/toolsenv"
fi


# Unused at the moment
# print output if verbose is defined or a "1" is passed as the second argument
verbose_print()
{
  if [[ "${VERBOSE}" -eq "1" || "$2" -eq "1" ]] ; then
    echo -e "$1"
  fi
}


# Clean a lot of stuff, probably more than desired in some cases.
if [[ "${CLEAN_GEN}" -eq "1" ]] ; then
  # ***Completely*** delete ${GEN_DIR}
  #rm -rf "${GEN_DIR}"
  # Clean out any extraneous files in WORK_DIR
  sh "${WORK_DIR}/cleanup.sh"
  #rm -f "${WORK_DIR}/"*.v "${WORK_DIR}/"*.gds "${WORK_DIR}/"*.mmc
fi


# Make necessary directories
mkdir -p "${GEN_OUTPUT_DIR}" "${GEN_LOG_DIR}" "${WORK_DIR}"


for DESIGN in ${DESIGNS_TO_RUN} ; do
  # make directories for ${DESIGN}'s generated files
  mkdir -p "${GEN_SCRIPT_DIR}/${DESIGN}" "${GEN_OUTPUT_DIR}/${DESIGN}" "${GEN_LOG_DIR}/${DESIGN}"

  # paths specific for ${DESIGN}
  export DES_GEN_DIR="${GEN_OUTPUT_DIR}/${DESIGN}"
  export DES_SCR_DIR="${GEN_SCRIPT_DIR}/${DESIGN}"
  export DES_LOG_DIR="${GEN_LOG_DIR}/${DESIGN}"
  DCSCRIPT_RUN="${DCSCRIPT_PREFIX}-${DESIGN}.tcl"
  MMCSCRIPT_RUN="${MMCSCRIPT_PREFIX}-${DESIGN}.mmc"
  IVSCRIPT_RUN="${IVSCRIPT_PREFIX}-${DESIGN}.tcl"

  ### Design Compiler ###
  if [[ "${PROC_DC}" -eq "1" ]] ; then 
    # echo sed -e 's/@TOP_LEVEL_DESIGN@/'"${DESIGN}"'/g'   \\
    # echo     -e 's#@PWD_PATH@#'"${CWD}"'#g'              \\
    # echo     -e 's#@DC_CFG_DIR@#'"${CFG_DIR}/dc"'#g'     \\
    # echo     -e 's#@DES_GEN_DIR@#'"${DES_GEN_DIR}"'#g'   \\
    # echo        "${DCSCRIPT_TEMPLATE}" > "${DES_SCR_DIR}/${DCSCRIPT_RUN}"
    verbose_print "Processing DC template script"
    sed -e 's/@TOP_LEVEL_DESIGN@/'"${DESIGN}"'/g'        \
        -e 's#@PWD_PATH@#'"${CWD}"'#g'                   \
        -e 's#@DC_CFG_DIR@#'"${CFG_DIR}/dc"'#g'          \
        -e 's#@DES_GEN_DIR@#'"${DES_GEN_DIR}"'#g'        \
           "${DCSCRIPT_TEMPLATE}" > "${DES_SCR_DIR}/${DCSCRIPT_RUN}"
    if [[ "${DC_QUIT}" -eq "0" ]] ; then
      sed -i 's/quit$/# quit/g' "${DES_SCR_DIR}/${DCSCRIPT_RUN}"
    fi
  fi
  if [[ "${RUN_DC}" -eq "1" ]] ; then
    cd "${WORK_DIR}"
    dc_shell-xg-t -f "${DES_SCR_DIR}/${DCSCRIPT_PREFIX}-${DESIGN}.tcl"
    mv "command.log" "${DES_LOG_DIR}/dc-command-${DESIGN}.log"
  fi


  ### Innovus ###
  if [[ "${PROC_IV}" -eq "1" ]] ; then 
    verbose_print "Processing MMC template"
    sed -e 's/@TOP_LEVEL_DESIGN@/'"${DESIGN}"'/g'                         \
        -e 's#@PWD_PATH@#'"${CWD}"'#g'                                    \
        -e 's#@IV_CFG_DIR@#'"${CFG_DIR}/iv"'#g'                           \
        -e 's#@DES_GEN_DIR@#'"${DES_GEN_DIR}"'#g'                         \
           "${MMCSCRIPT_TEMPLATE}" > "${DES_SCR_DIR}/${MMCSCRIPT_RUN}"
    verbose_print "Processing IV script template"
    sed -e 's/@TOP_LEVEL_DESIGN@/'"${DESIGN}"'/g'                         \
        -e 's#@PWD_PATH@#'"${CWD}"'#g'                                    \
        -e 's#@IV_CFG_DIR@#'"${CFG_DIR}/iv"'#g'                           \
        -e 's#@DES_GEN_DIR@#'"${DES_GEN_DIR}"'#g'                         \
        -e 's#@DESIGN_MMC_FILE@#'"${DES_SCR_DIR}/${MMCSCRIPT_RUN}"'#g'    \
        -e 's#@IV_DES_ASPECT@#'"${IV_DES_ASPECT}"'#g'                     \
        -e 's#@IV_DES_DENSITY@#'"${IV_DES_DENSITY}"'#g'                   \
        -e 's#@IV_DES_MARGIN_LEFT@#'"${IV_DES_MARGIN_LEFT}"'#g'           \
        -e 's#@IV_DES_MARGIN_BOT@#'"${IV_DES_MARGIN_BOT}"'#g'             \
        -e 's#@IV_DES_MARGIN_RIGHT@#'"${IV_DES_MARGIN_RIGHT}"'#g'         \
        -e 's#@IV_DES_MARGIN_TOP@#'"${IV_DES_MARGIN_TOP}"'#g'             \
        -e 's#@IV_PWR_NETS@#'"${IV_PWR_NETS}"'#g'                         \
        -e 's#@IV_PWR_CORE@#'"${IV_PWR_CORE}"'#g'                         \
        -e 's#@IV_GND_NETS@#'"${IV_GND_NETS}"'#g'                         \
        -e 's#@IV_GND_CORE@#'"${IV_GND_CORE}"'#g'                         \
        -e 's#@IV_HORZ_RING_LAYER@#'"${IV_HORZ_RING_LAYER}"'#g'           \
        -e 's#@IV_VERT_RING_LAYER@#'"${IV_VERT_RING_LAYER}"'#g'           \
        -e 's#@IV_RING_BOT_VIA_LAYER@#'"${IV_RING_BOT_VIA_LAYER}"'#g'     \
        -e 's#@IV_RING_TOP_VIA_LAYER@#'"${IV_RING_TOP_VIA_LAYER}"'#g'     \
        -e 's#@IV_HORZ_RING_WIDTH@#'"${IV_HORZ_RING_WIDTH}"'#g'           \
        -e 's#@IV_VERT_RING_WIDTH@#'"${IV_VERT_RING_WIDTH}"'#g'           \
        -e 's#@IV_HORZ_RING_SPACE@#'"${IV_HORZ_RING_SPACE}"'#g'           \
        -e 's#@IV_VERT_RING_SPACE@#'"${IV_VERT_RING_SPACE}"'#g'           \
        -e 's#@IV_HORZ_RING_OFFSET@#'"${IV_HORZ_RING_OFFSET}"'#g'         \
        -e 's#@IV_VERT_RING_OFFSET@#'"${IV_VERT_RING_OFFSET}"'#g'         \
        -e 's#@IV_STRIPE_LAYER@#'"${IV_STRIPE_LAYER}"'#g'                 \
        -e 's#@IV_STRIPE_BOT_VIA_LAYER@#'"${IV_STRIPE_BOT_VIA_LAYER}"'#g' \
        -e 's#@IV_STRIPE_TOP_VIA_LAYER@#'"${IV_STRIPE_TOP_VIA_LAYER}"'#g' \
        -e 's#@IV_STRIPE_OFFSET@#'"${IV_STRIPE_OFFSET}"'#g'               \
        -e 's#@IV_STRIPE_DIST@#'"${IV_STRIPE_DIST}"'#g'                   \
        -e 's#@IV_STRIPE_WIDTH@#'"${IV_STRIPE_WIDTH}"'#g'                 \
        -e 's#@IV_STRIPE_SPACE@#'"${IV_STRIPE_SPACE}"'#g'                 \
        -e 's#@IV_TOP_NR_LAYER@#'"${IV_TOP_NR_LAYER}"'#g'                 \
        -e 's#@IV_BOT_NR_LAYER@#'"${IV_BOT_NR_LAYER}"'#g'                 \
        -e 's#@IV_CTS_MAX_TRAN_TIME@#'"${IV_CTS_MAX_TRAN_TIME}"'#g'       \
        -e 's#@IV_CTS_SKEW_TARGET@#'"${IV_CTS_SKEW_TARGET}"'#g'           \
           "${IVSCRIPT_TEMPLATE}" > "${DES_SCR_DIR}/${IVSCRIPT_RUN}"
    if [[ "${IV_QUIT}" -eq "0" || "${IV_USE_GUI}" -eq "1" ]] ; then
      sed -i 's/exit$/# exit/g' "${DES_SCR_DIR}/${IVSCRIPT_RUN}"
    fi
  fi
  if [[ "${RUN_IV}" -eq "1" ]] ; then
    if [[ "${IV_SKIP_CTS}" -ne "0" ]] ; then
      export DES_HAS_CLK=0
    fi
    cd "${WORK_DIR}"
    IV_FILES="${DES_SCR_DIR}/${IVSCRIPT_RUN}"
    if [[ "${IV_USE_MGCRT}" -eq "1" ]] ; then
      IV_FILES="${MGC_HOME}/lib/cal_enc.tcl ${IV_FILES}"
    fi
    if [[ "${IV_USE_GUI}" -eq "1" ]] ; then
      innovus -files "${IV_FILES}" -cds_lib_file "${HOME}/cadence/ravens/${PDK_NAME}/cds.lib" -win
    else 
      innovus -files "${IV_FILES}" -cds_lib_file "${HOME}/cadence/ravens/${PDK_NAME}/cds.lib"
    fi
    mv "${WORK_DIR}/innovus.cmd"  "${DES_LOG_DIR}/innovus-${DESIGN}.cmd"
    mv "${WORK_DIR}/innovus.log"  "${DES_LOG_DIR}/innovus-${DESIGN}.log"
    mv "${WORK_DIR}/innovus.logv" "${DES_LOG_DIR}/innovus-${DESIGN}.logv"
  fi

done

