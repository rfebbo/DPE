
#####################################
# Generic syn and p&r utilities     #
# iv-generic.tcl                    #
# University of Tennessee Knoxville #
# John Murray                       #
# 2021                              #
#                                   #
# Rev:           v0.55              #
# Last mofified: 2021/06/09         #
#####################################


set my_toplevel @TOP_LEVEL_DESIGN@
set my_output_lib [format "%s%s" $my_toplevel "_lib"]

set my_design $my_toplevel
set my_compiled_verilog [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_compiled.v"]
# set my_pins [format "%s %s %s %s %s" "CLK" "RESETn" "SC_EN" "scanIn" "scanOut"]

set search_path {@DES_GEN_DIR@ + .}
source @IV_CFG_DIR@/iv_config.tcl

set init_verilog $my_compiled_verilog
set init_design $my_design
set init_top_cell $my_toplevel

set init_pwr_net @IV_PWR_NETS@
set init_gnd_net @IV_GND_NETS@

set filler_cells {                                                     \
  filler_x01 filler_x02 filler_x03 filler_x04 filler_x05              \
  filler_x06 filler_x07 filler_x08 filler_x09 filler_x10              \
  filler_x01_empty filler_x02_empty filler_x03_empty filler_x04_empty \
  filler_x05_empty filler_x06_empty filler_x07_empty filler_x08_empty \
  filler_x09_empty filler_x10_empty                                   \
  filler_x01_norx  filler_x02_norx  filler_x03_norx  filler_x04_norx  \
  filler_x05_norx  filler_x06_norx  filler_x07_norx  filler_x08_norx  \
  filler_x09_norx  filler_x10_norx                                    \
}

set tie_cells { tiehi tielo }

set init_mmmc_file @DESIGN_MMC_FILE@

#setMessageLimit 200

init_design

setIoFlowFlag 0

# Make metal layers/features of cells visible
setLayerPreference node_cell -isVisible 1

# setTieHiLoMode -maxFanout 10 -maxDistance 20 -cell "tiehi tielo" -cellPins "tiehi:H tielo:L"
# setTieHiLoMode -maxFanout 10 -maxDistance 20 -cell "tiehi tielo"
# addTieHiLo -cell "tiehi tielo" -cellPins "tiehi:H tielo:L"
# addTieHiLo -cell "tiehi tielo"
# setTieHiLoMode -maxFanout 10 -maxDistance 20 -cell "tiehi tielo"

### Try reading SDF
read_sdf @DES_GEN_DIR@/@TOP_LEVEL_DESIGN@_compiled.sdf

### Specify Floorplan
# floorPlan -site CORE_SITE -r $AspectRatio $Density $Margin $Margin $Margin $Margin
# floorPlan -site CoreSite -r 0.8 0.7 10 10 10 10 -noResize
# floorPlan -site CoreSite -d 50 50 15 15 15 15 -adjustToSite
floorPlan -site CoreSite -r @IV_DES_ASPECT@ @IV_DES_DENSITY@ @IV_DES_MARGIN_LEFT@ @IV_DES_MARGIN_BOT@ @IV_DES_MARGIN_RIGHT@ @IV_DES_MARGIN_TOP@ -noResize


addHaloToBlock 14.28 14.28 14.28 14.28 -allBlock

### Connect global nets 
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin vdd!    -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin \\vdd!  -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin vdd     -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin VDD     -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin VDD1V2  -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin VDD1v2  -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin vdd1V2  -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type pgpin -pin vdd1v2  -instanceBasename * -hierarchicalInstance {} -override
# globalNetConnect @IV_PWR_CORE@ -type pgpin -pin VDD1V2  -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_GND_CORE@ -type pgpin -pin gnd!    -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_GND_CORE@ -type pgpin -pin \\gnd!  -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_GND_CORE@ -type pgpin -pin gnd     -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_GND_CORE@ -type pgpin -pin GND     -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_GND_CORE@ -type pgpin -pin vss     -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_GND_CORE@ -type pgpin -pin VSS     -instanceBasename * -hierarchicalInstance {} -override
# globalNetConnect @IV_GND_CORE@ -type pgpin -pin GND    -instanceBasename * -hierarchicalInstance {} -override
globalNetConnect @IV_PWR_CORE@ -type tiehi
globalNetConnect @IV_GND_CORE@ -type tielo


### Power Ring Creation
setAddRingMode -ring_target default -extend_over_row 0 -ignore_rows 0    \
               -avoid_short 0 -skip_crossing_trunks none                 \
               -via_using_exact_crossover_size 1 -orthogonal_only true   \
               -skip_via_on_pin { standardcell }                         \
               -skip_via_on_wire_shape { noshape }                       \
               -stacked_via_bottom_layer @IV_RING_BOT_VIA_LAYER@ -stacked_via_top_layer @IV_RING_TOP_VIA_LAYER@


addRing -nets {@IV_GND_NETS@ @IV_PWR_NETS@} -type core_rings -follow core \
        -layer {top @IV_HORZ_RING_LAYER@ bottom @IV_HORZ_RING_LAYER@ left @IV_VERT_RING_LAYER@ right @IV_VERT_RING_LAYER@}      \
        -width {top @IV_HORZ_RING_WIDTH@ bottom @IV_HORZ_RING_WIDTH@ left @IV_VERT_RING_WIDTH@ right @IV_HORZ_RING_WIDTH@}      \
        -spacing {top @IV_HORZ_RING_SPACE@ bottom @IV_HORZ_RING_SPACE@ left @IV_VERT_RING_SPACE@ right @IV_VERT_RING_SPACE@}    \
        -offset {top @IV_HORZ_RING_OFFSET@ bottom @IV_HORZ_RING_OFFSET@ left @IV_VERT_RING_OFFSET@ right @IV_VERT_RING_OFFSET@} \
        -center 0 -extend_corner {} -threshold 0 -jog_distance 0          \
        -snap_wire_center_to_grid None


### Power Stripe Creation
setAddStripeMode -ignore_block_check false -break_at none                 \
        -route_over_rows_only false -rows_without_stripes_only false      \
        -extend_to_closest_target none -stop_at_last_wire_for_area false  \
        -partial_set_thru_domain false -ignore_nondefault_domains false   \
        -trim_antenna_back_to_shape none -spacing_type edge_to_edge       \
        -spacing_from_block 0 -stripe_min_length stripe_width             \
        -via_using_exact_crossover_size false -split_vias false           \
        -orthogonal_only true -allow_jog { padcore_ring block_ring }      \
        -skip_via_on_pin { standardcell }                                 \
        -skip_via_on_wire_shape { noshape }                               \
        -stacked_via_bottom_layer @IV_STRIPE_BOT_VIA_LAYER@ -stacked_via_top_layer @IV_STRIPE_TOP_VIA_LAYER@

addStripe -switch_layer_over_obs false -snap_wire_center_to_grid None      \
        -max_same_layer_jog_length 2 -use_wire_group 0                     \
        -start_offset @IV_STRIPE_OFFSET@ -set_to_set_distance @IV_STRIPE_DIST@ -width @IV_STRIPE_WIDTH@ -spacing @IV_STRIPE_SPACE@ \
        -start_from left -direction vertical -create_pins 1                \
        -block_ring_bottom_layer_limit M1 -padcore_ring_top_layer_limit BB \
        -padcore_ring_bottom_layer_limit M1 -block_ring_top_layer_limit BB \
        -layer @IV_STRIPE_LAYER@ -nets {@IV_PWR_NETS@ @IV_GND_NETS@}

### Power Routing
setSrouteMode -viaConnectToShape { noshape stripe followpin } -targetNumber { 1 }
sroute -connect { blockPin padPin padRing corePin floatingStripe }                   \
  -blockPinTarget { nearestRingStripe nearestTarget }                                \
  -padPinPortConnect { allPort oneGeom }                                             \
  -blockPin useLef -allowJogging 1 -allowLayerChange 1                               \
  -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } \
  -crossoverViaLayerRange { M1(1) BB(6) } -targetViaLayerRange { M1(1) BB(6) }       \
  -layerChangeRange { M1(1) BB(6)) }                                                 \
  -nets {@IV_GND_NETS@ @IV_PWR_NETS@}


