#!/bin/bash
#SBATCH --array=1-6
#SBATCH --partition=EPYC
#SBATCH --job-name=rach3_transcode
#SBATCH --cpus-per-task=32
#SBATCH --mem=10gb
#SBATCH --time=00:05:00
#SBATCH --output=./logs/dataset_transcode%j.out

# Load variables from a .env file
set -a; source .env; set +a

# Use nullglob in case there are no matching files
shopt -s nullglob

job_id=$SLURM_ARRAY_TASK_ID
echo "job ID: $job_id"

all_files=("$DATASET_ROOT_DIR"/*.mp4)
# Sort the files to be sure all processes have the same list
readarray -t all_files < <(printf '%s\0' "${all_files[@]}" | sort -z | xargs -0n1)
no_files=${#all_files[@]}
echo "no_files: $no_files"

# If there are more jobs than files and our job ID is higher than the
# amount of files, do nothing.
if ((job_id > no_files)); then
  echo "Found more jobs than there are files, exiting."
  exit 0
fi

# In case there are more jobs than files, we make sure at least one
# task gets assigned per job.
tasks_per_job=$((no_files/(SLURM_ARRAY_TASK_COUNT)))
echo "array task count: $SLURM_ARRAY_TASK_COUNT"
tasks_per_job=$((1 > tasks_per_job ? 1:tasks_per_job))
echo "Tasks per job: $tasks_per_job"

# What file to start and end transcoding at
start_idx=$(((job_id-1)*tasks_per_job))
echo "start_idx: $start_idx"
end_idx=$((start_idx+tasks_per_job))
end_idx=$((end_idx < no_files ? end_idx:no_files))
end_idx=$((end_idx))
echo "end_idx: $end_idx"

# Slice the array to get only the files that we need to do:
sliced_files=("${all_files[@]:$start_idx:$end_idx}")

# Transcode in parallel:
parallel -j "$PARALLEL_PER_JOB" "$FFMPEG_LOC" -i "{}" "$FFMPEG_ARGS" "$OUTPUT_DIR/{/}" ::: "${sliced_files[@]}"
