#!/bin/bash
#SBATCH --array=1-16
#SBATCH --partition=EPYC
#SBATCH --job-name=rach3_transcode
#SBATCH --cpus-per-task=8
#SBATCH --mem=10gb
#SBATCH --time=00:15:00
#SBATCH --output=dataset_transcode%j.out

# Load variables from a .env file
set -a; source .env; set +a

# Use nullglob in case there are no matching files
shopt -s nullglob

job_id=$SLURM_JOB_ID
echo "Job ID: $job_id"

all_files=("$DATASET_ROOT_DIR"/*.mp4)
no_files=${#all_files[@]}

# If there are more jobs than files and our job ID is higher than the
# amount of files, do nothing.
if ((job_id > no_files)); then
  echo "Found more files than there are jobs, exiting."
  exit 0
fi

# In case there are more jobs than files, we make sure at least one
# task gets assigned per job.
tasks_per_job=$((no_files/(SLURM_ARRAY_TASK_MAX)))
tasks_per_job=$((1 > tasks_per_job ? 1:tasks_per_job))
echo "Tasks per job: $tasks_per_job"

# What file to start and end transcoding at
start_idx=$(((job_id-1)*tasks_per_job))
echo "start_idx: $start_idx"
end_idx=$((start_idx+tasks_per_job))
end_idx=$((end_idx < no_files ? end_idx:no_files))
end_idx=$((end_idx-1))
echo "end_idx: $end_idx"
# Transcode everything between start and end idx's
for i in $(seq $start_idx $end_idx); do
  echo "file: ${all_files[$i]}"
  file="${all_files[$i]}"
  file_basename="$(basename -- "$file")"
  "$FFMPEG_LOC" -i "$file" -map v:0 -map a:0 -vcodec libx265 -crf 23 -x265-params "keyint=11:no-open-gop=1" -pix_fmt yuv420p "$OUTPUT_DIR"/prfr_"$file_basename"
done


