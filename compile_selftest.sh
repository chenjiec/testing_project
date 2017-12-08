#!/bin/sh

cd $(dirname $0)
root_dir=${PWD}
cd - &>/dev/null

build_dir=${root_dir}/sw/build

cd ${build_dir}
make rv_polito
