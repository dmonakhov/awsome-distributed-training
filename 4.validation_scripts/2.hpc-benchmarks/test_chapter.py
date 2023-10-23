import pytest
import os


def test_0_nccl_test(docker_build, docker_run):
    img = docker_build('hpc-benchmarks-aws', '0.hpc-benchmarks.Dockerfile')
