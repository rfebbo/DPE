
#####################################
# Generic syn and p&r utilities     #
# dc-generic.tcl                    #
# University of Tennessee Knoxville #
# John Murray                       #
# 2021                              #
#                                   #
# Rev:           v0.39              #
# Last mofified: 2021/04/12         #
#####################################


set my_toplevel @TOP_LEVEL_DESIGN@
set my_top_sv [format "%s%s" $my_toplevel ".sv"]

source @DC_CFG_DIR@/dc_clk_settings.tcl
source @DC_CFG_DIR@/dc_lib_settings.tcl
source @DC_CFG_DIR@/dc_sv_sources.tcl


set my_sverilog_files $my_top_sv
set src_sverilog_files [concat $my_sverilog_files $base_sverilog_files]
set search_path [concat "." [concat $env(USER_SRCS_DIR) [concat [concat $env(DES_GEN_DIR) @PWD_PATH@] $lib_search_path]]]


# Remove existing design if being rerun
remove_design -all -quiet


### Disable generation of tristates in output netlist
set verilog_out_no_tri true


### Read sources
# read -f sverilog { $src_sverilog_files }
# read_file $src_sverilog_files -autoread -format sverilog -top $my_toplevel
read_file {@PWD_PATH@/srcs @PWD_PATH@/core/base-srcs} -autoread -recursive -format sverilog -top $my_toplevel


### Initialize Design
analyze -f sverilog $src_sverilog_files
elaborate $my_toplevel
current_design $my_toplevel
# set_boundary_optimization true
# set_fix_multiple_port_nets -all -buffer_constants true
set_fix_multiple_port_nets -all


### Timing constraints
if {$env(DES_HAS_CLK) == "1"} {
  ### Clock
  set find_clock [ find port [list $env(DC_CLK_NETS)] ]
  if { $find_clock != [list] } {
      set clk_name $env(DC_CLK_NETS)
      create_clock -name $clk_name -period $CLK_PERIOD [get_ports $env(DC_CLK_NETS)]
  } else {
      set clk_name vclk
      create_clock -name $clk_name -period $CLK_PERIOD
  }
  # create_clock -name $CLK_INPUT -period $CLK_PERIOD [get_ports $env(DC_CLK_NETS)]
  # set_clock_latency -rise $TR -fall $TF
  # set_clock_uncertainty $CLK_SKEW
  set_dont_touch_network [get_clocks $clk_name]
  set_fix_hold [get_clocks $clk_name]
  set_driving_cell -lib_cell inv_x1 [all_inputs]
  set_input_delay $CLK_DELAY -clock $clk_name [remove_from_collection [all_inputs] $clk_name]
  set_output_delay $CLK_DELAY -clock $clk_name [all_outputs]
  set_clock_latency $TR -rise [get_clocks $clk_name]
  set_clock_latency $TF -fall [get_clocks $clk_name]
  set_clock_uncertainty $CLK_SKEW [get_clocks $clk_name]
  report_clock

  ### IO delay
  # set_input_delay 2 -clock $CLK_INPUT [all_inputs]
  # set_output_delay 2 -clock $CLK_INPUT [all_outputs]
  # set_input_delay 4 -clock $CLK_INPUT [all_inputs]
  # set_output_delay 4 -clock $CLK_INPUT [all_outputs]
  # set_max_delay -from [all_inputs] -to [all_outputs] 4
}

### Specify Load
set_load 2 [all_outputs]


### Operating conditions (Doesn't really do anything right now)
#set_operating_conditions WORST
#set_operating_conditions PVT_1V_27C


### Clock gating
if {$env(DES_HAS_CLK) == "1"} {
  set_clock_gating_style -num_stages $env(DC_CG_STAGES) -sequential_cell latch \
                         -minimum_bitwidth $env(DC_CG_BITWIDTH)
}


### Link instances to libraries
link
check_design


### Compile design
# compile_ultra -no_autoungroup
if {$env(DES_HAS_CLK) == "1"} {
  compile_ultra -no_autoungroup -gate_clock -retime
  # compile_ultra -no_autoungroup -gate_clock -retime -no_boundary_optimization
} else {
  compile_ultra -no_autoungroup -retime
  # compile_ultra -no_autoungroup -retime -no_boundary_optimization
}


### Optimize for area
optimize_netlist -area

### Recompile
compile_ultra -incremental


### Reports
report_timing

if {$env(DES_HAS_CLK) == "1"} {
  # report_clock_timing -type skew
}

report_constraint -all_violators


if {$env(DC_SAVE_REPS) == "1"} {
  set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_timing.rep"]
  redirect $filename {report_timing}

  set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_cell.rep"]
  redirect $filename {report_cell}

  set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_power.rep"]
  redirect $filename {report_power -analysis_effort high}

  set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_area.rep"]
  redirect $filename {report_area -hierarchy}

  set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_hierarchy.rep"]
  redirect $filename {report_hierarchy}
}


change_names -rule sverilog -hierarchy

set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_compiled.sdc"]
write_sdc $filename

set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_compiled.sdf"]
write_sdf $filename

set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_compiled.v"]
write -format verilog -hierarchy -output $filename

quit
