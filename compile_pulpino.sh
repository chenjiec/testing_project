#!/bin/sh

cd $(dirname $0)
root_dir=${PWD}
cd - &>/dev/null

build_dir=${root_dir}/sw/build
mkdir -p ${build_dir}
cd ${build_dir}

# SETUP BUILD DIRECTORY
cp ../cmake_configure.riscv.gcc.sh .

# UPDATE MAKEFILES
./cmake_configure.riscv.gcc.sh

# COMPILE RTL
make vcompile
