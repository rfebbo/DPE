
set lib_search_path {                                                      \
  "/research/seneca/RAVENS_10LPe/LibraryData/stdlib_10lpe/current/library" \
  "/research/seneca/RAVENS_10LPe/LibraryData/stdio_10lpe/current/library"  \
}

set synthetic_library [list dw_foundation.sldb]
set target_library [list stdlib_10lpe_ccs_comb.db stdio_10lpe_ccs.db]
# set target_library [list stdlib_tsmc65_ccs_comb.db]
set link_library [concat [concat "*" $target_library] $synthetic_library]
