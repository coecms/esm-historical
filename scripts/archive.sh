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
/g/data/tm70/kr4383/ACCESS-Archiver/ACCESS_Archiver.sh