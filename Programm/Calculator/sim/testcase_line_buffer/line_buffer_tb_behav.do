if {[file exists behav_work]} {
  vdel -all -lib behav_work
}

# create work library directory
vlib behav_work

# map directory to library name "work"
vmap work behav_work

#compile vhdl files

	vcom -work work ../../../textmode_vga/src/mjl_stratix/textmode_vga_platform_dependent_pkg.vhd
	vcom -work work ../../../math/src/math_pkg.vhd
	vcom -work work ../../../textmode_vga/src/textmode_vga_pkg.vhd
	vcom -work work ../../../textmode_vga/src/font_pkg.vhd
	vcom -work work ../../../textmode_vga/src/textmode_vga_component_pkg.vhd	


	vcom -work work ../../src/line_buffer_pkg.vhd
	vcom -work work ../../src/line_buffer_ent.vhd
	vcom -work work ../../src/line_buffer_arc_beh.vhd


# vcom -work work -cover bs ../../src/demo.vhd

# compile testbench
vcom -work work line_buffer_tb.vhd

# compile configuration file
#vcom -work work config_behav.vhd

# start simulation
vsim -coverage work.line_buffer_tb

view -undock wave

# add signals to waveform
# add all testbench signals
#add wave *

# add internal signals of unit under test
#add wave -divider DEMO
#add wave uut/counter
#add wave uut/ledstate

# auto-run simulation
run 50 us
#wave zoomfull
