#!/bin/bash
#SBATCH --partition=EPYC
#SBATCH --job-name=dataset_transcode
#SBATCH --nodes=5
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=32
#SBATCH --mem=10gb
#SBATCH --time=00:15:00
#SBATCH --output=dataset_transcode%j.out
# Load variables from a .env file
set -a; source .env; set +a
# Use nullglob in case there are no matching files
shopt -s nullglob
all_files=($DATASET_ROOT_DIR/*.mp4)
no_files=${#all_files[@]}
tasks_per_job=$(($no_files/$SLURM_NTASKS))
# What file to start and end transcoding at
start_idx=$((($SLURM_JOB_ID-1)*$tasks_per_job))
end_idx=$(($start_idx+$tasks_per_job))
end_idx=$(($end_idx < $no_files ? $end_idx:$no_files))
# Transcode everything between start and end idx's
for i in $(seq $start_idx $end_idx); do
    ./ff/ffmpeg -i $arr[$i] -map v:0 -vcodec libx265 -crf 23 -x265-params "keyint=11:no-open-gop=1" -pix_fmt yuv420p ./output/output.mp4
done


