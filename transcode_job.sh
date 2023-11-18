#!/bin/bash
#SBATCH --partition=EPYC
#SBATCH --job-name=dataset_transcode
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=32
#SBATCH --mem=10gb
#SBATCH --time=00:15:00
#SBATCH --output=dataset_transcode%j.out
set -a; source .env; set +a
shopt -s nullglob
all_files=($DATASET_ROOT_DIR/*.mp4)
no_files=${#all_files[@]}
tasks_per_job=($len_files/$SLURM_NTASKS)
start_idx=$SLURM_JOB_ID*$tasks_per_job
end_idx=$(($start_idx+$tasks_per_job<$len_files}?$start_idx+$tasks_per_job:$len_files)) 
for ((i=$start_idx; i<$end_idx; i++)); do
    ./ff/ffmpeg -i $arr[$i] -map v:0 -vcodec libx265 -crf 23 -x265-params "keyint=11:no-open-gop=1" -pix_fmt yuv420p ./output/output.mp4
    echo "${arr[$i]}"
done


