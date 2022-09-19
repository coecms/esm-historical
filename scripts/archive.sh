#!/bin/bash
source  /etc/profile.d/modules.sh

set -a

module purge
module use /g/data/hh5/public/modules
module use ~access/modules
module load pbs
module load parallel
module load pythonlib/um2netcdf4/2.0

# set the environment variables for ACCESS-Archiver
loc_exp=${PWD##*/}
subdaily=false
access_version=esmpayu
arch_dir=/g/data/$PROJECT/$USER/archive/access-esm

base_dir=$(dirname $(readlink archive))
comp_proj=$PROJECT
here=/g/data/tm70/kr4383/ACCESS-Archiver 

plev8=false
zonal=false
convert_unknown=false
ncexists=false
arch_grp=$PROJECT
UMDIR=~access/umdir

# # setup dircetories
rm -rf $here/tmp/$loc_exp
mkdir -p $here/tmp/$loc_exp
mkdir -p $arch_dir/$loc_exp/{history/atm/netCDF,restart/atm}

# run access archiving scripts
${here}/subroutines/find_files_payu.sh # create file list
python -s -W ignore $here/subroutines/run_um2nc.py # convert UM files to netcdf
$here/subroutines/cp_hist_payu.sh # copy over history
$here/subroutines/cp_rest_payu.sh # copy over output files
$here/subroutines/mppnccomb_check.sh # combine ocean output files

#
########################################
#
# set environment variables for APP4
DATA_LOC=/g/data/tm70/kr4383/archive/access-esm/
EXP_TO_PROCESS=esm-historical                # local name of experiment
VERSION=ESM                                  # select one of: [CM2, ESM, OM2[-025]]
START_YEAR=1850                              # internal year to begin CMORisation
END_YEAR=1850                                # internal year to end CMORisation (inclusive)
REFERENCE_YEAR=1850                          # reference date for time units (set as 'default' to use START_YEAR)
CONTACT=access_csiro@csiro.au                # please insert your contact email
# Please provide a short description of the experiment. For those created from the p73 archive, it's ok to just link to the Archive Wiki.
EXP_DESCRIPTION="Pacemaker, Topical Atlantic, HadISST obs. see: https://confluence.csiro.au/display/ACCESS/ACCESS+Model+Output+Archive+%28p73%29+Wiki"

# Standard experiment details:
#
experiment_id=hist-control                   # standard experiment name (e.g. piControl)
activity_id=PacemakerMIP                     # activity/MIP name (e.g. CMIP)
realization_index=1                          # "r1"[i1p1f1] (e.g. 1)
initialization_index=1                       # [r1]"i1"[p1f1] (e.g. 1)
physics_index=1                              # [r1i1]"p1"[f1] (e.g. 1)
forcing_index=1                              # [r1i1p1]"f1" (e.g. 1)
source_type=AOGCM                            # see input_files/custom_mode_cmor-tables/Tables/CMIP6_CV.json
branch_time_in_child=0D0                     # specifies the difference between the time units base and the first internal year (e.g. 365D0)

# Parent experiment details:
# if parent=false, all parent fields are automatically set to "no parent". If true, defined values are used.
#
parent=true 
parent_experiment_id=piControl               # experiment name of the parent (e.g. piControl-spinup)
parent_activity_id=CMIP                      # activity/MIP name of the parent (e.g. CMIP)
parent_time_units="days since 0950-01-01"    # time units of the parent (e.g. "days since 0001-01-01")
branch_time_in_parent=0D0                    # internal time of the parent at which the branching occured (e.g. 0D0)
parent_variant_label=r1i1p1f1                # variable label of the parent (e.g. r1i1p1f1)

# Variables to CMORise: 
# CMIP6 table/variable to process; default is 'all'. Or create a file listing variables to process (VAR_SUBSET[_LIST]).
#
DREQ=default                                 # default=input_files/dreq/cmvme_all_piControl_3_3.csv
TABLE_TO_PROCESS=all                         # CMIP6 table to process. Default is 'all'
VARIABLE_TO_PROCESS=all                      # CMIP6 variable to process. Default is 'all'
SUBDAILY=false                               # subdaily selection options - select one of: [true, false, only]
VAR_SUBSET=false                             # use a sub-set list of variables to process, as defined by 'VAR_SUBSET_LIST'
VAR_SUBSET_LIST=input_files/var_subset_lists/var_subset_ACS.csv

./scripts/run_app4.sh