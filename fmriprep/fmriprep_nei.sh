#! /bin/bash

## the following script can be used to run analyzePRF on the HPC cluster
## using the command 'sbatch runPrincePRF.sh'

## First we set up some SBATCH directives. Note that these are hard values
## if you go beyond your job will be killed by SLURM

#SBATCH --job-name=fmriprep
#SBATCH -a 0  # run this script as 2 jobs with SLURM_ARRAY_TASK_ID = 0 and 1. Add more numbers for more jobs!
#BATCH --nodes=1 # nodes per job
#SBATCH --cpus-per-task=48 #~2 days to run PRFs
#SBATCH --mem=64g # More memory you request the less priority you get
#SBATCH --time=10:00:00 # Max request to be safe...
#SBATCH --mail-type=END #email me when it crashes or better, ends


# load the freesurfer module
module load freesurfer/6.0.0
source /share/apps/freesurfer/6.0.0/SetUpFreeSurfer.sh

fsLicense=${FREESURFER_HOME}/license.txt

DATA_DIR="/scratch/projects/corevisiongrantnei/"    
SINGULARITY_PULLFOLDER="/scratch/projects/corevisiongrantnei/Singularity/"
STUDY_DIR="$DATA_DIR/NEI_BIDS"

SUBJECT_ID=$1


# Set up some derived variables that we'll use later:
fsLicenseBasename=$(basename $fsLicense)
fsLicenseFolder=${fsLicense%$fsLicenseBasename}

scp  ${SINGULARITY_PULLFOLDER}/fmriprep_24.0.0.sif  ${SINGULARITY_PULLFOLDER}/fmriprep_24.0.0_$1.sif

###   fMRIPrep:   ###
# fmriprep folder contains the reports and results of 'fmriprep'
singularity run  \
           -B $STUDY_DIR:/data \
           -B ${fsLicenseFolder}:/FSLicenseFolder:ro \
           ${SINGULARITY_PULLFOLDER}/fmriprep_24.0.0_$1.sif \
               /data \
               /data/derivatives \
               participant \
               --fs-license-file /FSLicenseFolder/$fsLicenseBasename \
               --output-space func T1w:res-native fsnative fsaverage MNI152NLin6Asym:res-native \
               --participant_label ${SUBJECT_ID} \
               --skip_bids_validation \
               --omp-nthreads 32 \
               --mem_mb 64000 \
               --output-layout legacy 


rm ${SINGULARITY_PULLFOLDER}/fmriprep_24.0.0_$1.sif
rm -rf ${STUDY_DIR}/derivatives/fmriprep_code/work/fmriprep_24_0_wf/sub_${SUBJECT_ID}_wf
exit 0
EOT