### Logic/stdcell Placement
setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -clkGateAware 1 \
        -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 1 \
        -placeIOPins 1 -moduleAwareSpare 1 \
        -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setPlaceMode -fp true
place_design

set delaycal_use_default_delay_limit 1500

setPlaceMode -fp false
place_design -noPrePlaceOpt -incremental

setRouteMode -earlyGlobalHonorMsvRouteConstraint false \
             -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setUsefulSkewMode -maxSkew false -noBoundary false \
        -useCells {buf_x1 buf_x2 buf_x4 buf_x8 buf_x16 buf_x32 buf_x64 \
                   inv_x1 inv_x2 inv_x4 inv_x8 inv_x16 inv_x32 inv_x64} \
        -maxAllowedDelay 1

setPlaceMode -reset
setPlaceMode -congEffort high -timingDriven 1 -clkGateAware 1 \
        -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 1 \
        -placeIOPins 1 -moduleAwareSpare 1 \
        -preserveRouting 0 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setRouteMode -earlyGlobalMaxRouteLayer 5
refinePlace -checkRoute 0 -preserveRouting 0 -rmAffectedRouting 0 -swapEEQ 0


# # *** CTS ***
# if {$env(DES_HAS_CLK)} {
#   set_db design_early_clock_flow true
# }

