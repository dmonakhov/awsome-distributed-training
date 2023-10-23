#!/bin/bash

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0

#SBATCH -N 4 # number of nodes to use p5.48xlarge = 32 H100 GPUs
#SBATCH --job-name=xhpl # name of your job
#SBATCH --ntasks-per-node 8 # Number of GPU per node
#SBATCH --gres=gpu:8 # number of GPU we reserve
#SBATCH --exclusive
#SBATCH --wait-all-nodes=1
#SBATCH --export=NIL # do not export env vars from the host env


###########################
###### User Variables #####
###########################


# default variables for Enroot
: "${APPS_PATH:=/apps}"

: "${IMAGE:=$APPS_PATH/hpc-benchmarks-aws.sqsh}"

## Plenty of EFA level variables
export FI_EFA_USE_DEVICE_RDMA=1 # use for p4d
export FI_PROVIDER=efa
export FI_EFA_FORK_SAFE=1
export FI_LOG_LEVEL=1
export FI_PROVIDER=efa # change to eth if you want to use ENA for comparisons
export NCCL_DEBUG=INFO


declare -a ARGS=(
    --container-image $IMAGE
)
srun -l "${ARGS[@]}" --mpi=pmix ./hpl-aws-p5.sh --dat ./hpl-linux/sample-dat/HPL-dgx-8N.dat
