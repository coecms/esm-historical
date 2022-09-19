#!/bin/bash
set -a 

# Additional NCI information:
# OUTPUT_LOC defines directory for all generated data (CMORISED files & logs)
#
OUTPUT_LOC=/scratch/$PROJECT/$USER/APP4_output 
PROJECT=$PROJECT                             # NCI project to charge compute; $PROJECT = your default project
QUEUE=hugemem                                # NCI queue to use; hugemem is recommended
MEM_PER_CPU=24                               # memory (GB) per CPU (recommended: 24 for daily/monthly; 48 for subdaily) 
ADDPROJS=( p66 )
#
#
#
#
#
#

# Set up environment
MODE=custom
APP_DIR=/g/data/tm70/kr4383/APP4
HISTORY_DATA=$DATA_LOC/$EXP_TO_PROCESS/history
source /g/data/tm70/kr4383/APP4/subroutines/setup_env.sh
# Cleanup output_files
/g/data/tm70/kr4383/APP4/subroutines/cleanup.sh $OUT_DIR

# Create json file which contains metadata info
python /g/data/tm70/kr4383/APP4/subroutines/custom_json_editor.py

# Create variable maps
python /g/data/tm70/kr4383/APP4/subroutines/dreq_mapping.py --multi

# Create database
python /g/data/tm70/kr4383/APP4/subroutines/database_manager.py


################################################################
# CREATE JOB
################################################################
echo -e '\ncreating job...'

for addproj in ${ADDPROJS[@]}; do
  addstore="${addstore}+scratch/${addproj}+gdata/${addproj}"
done
#
NUM_ROWS=$( cat $OUT_DIR/database_count.txt )
if (($NUM_ROWS <= 24)); then
  NUM_CPUS=$NUM_ROWS
else
  NUM_CPUS=24
fi
NUM_MEM=$(echo "${NUM_CPUS} * ${MEM_PER_CPU}" | bc)
if ((${NUM_MEM} >= 1470)); then
  NUM_MEM=1470
fi
#
#NUM_CPUS=48
#NUM_MEM=1470
echo "number of files to create: ${NUM_ROWS}"
echo "number of cpus to to be used: ${NUM_CPUS}"
echo "total amount of memory to be used: ${NUM_MEM}Gb"

JOB_OUTPUT=./job_output.OU

cat << EOF > $APP_JOB
#!/bin/bash
#PBS -P $PROJECT
#PBS -q $QUEUE
#PBS -l storage=scratch/$PROJECT+gdata/$PROJECT+gdata/hh5+gdata/access${addstore}
#PBS -l ncpus=${NUM_CPUS},walltime=0:15:00,mem=${NUM_MEM}Gb,wd
#PBS -j oe
#PBS -o ${JOB_OUTPUT}
#PBS -e ${JOB_OUTPUT}
#PBS -N custom_app4_${EXP_TO_PROCESS}
module purge
set -a
# pre
EXP_TO_PROCESS=${EXP_TO_PROCESS}
OUTPUT_LOC=$OUTPUT_LOC
MODE=$MODE
CONTACT=$CONTACT
CDAT_ANONYMOUS_LOG=no
APP_DIR=/g/data/tm70/kr4383/APP4
source /g/data/tm70/kr4383/APP4/subroutines/setup_env.sh
# main
python /g/data/tm70/kr4383/APP4/subroutines/app_wrapper.py
# post
python ${OUT_DIR}/database_updater.py
sort ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_success.csv \
    > ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_success_sorted.csv
mv ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_success_sorted.csv \
    ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_success.csv
sort ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_failed.csv \
    > ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_failed_sorted.csv 2>/dev/null
mv ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_failed_sorted.csv \
    ${SUCCESS_LISTS}/${EXP_TO_PROCESS}_failed.csv
echo "APP completed for exp ${EXP_TO_PROCESS}."
EOF

/bin/chmod 775 ${APP_JOB}
echo "app job script: ${APP_JOB}"
qsub ${APP_JOB}
