#!/bin/bash
# \
exec vsim -64 -do "$0"

set TB_TEST $::env(TB_TEST)
set VSIM_FLAGS    "-GTEST=\"$TB_TEST\""

set TB            tb
set MEMLOAD       "PRELOAD"

source ./tcl_files/config/vsim.tcl

do ./tcl_files/wave.do

vcd dumpports /tb/top_i/core_region_i/CORE/RISCV_CORE/* -file tmax/dumpports_rtl.riscv_core.vcde -unique