setPlaceMode -fp false

if {$env(DES_HAS_CLK)} {
  # IV is not happy with these commands
  #set_db place_global_clock_power_driven true
  #set_db place_global_cong_effort high
  place_opt_design -incremental
  refinePlace
} else {
  placeDesign -noPrePlaceOpt
}

setDrawView place
setLayerPreference node_cell -isVisible 1


# Unnecessary due to setting in iv_config.tcl
### Via Generation
# generateVias


if {$env(DES_HAS_CLK)} {
  if {$env(OVERRIDE_CTS_MAX_TRAN_TIME)} {
    set_db override_minimum_max_trans_target true
  }
  ### Clock Tree
  set_db cts_buffer_cells   { buf_x1 buf_x2 buf_x4 buf_x8 buf_x16 buf_x32 buf_x64 }
  set_db cts_inverter_cells { inv_x1 inv_x2 inv_x4 inv_x8 inv_x16 inv_x32 inv_x64 }
  # set_db cts_clock_gating_cells { latchgd_x1 latchgd_x2 latchgd_x4 latchgd_x8 \
  #                                 and2_x1 and2_x2 and2_x4 and2_x8 \
  #                                 nand2_x1 nand2_x2 nand2_x4 nand2_x8}

  # # Maximum transition target -- listed as '5' in Liberty file for stdlib
  # ### Rule of Thumb: Slew should be 10% - 20% of Clock Period
  # ###                Thus, max transition time = 20% of Clock Period
  # set_db cts_target_max_transition_time 10
  # Maximum transition target
  set_db cts_target_max_transition_time @IV_CTS_MAX_TRAN_TIME@

  # Skew target
  set_db cts_target_skew @IV_CTS_SKEW_TARGET@
  # set_db cts_target_skew 5
  set_db cts_clock_gate_movement_limit 20
  # Need an exit strategy ... it will run forever if constraints bad
  set_db cts_exit_if_skew_target_over_constrained true

  if {${my_toplevel} == "DPE"} {
    set_ccopt_property -pin sram/clk sink_type stop
    set_ccopt_property -pin sram/clk -delay_corner gen_delay_corner capacitance_override 2fF
  } elseif {${my_toplevel} == "rv_uart_top"} {
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell0/clk sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell0/clk -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell1/clk sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell1/clk -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell2/clk sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell2/clk -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell3/clk sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_icell3/clk -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell0/clk  sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell0/clk  -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell1/clk  sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell1/clk  -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell2/clk  sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell2/clk  -delay_corner gen_delay_corner capacitance_override 2fF
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell3/clk  sink_type stop
    set_ccopt_property -pin memcon0/sharedmem/genblk1_cell3/clk  -delay_corner gen_delay_corner capacitance_override 2fF
  }

  # create_ccopt_clock_tree_spec -file ccopt.spec
  # source ccopt.spec
  create_ccopt_clock_tree_spec
  # *** CTS ***
  ccopt_design
}

