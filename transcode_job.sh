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

source ./split_work.sh

# Transcode in parallel:
parallel -j "$PARALLEL_PER_JOB" \
"$FFMPEG_LOC -i {} $TRANSCODE_FFMPEG_ARGS $TRANSCODE_OUTPUT_DIR/{/}" ::: "${sliced_files[@]}"

echo "Done, exiting"