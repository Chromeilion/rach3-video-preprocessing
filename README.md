# What is this?
This is a script for processing the Rach3 videos into a more usable format using a SLURM compute cluster.
While it can work on any compute cluster in theory, it's been designed primarily for the ORFEO compute cluster at the Area Science Park Trieste.

# Why do the videos need to be preprocessed?
There are two main issues that can be fixed by processing the videos:
 1. Lower file size. Currently, the videos are in a relatively uncompressed format, meaning that they take up an absurd amount of data.
 2. Lower the keyframe interval. This is very important because the videos are used for machine learning. A lower keyframe interval reduces the random access time of all frames significantly.

# How is this done?
This script utilizes FFMPEG. The videos are re-encoded using HEVC and the keyframe interval is also changed.
HEVC is used because it's standard and has good support from most modern hardware and software. 
A more exotic format, such as AV1 for example, may provide better image quality and size reductions, but it has slower decode times and worse hardware support, both of which are critical for machine learning.