# *** CTS ***
if {$env(DES_HAS_CLK)} {
  optDesign -postCTS -incr
  optDesign -postCTS -incr -hold
}


setRouteMode -earlyGlobalHonorMsvRouteConstraint false \
             -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false


### Signal Routing
# This *should* make the router trictly honor tracks from LEF
add_tracks -honor_pitch

# setNanoRouteMode -quiet -routeTopRoutingLayer 4
# setNanoRouteMode -quiet -routeBottomRoutingLayer 1
setNanoRouteMode -quiet -routeTopRoutingLayer @IV_TOP_NR_LAYER@
setNanoRouteMode -quiet -routeBottomRoutingLayer @IV_BOT_NR_LAYER@
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -routeWithSiDriven false
setNanoRouteMode -quiet -timingEngine {}
# # setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
# # setNanoRouteMode -quiet -droutePostRouteWidenWireRule LEFDefaultRouteSpec_Min
# # setNanoRouteMode -quiet -droutePostRouteWidenWireRule DEFAULT
# setNanoRouteMode -quiet -routeStrictlyHonorNonDefaultRule "wire 2:3"
# setNanoRouteMode -quiet -drouteOnGridOnly {wire 2:3 via 2:3}
setNanoRouteMode -quiet -droutePostRouteSpreadWire false
setNanoRouteMode -quiet -drouteOnGridOnly all
setNanoRouteMode -quiet -routeStrictlyHonorNonDefaultRule true
# setNanoRouteMode -quiet -routeExtraViaEnclosure 0.09
setNanoRouteMode -quiet -routeExtraViaEnclosure 0.04
setNanoRouteMode -quiet -routeWithViaInPin 1:2
routeDesign -globalDetail



# *** CTS ***
if {$env(DES_HAS_CLK)} {
  # Removed as options don't exist anymore
  # setOptMode -fixCap true -fixTran true -fixFanoutLoad true
  # setDelayCalMode -engine default -siAware true
  setOptMode -fixFanoutLoad true

  setAnalysisMode -analysisType onChipVariation
  setAnalysisMode -cppr both
  optDesign -postRoute -incr
  optDesign -postRoute -incr -hold
}


### Filler Placement
addFiller -cell $filler_cells -prefix FILLER -fitGap
# IV is not happy with stylus commands
# add_fillers -base_cell $filler_cells -fill_gap
ecoRoute -target



### Optionally save design
# set design_filename [format "%s%s%s%s" $my_toplevel "-" $my_compiled_version "-testing.innovus"]
# saveDesign $design_filename

### DRC
setVerifyGeometryMode -area { 0 0 0 0 } -minWidth true -minSpacing true -minArea true             \
  -sameNet true -short true -overlap true -offRGrid false -offMGrid true -mergedMGridCheck true   \
  -minHole true -implantCheck true -minimumCut true -minStep true -viaEnclosure true              \
  -antenna false -insuffMetalOverlap true -pinInBlkg false -diffCellViol true -sameCellViol false \
  -padFillerCellsOverlap true -routingBlkgPinOverlap true -routingCellBlkgOverlap true            \
  -regRoutingOnly false -stackedViasOnRegNet false -wireExt true -useNonDefaultSpacing false      \
  -maxWidth true -maxNonPrefLength -1 -error 1000 -warning 50
verifyGeometry
setVerifyGeometryMode -area { 0 0 0 0 }

### LVS
verifyConnectivity -type all -error 1000 -warning 50


### Export
# Can export sdf if desired (see docs for options)
#set sdf_filename [format "%s%s" $my_toplevel "_pnr.sdf"]
#write_sdf $sdf_filename
# Netlist for schematic
set schematic_filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_pnr.v"]
saveNetlist $schematic_filename
# GDS
set filename [format "%s%s%s%s" $env(DES_GEN_DIR) "/" $my_toplevel "_pnr.gds"]
streamOut $filename -mapFile $iv_layer_map_file -libName $my_output_lib -units 1000 -mode ALL


exit
