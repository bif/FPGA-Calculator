# compile technology libraries
# if you're using Quartus Web Edition combined with ModelSim-Altera you have
# to omit this step. ModelSim-Altera uses its own precompiled Altera technology
# libraries.

set SIM_LIBRARY_PATH /opt/altera8.1/quartus/eda/sim_lib

if {[file exists cyclonelib]} {
  vdel -all -lib cyclonelib
}

vlib cyclonelib
vmap cycloneii cyclonelib

vcom -work cycloneii $SIM_LIBRARY_PATH/cycloneii_atoms.vhd
vcom -work cycloneii $SIM_LIBRARY_PATH/cycloneii_components.vhd

# end compile technology libraries


# create work library directory
vlib post_work

# map directory to library name "work"
vmap work post_work

# compile gate-level netlist
set NETLIST_PATH ../../quartus/simulation/modelsim

vcom -work work "$NETLIST_PATH/demo.vho"

# compile testbench
vcom -work work {../../src/demo_pkg.vhd}
vcom -work work demo_tb.vhd

# compile configuration file
vcom -work work config_post.vhd

# start simulation
vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /uut=$NETLIST_PATH/demo_vhd.sdo -L cycloneii -L work work.conf

view -undock wave

# add signals to waveform
# add all testbench signals
add wave *

# auto-run simulation
run 50 us
wave zoomfull

