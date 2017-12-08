#=============================================================================#
#                              Configuration                                  #
#=============================================================================#

set DESIGN_NAME      "riscv_core"

set NETLIST_FILES    [list "../gate/$DESIGN_NAME.gate.v"]

set LIBRARY_FILES    [list "../gate/NangateOpenCellLibrary.tlib"]



#=============================================================================#
#                           Read Design & Technology files                    #
#=============================================================================#

# Rules to be ignored
set_rules B7  ignore    ;# undriven module output pin
set_rules B8  ignore    ;# unconnected module input pin
set_rules B9  ignore    ;# undriven module internal net
set_rules B10 ignore    ;# unconnected module internal net
set_rules N20 ignore    ;# underspecified UDP
set_rules N21 ignore    ;# unsupported UDP entry
set_rules N23 ignore    ;# inconsistent UDP


# Reset TMAX
reset_all
build -force
read_netlist -delete

set_netlist -sequential_modeling

# Read library files
foreach lib_file $LIBRARY_FILES {
    read_netlist $lib_file
}

# Read gate level netlist
foreach design_file $NETLIST_FILES {
    read_netlist $design_file
}


# Remove unused net connections
remove_net_connection -all

# Build the model
run_build_model $DESIGN_NAME


#=============================================================================#
#                                    Run DRC                                  #
#=============================================================================#

add_po_masks -all
remove_po_masks instr_req_o
remove_po_masks instr_addr_o[31]
remove_po_masks instr_addr_o[30]
remove_po_masks instr_addr_o[29]
remove_po_masks instr_addr_o[28]
remove_po_masks instr_addr_o[27]
remove_po_masks instr_addr_o[26]
remove_po_masks instr_addr_o[25]
remove_po_masks instr_addr_o[24]
remove_po_masks instr_addr_o[23]
remove_po_masks instr_addr_o[22]
remove_po_masks instr_addr_o[21]
remove_po_masks instr_addr_o[20]
remove_po_masks instr_addr_o[19]
remove_po_masks instr_addr_o[18]
remove_po_masks instr_addr_o[17]
remove_po_masks instr_addr_o[16]
remove_po_masks instr_addr_o[15]
remove_po_masks instr_addr_o[14]
remove_po_masks instr_addr_o[13]
remove_po_masks instr_addr_o[12]
remove_po_masks instr_addr_o[11]
remove_po_masks instr_addr_o[10]
remove_po_masks instr_addr_o[9]
remove_po_masks instr_addr_o[8]
remove_po_masks instr_addr_o[7]
remove_po_masks instr_addr_o[6]
remove_po_masks instr_addr_o[5]
remove_po_masks instr_addr_o[4]
remove_po_masks instr_addr_o[3]
remove_po_masks instr_addr_o[2]
remove_po_masks instr_addr_o[1]
remove_po_masks instr_addr_o[0]
remove_po_masks data_req_o
remove_po_masks data_we_o
remove_po_masks data_be_o[3]
remove_po_masks data_be_o[2]
remove_po_masks data_be_o[1]
remove_po_masks data_be_o[0]
remove_po_masks data_addr_o[31]
remove_po_masks data_addr_o[30]
remove_po_masks data_addr_o[29]
remove_po_masks data_addr_o[28]
remove_po_masks data_addr_o[27]
remove_po_masks data_addr_o[26]
remove_po_masks data_addr_o[25]
remove_po_masks data_addr_o[24]
remove_po_masks data_addr_o[23]
remove_po_masks data_addr_o[22]
remove_po_masks data_addr_o[21]
remove_po_masks data_addr_o[20]
remove_po_masks data_addr_o[19]
remove_po_masks data_addr_o[18]
remove_po_masks data_addr_o[17]
remove_po_masks data_addr_o[16]
remove_po_masks data_addr_o[15]
remove_po_masks data_addr_o[14]
remove_po_masks data_addr_o[13]
remove_po_masks data_addr_o[12]
remove_po_masks data_addr_o[11]
remove_po_masks data_addr_o[10]
remove_po_masks data_addr_o[9]
remove_po_masks data_addr_o[8]
remove_po_masks data_addr_o[7]
remove_po_masks data_addr_o[6]
remove_po_masks data_addr_o[5]
remove_po_masks data_addr_o[4]
remove_po_masks data_addr_o[3]
remove_po_masks data_addr_o[2]
remove_po_masks data_addr_o[1]
remove_po_masks data_addr_o[0]
remove_po_masks data_wdata_o[31]
remove_po_masks data_wdata_o[30]
remove_po_masks data_wdata_o[29]
remove_po_masks data_wdata_o[28]
remove_po_masks data_wdata_o[27]
remove_po_masks data_wdata_o[26]
remove_po_masks data_wdata_o[25]
remove_po_masks data_wdata_o[24]
remove_po_masks data_wdata_o[23]
remove_po_masks data_wdata_o[22]
remove_po_masks data_wdata_o[21]
remove_po_masks data_wdata_o[20]
remove_po_masks data_wdata_o[19]
remove_po_masks data_wdata_o[18]
remove_po_masks data_wdata_o[17]
remove_po_masks data_wdata_o[16]
remove_po_masks data_wdata_o[15]
remove_po_masks data_wdata_o[14]
remove_po_masks data_wdata_o[13]
remove_po_masks data_wdata_o[12]
remove_po_masks data_wdata_o[11]
remove_po_masks data_wdata_o[10]
remove_po_masks data_wdata_o[9]
remove_po_masks data_wdata_o[8]
remove_po_masks data_wdata_o[7]
remove_po_masks data_wdata_o[6]
remove_po_masks data_wdata_o[5]
remove_po_masks data_wdata_o[4]
remove_po_masks data_wdata_o[3]
remove_po_masks data_wdata_o[2]
remove_po_masks data_wdata_o[1]
remove_po_masks data_wdata_o[0]


# Allow ATPG to use nonscan cell values loaded by the last shift.
#set_drc -load_nonscan_cells

# Report settings
report_settings drc

# Run DRC
#run_drc $SPF_FILE
run_drc


#=============================================================================#
#                               Fault Simulation                              #
#=============================================================================#

set_patterns -external dumpports_rtl.$DESIGN_NAME.vcde -sensitive -strobe_period { 40 ns } -strobe_offset { 698 ns }
run_simulation -sequential -sequential_update
set_faults -model stuck
#add_faults -all
read_faults initial_fault_list.txt -add -force_retain_code
run_fault_sim -sequential
 
# # Create reports
report_summaries
write_faults output_fault_list.txt -all -replace
report_faults -level {100 1} -verbose > report_faults_verbose.txt
report_faults -level {5 100} > report_faults.txt

# 
quit


