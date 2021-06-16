
***** This is not entirely set up, tested, and debugged yet *****

=== How To ===
  *** Make sure the file name for the top level designs are named "<top level module>.sv" ***

  Dump any source files into "srcs", or into the current directory.
  Utility designs are already included in the "core/base-srcs" directory.
  These include: RegPLoad, ShiftRegN, and ShiftRegPLoad

  Make a copy of "user_designs.template" and add/replace the name of your top level 
  module(s)/file(s) into the list, one entry per line.

  Make a copy of "user_cfg.template". Make changes desired.

  If one, or neither, of these files exist, the template files themselves will be sourced.
  This will run with the example design.

  Then, run "run-syn-pnr.sh".


=== (Current) Limitations ===
  Does not specify pin names or locations while running Innovus.

  Does not handle IO/pad frames at the moment.

  Currently uses absolute paths for a number of things.

  Can not run a mixture of pure-logic and clocked designs at the same time while 
  implementing optimizations/CTS for the clocked designs. To run pure-logic designs,
  leave "DC_CLK_NETS" as an empty string. Otherwise, put your clk net/pin name(s) here.
    *** It works fine for Design Compiler, but Innovus is being annoying

