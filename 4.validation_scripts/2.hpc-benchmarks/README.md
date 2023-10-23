# HPC Benchmarks

[hpc-benchmarks](https://catalog.ngc.nvidia.com/orgs/nvidia/containers/hpc-benchmarks) is an image which
contains collection of benchmakrs for validating HPC performance

## 0. Preparation

This guide assumes that you have the following:

- A functional Slurm cluster on AWS.
- Docker, [Pyxis](https://github.com/NVIDIA/pyxis) and [Enroot](https://github.com/NVIDIA/enroot) installed.
- Enroot requires libmd to compile and squashfs-tools to execute.
- A shared directory mounted on `/apps`

It is recommended that you use the templates in the architectures [directory](../../1.architectures)


## 1. Build the container and the Squash file

Originaly the hpc-benchmarks are image from NVIDIA, in order to make it EFA aware we need to install EFA libraries. To run it on Slurm you will need to build your container then convert it into a Squash file using Enroot.

To build the container:

1. Copy the file `0.hpc-benchmarks.Dockerfile` or its content to your head-node.
2. Build the container image with the command below
   ```bash
   docker build -t hpc-benchmarks-aws -f 0.hpc-benchmarks.Dockerfile .
   ```
3. Convert the container image to a squash file via Enroot
   ```bash
   export IMAGE=/apps/hpc-benchmarks-aws.sqsh
   enroot import -o /${IMAGE}  dockerd://hpc-benchmarks-aws:latest
   ```
   The file will be stored in the `/apps` directory.

## 2. Running the linpack(xhpl) test

XHPL test require explicit GPU,CPU and memory binding options, so it is reasonable to use helper scripts `hpl-aws-p4.sh` and `xhpl-aws-p5.sh`. Assumes we use p4d.24xlarge or p4de.24xlarge compute nodes, let's run basic test for single node
```bash
srun --mpi=pmix --container-image=${IMAGE} ./hpl-aws-p4.sh --dat ./hpl-linux/sample-dat/HPL-dgx-1N.dat

[HPL TRACE] dev_matgen_t: max=0.4795 (1) min=0.4704 (6)
[HPL TRACE] dev_vecgen: max=0.0001 (2) min=0.0001 (1)
 Prog= 2.31%    N_left=   262144        Time=   2.27    Time_left=  95.96       iGF= 125151.50  GF= 125151.50   iGF_per= 15643.94       GF_per= 15643.94
 Prog= 3.45%    N_left=   261120        Time=   3.44    Time_left=  96.22       iGF= 119886.26  GF= 123359.64   iGF_per= 14985.78       GF_per= 15419.95
 Prog= 4.58%    N_left=   260096        Time=   4.41    Time_left=  91.98       iGF= 142200.39  GF= 127534.60   iGF_per= 17775.05       GF_per= 15941.83

 Warm-up done
2023-10-23 11:14:16.320
 Prog= 2.31%    N_left=   262144        Time=   2.21    Time_left=  93.67       iGF= 128205.88  GF= 128205.88   iGF_per= 16025.73       GF_per= 16025.73
 Prog= 3.45%    N_left=   261120        Time=   3.21    Time_left=  89.98       iGF= 140095.86  GF= 131908.50   iGF_per= 17511.98       GF_per= 16488.56
 Prog= 4.58%    N_left=   260096        Time=   4.21    Time_left=  87.74       iGF= 139423.51  GF= 133688.90   iGF_per= 17427.94       GF_per= 16711.11
 Prog= 6.82%    N_left=   258048        Time=   6.32    Time_left=  86.42       iGF= 130308.96  GF= 132560.74   iGF_per= 16288.62       GF_per= 16570.09
 Prog= 7.92%    N_left=   257024        Time=   7.44    Time_left=  86.54       iGF= 120900.17  GF= 130800.87   iGF_per= 15112.52       GF_per= 16350.11
```

In order to run two nodes test copy the file `1.xhpl-p4.sbatch` or its content on your cluster then submit a preprocessing jobs with the command below:

```
sbatch 1.xhpl-p4.sbatch
```

Here is example script `1.xhpl-p5.sbatch` which run xhpl test on 4 p5.48xlarge nodes
```

sbatch 1.xhpl-p5.sbatch
```
Here is example of test running log, last string is final porformance result, in this case total performance is 1.34PFLOPS FP64
```
tail -f slurm-21808.out

 ... Testing HPL components ...
 Prog= 1.73%        N_left=   525312        Time=   1.29    Time_left=  72.98       iGF= 1324291.79 GF= 1324291.79  iGF_per= 41384.12       GF_per= 41384.12
 Prog= 3.45%        N_left=   522240        Time=   2.45    Time_left=  68.49       iGF= 1455487.51 GF= 1386411.02  iGF_per= 45483.98       GF_per= 43325.34
 Prog= 4.58%        N_left=   520192        Time=   3.21    Time_left=  66.85       iGF= 1459242.11 GF= 1403721.04  iGF_per= 45601.32       GF_per= 43866.28

 Warm-up done
 2023-10-23 11:50:54.885
 Prog= 1.73%        N_left=   525312        Time=   1.17    Time_left=  66.33       iGF= 1456902.82 GF= 1456902.82  iGF_per= 45528.21       GF_per= 45528.21
 Prog= 3.45%        N_left=   522240        Time=   2.23    Time_left=  62.53       iGF= 1586660.33 GF= 1518636.95  iGF_per= 49583.14       GF_per= 47457.40
 Prog= 4.58%        N_left=   520192        Time=   2.93    Time_left=  61.04       iGF= 1597549.46 GF= 1537400.11  iGF_per= 49923.42       GF_per= 48043.75
 Prog= 6.26%        N_left=   517120        Time=   4.02    Time_left=  60.16       iGF= 1519253.84 GF= 1532486.12  iGF_per= 47476.68       GF_per= 47890.19
 Prog= 7.37%        N_left=   515072        Time=   4.81    Time_left=  60.46       iGF= 1376263.43 GF= 1506739.69  iGF_per= 43008.23       GF_per= 47085.62
 Prog= 9.02%        N_left=   512000        Time=   5.86    Time_left=  59.13       iGF= 1543550.10 GF= 1513333.94  iGF_per= 48235.94       GF_per= 47291.69
 Prog= 10.64%       N_left=   508928        Time=   6.85    Time_left=  57.49       iGF= 1618938.77 GF= 1528582.60  iGF_per= 50591.84       GF_per= 47768.21
 Prog= 11.72%       N_left=   506880        Time=   7.51    Time_left=  56.60       iGF= 1587779.10 GF= 1533825.26  iGF_per= 49618.10       GF_per= 47932.04
 Prog= 13.31%       N_left=   503808        Time=   8.50    Time_left=  55.37       iGF= 1585221.33 GF= 1539807.30  iGF_per= 49538.17       GF_per= 48118.98
..<SKIP>
 ================================================================================
 T/V                N    NB     P     Q         Time          Gflops (   per GPU)
 --------------------------------------------------------------------------------
 WC03R2R2      528384  1024     8     4        73.32       1.341e+06 ( 4.192e+04)
```