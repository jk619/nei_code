#! /bin/bash


for sub in $(find /scratch/projects/corevisiongrantnei/NEI_BIDS/ -maxdepth 1 -type d -name 'sub-*' -exec sh -c 'basename {} | sed "s/^sub-//"' \;); do
	
	report=/scratch/projects/corevisiongrantnei/NEI_BIDS/derivatives/fmriprep/sub-$sub.html     
	
	if [ ! -f $report ]; then
		
		rm -rf /scratch/projects/corevisiongrantnei/NEI_BIDS/derivatives/fmriprep/sub-$sub
		var1="/scratch/projects/corevisiongrantnei/NEI_BIDS/derivatives/fmriprep_logs/fmriprep_err_ses_%x-%a_$sub.txt"
		var2="/scratch/projects/corevisiongrantnei/NEI_BIDS/derivatives/fmriprep_logs/fmriprep_out_ses_%x-%a_$sub.txt"
		var3="$(whoami)@nyu.edu"

		sbatch --error=$var1 --output=$var2 --mail-user=$var3  fmriprep_nei.sh $sub

		echo Submitted fmriprep for sub-$sub
	fi
done



