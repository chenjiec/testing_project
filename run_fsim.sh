#!/bin/sh

cd $(dirname $0)
root_dir=${PWD}
cd - &>/dev/null

cd ${root_dir}/tmax
tmax -shell fsim.tcl
