#!/bin/sh

cd $(dirname $0)
root_dir=${PWD}
cd - &>/dev/null

build_dir=${root_dir}/sw/build

rm -f ${build_dir}/apps/riscv_tests/polito/waves

cd ${build_dir}
make rv_polito.vsim

cd ${root_dir}/tmax
utils/prepare_evcd_rtl.sh dumpports_rtl.riscv_core.vcde

