#!/bin/bash
source  /etc/profile.d/modules.sh

set -a

module purge
module load pbs
module use /g/data/hh5/public/modules
module use ~access/modules
module load cdo
module load nco
module load pythonlib/um2netcdf4/2.0
module load conda/analysis3

# set the environment variables for ACCESS-Archiver
loc_exp=${PWD##*/}
subdaily=false
access_version=esmpayu
arch_dir=/g/data/$PROJECT/$USER/archive/access-esm
base_dir=/scratch/$PROJECT/$USER/access-esm/archive
comp_proj=$PROJECT
here=/g/data/tm70/kr4383/ACCESS-Archiver 

plev8=false
zonal=false
convert_unknown=false
ncexists=false
arch_grp=$PROJECT
UMDIR=/projects/access/umdir

# setup dircetories
mkdir -p $here/tmp/$loc_exp
rm -f $here/tmp/$loc_exp/*
mkdir -p $arch_dir/$loc_exp/{history/atm/netCDF,restart/atm}

# run access archiving scripts
${here}/subroutines/find_files_payu.sh # create file list
python -W ignore $here/subroutines/run_um2nc.py # convert UM files to netcdf
$here/subroutines/cp_hist.sh # copy over history
$here/subroutines/cp_rest_payu.sh # copy over output files
$here/subroutines/mppnccomb_check.sh # combine ocean output files