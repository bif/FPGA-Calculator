if {[file exists behav_work]} {
  vdel -all -lib behav_work
}

# create work library directory
vlib behav_work

# map directory to library name "work"
vmap work behav_work

#compile vhdl files

	vcom -work work ../../src/sp_ram_pkg.vhd
	vcom -work work ../../src/sp_ram_ent.vhd
	vcom -work work ../../src/sp_ram_arc_beh.vhd

	vcom -work work ../../src/parser_pkg.vhd
	vcom -work work ../../src/parser_ent.vhd
	vcom -work work ../../src/parser_arc_beh.vhd


# vcom -work work -cover bs ../../src/demo.vhd

# compile testbench
vcom -work work parser_tb.vhd

# compile configuration file
#vcom -work work config_behav.vhd

# start simulation
vsim -coverage work.parser_tb

quietly WaveActivateNextPane {} 0
# add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update



# auto-run simulation
run 50 us
wave zoomfull
