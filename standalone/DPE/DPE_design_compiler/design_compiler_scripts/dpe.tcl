gui_start

set search_path ". /research/seneca/RAVENS_TSMC65/LibraryData/stdlib_tsmc65/current/library"
set link_library "* /research/seneca/RAVENS_TSMC65/LibraryData/stdlib_tsmc65/current/library/stdio_tsmc65_ccs.db"
set target_library "* /research/seneca/RAVENS_TSMC65/LibraryData/stdlib_tsmc65/current/library/stdio_tsmc65_ccs.db"

analyze -library WORK -format sverilog {/home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/DPE_srcs/CSA/CSA_8.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/DPE_srcs/CSA/RCA/RCA.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/DPE_srcs/CSA/RCA/FA/FA.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/DPE_srcs/MAC/spike_MAC.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/DPE_srcs/DPE.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/DPE_srcs/DPE_params.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/scanchain/RegPLoad.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/scanchain/ShiftRegN.sv /home/rfebbo/cadence/ravens/tsmc65_srcs/DPE/standalone/sram/1Kb/sram_bb.sv}

elaborate DPE -architecture verilog -library WORK

link

compile_ultra

write -f verilog -h -o DPE_GLN.v