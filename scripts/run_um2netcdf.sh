#!/bin/bash

# a post processing script to convert UM output files to netcdf

source  /etc/profile.d/modules.sh

module purge
module use ~access/modules
module unload python
module load pythonlib/umfile_utils/access_cm2
shopt -s extglob

for INFILE in archive/*/atmosphere/*a.p{e,a}+([0-z])
do
    OUTFILE="${INFILE}.nc"
    if test -f "$OUTFILE" 
    then
        echo "skipping {$INFILE}"
    else
        echo "converting {$INFILE}"
        python -m um2netcdf4 $INFILE $OUTFILE
    fi
    
done