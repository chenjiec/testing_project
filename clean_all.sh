#!/bin/sh

cd $(dirname $0)
root_dir=${PWD}
cd - &>/dev/null


rm -rf ${root_dir}/sw/build

rm -rf ${root_dir}/vsim/{modelsim.ini,modelsim_libs,waves,work}

rm -rf ${root_dir}/tmax/dumpports_rtl.riscv_core.vcde
rm -rf ${root_dir}/tmax/output_fault_list.txt
rm -rf ${root_dir}/tmax/report_faults.txt
rm -rf ${root_dir}/tmax/report_faults_verbose.txt

