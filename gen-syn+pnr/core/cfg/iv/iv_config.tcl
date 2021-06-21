
setMultiCpuUsage -localCpu $env(IV_NUM_THREADS)

# Via setting
setGenerateViaMode -auto true
# Timing unit
setLibraryUnit -time 1ns

setDesignMode -process 65


set conf_qxconf_file NULL
set conf_qxlib_file NULL
set defHierChar /win

if {$env(IV_USE_OA)} {
  set init_oa_ref_lib {cmos10lpe stdlib_10lpe stdlib_10lpe_filler stdio_10lpe}
  set init_abstract_view abstract
  set init_layout_view layout
} else {
  set init_lef_file {                                                              \
    # /research/seneca/RAVENS_10LPe/TechData/cmos10lpe_tech.lef                      \
    /research/seneca/RAVENS_10LPe/cmos10lpe_tech-antenna_testing.lef               \
    /research/seneca/RAVENS_10LPe/LibraryData/stdlib_10lpe/stdlib_10lpe.lef        \
    /research/seneca/RAVENS_10LPe/LibraryData/stdlib_10lpe/stdlib_10lpe_filler.lef \
    /research/seneca/RAVENS_10LPe/LibraryData/stdio_10lpe/stdio_10lpe.lef          \
    # /research/seneca/RAVENS_10LPe/LibraryData/sram_arrays/sram_1kb_64x128x32.lef   \
    # /research/seneca/RAVENS_10LPe/testing_lefs/sram-1kb/sram_arrays-1kb_64x128x32-20210616-test_1.lef \
    /research/seneca/RAVENS_10LPe/testing_lefs/sram-1kb/sram_arrays-1kb_64x128x32-20210616-test_2.lef \
    /research/seneca/RAVENS_10LPe/LibraryData/sram_arrays/sram_2kb_128x128x32.lef  \
    /research/seneca/RAVENS_10LPe/LibraryData/sram_arrays/sram_4kb_256x128x8.lef   \
  }
}


set iv_layer_map_file /research/seneca/RAVENS_10LPe/TechData/cmos10lpe_innovus.map
