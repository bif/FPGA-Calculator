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

	vcom -work work ../../src/sp_ram_pkg.vhd
	vcom -work work ../../src/sp_ram_ent.vhd
	vcom -work work ../../src/sp_ram_arc_beh.vhd

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

quietly WaveActivateNextPane {} 0
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state
add wave -noupdate -format Literal /line_buffer_tb/uut/lb_fsm_state_next
add wave -noupdate -format Logic /line_buffer_tb/clk
add wave -noupdate -format Logic /line_buffer_tb/vga_free_sig
add wave -noupdate -format Logic /line_buffer_tb/uut/enable
add wave -noupdate -format Logic /line_buffer_tb/uut/enable_old
add wave -noupdate -format Logic /line_buffer_tb/uut/enable_old_next
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/count
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/count_next
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/reset_count
add wave -noupdate -format Literal -radix decimal /line_buffer_tb/uut/reset_count_next
add wave -noupdate -format Logic /line_buffer_tb/new_ascii_sig
add wave -noupdate -format Literal -radix ascii /line_buffer_tb/ascii_sign_sig


add wave -noupdate -format Literal -radix hexadecimal /line_buffer_tb/uut/bcd_result
add wave -noupdate -format Literal -radix hexadecimal /line_buffer_tb/uut/bcd_result_sig
add wave -noupdate -format Literal /line_buffer_tb/command_sig
#add wave -noupdate -format Literal -radix ascii /line_buffer_tb/command_data_sig
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(7)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(7)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(6)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(5)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(4)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(3)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(2)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(1)
add wave -noupdate -format Logic /line_buffer_tb/command_data_sig(0)
#add wave -noupdate -format Literal -radix decimal /line_buffer_tb/mem_debug_addr
#add wave -noupdate -format Literal -radix ascii /line_buffer_tb/mem_debug_data

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
#simulate save value (first sign ?)
#WaveRestoreZoom {7200 ns} {7400 ns}
#simulate enable
#WaveRestoreZoom {26800 ns} {27000 ns}
#simulate memmory 
#WaveRestoreZoom {22950 ns} {25000 ns}
#siulate bcd_result
WaveRestoreZoom {22500 ns} {25000 ns}
#wave zoomfull
